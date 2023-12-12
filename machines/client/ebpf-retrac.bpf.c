#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/pkt_cls.h>
#include <linux/swab.h>
#include <bpf/bpf_endian.h>
#include <linux/filter.h>
#include <string.h>

#define BATCH_SIZE 200
#define PIN_GLOBAL_NS 2

struct rewritten_ports
{
	__u16 ports[BATCH_SIZE];
};

struct bpf_elf_map
{
	__u32 type;
	__u32 key_size;
	__u32 value_size;
	__u32 max_entries;
	__u32 flags;
	__u32 id;
	__u32 pinning;
};

// rewritten port -> original port
struct bpf_elf_map SEC("maps") port_map = {
	.type = BPF_MAP_TYPE_HASH,
	.key_size = sizeof(__u16),
	.value_size = sizeof(__u16),
	.max_entries = 32767,
	.pinning = PIN_GLOBAL_NS,
};

// original port -> inner map of oustanding new ports
struct bpf_elf_map SEC("maps") orig_to_rewritten_ports_map = {
	.type = BPF_MAP_TYPE_HASH,
	.key_size = sizeof(__u16),
	.value_size = sizeof(struct rewritten_ports),
	.max_entries = 32767,
	.pinning = PIN_GLOBAL_NS,
};

struct bpf_elf_map SEC("maps") free_ports_pool = {
	.type = BPF_MAP_TYPE_QUEUE,
	.key_size = 0,
	.value_size = sizeof(__u16),
	.max_entries = 10,
	.pinning = PIN_GLOBAL_NS,
};

SEC("xdp")
int rev_classifier(struct xdp_md *ctx)
{
	void *data = (void *)(unsigned long long)ctx->data;
	void *data_end = (void *)(unsigned long long)ctx->data_end;

	struct ethhdr *eth = data;
	struct iphdr *ip = data + sizeof(struct ethhdr);
	struct tcphdr *tcp = data + sizeof(struct ethhdr) + sizeof(struct iphdr);
	if ((void *)(tcp + 1) > data_end)
		return XDP_PASS;

	__u16 sport = bpf_htons(tcp->source);

	if (sport == 80)
	{
		if (tcp->rst)
		{
			bpf_printk("[DEBUG_XDP] RST packet\n");
			return XDP_DROP;
		}

		__u16 dport = tcp->dest; // dport already in network-byte order
		__u16 *app_port_ptr = bpf_map_lookup_elem(&port_map, &dport);

		if (!app_port_ptr)
			return XDP_PASS;

		if (tcp->syn && tcp->ack)
		{
			bpf_map_push_elem(&free_ports_pool, &dport, BPF_EXIST);
			bpf_printk("[DEBUG_XDP] Added port %d to free ports pool\n", bpf_ntohs(dport));
		}

		// update port
		tcp->dest = bpf_htons(*app_port_ptr);
		bpf_printk("[DEBUG_XDP]: Port %d rewritten to port %d\n", bpf_ntohs(dport), bpf_ntohs(tcp->dest));
	}

	return XDP_PASS;
}

SEC("tc")
int classifier(struct __sk_buff *skb)
{
	void *data = (void *)(unsigned long long)skb->data;
	void *data_end = (void *)(unsigned long long)skb->data_end;

	struct ethhdr *eth = data;
	struct iphdr *ip = data + sizeof(struct ethhdr);
	struct tcphdr *tcp = data + sizeof(struct ethhdr) + sizeof(struct iphdr);

	if ((void *)(tcp + 1) > data_end)
		return TC_ACT_OK;

	__u16 sport = bpf_htons(tcp->source);
	__u16 dport = bpf_htons(tcp->dest);

	// if sport in map, it's rewritten
	if (dport == 80 && skb->mark != 1)
	{
		skb->mark = 1; // need to do this so bpf_clone_redirect() doesn't trigger infinite processing
		__u32 saddr = bpf_htons(ip->saddr);
		__u32 daddr = bpf_htons(ip->daddr);

		if (tcp->syn)
		{
			__u16 free_sport;
			int ret = bpf_map_pop_elem(&free_ports_pool, &free_sport);

			if (ret == 0)
			{
				bpf_map_update_elem(&port_map, &free_sport, &sport, BPF_ANY);
				bpf_map_update_elem(&port_map, &sport, &free_sport, BPF_ANY);
			}
			else
			{
				struct rewritten_ports ports;
				for (int i = 0; i < BATCH_SIZE; i++)
				{
					ports.ports[i] = bpf_htons((__u16)(bpf_get_prandom_u32() >> 16));
					bpf_map_update_elem(&port_map, &ports.ports[i], &sport, BPF_ANY);
				}
				bpf_map_update_elem(&orig_to_rewritten_ports_map, &sport, &ports, BPF_ANY);
			}
		}

		struct rewritten_ports *ports_ptr = bpf_map_lookup_elem(&orig_to_rewritten_ports_map, &sport);

		if (!ports_ptr)
		{
			__u16 *known_free_port_ptr = bpf_map_lookup_elem(&port_map, &sport);
			if (known_free_port_ptr)
			{
				__u16 free_sport = *known_free_port_ptr;
				__u32 off = sizeof(struct ethhdr) + sizeof(struct iphdr) + __builtin_offsetof(struct tcphdr, source);
				bpf_skb_store_bytes(skb, off, &free_sport, sizeof(free_sport), BPF_F_RECOMPUTE_CSUM);
			}
			return TC_ACT_OK;
		}

		for (int i = 0; i < BATCH_SIZE; i++)
		{
			bpf_printk("Port %d is %d %d\n", i, ports_ptr->ports[i], bpf_htons(ports_ptr->ports[i]));
			// We use existing port numbers in the array, ragardless of SYN or not
			__u16 new_sport = ports_ptr->ports[i];

			// But don't rewrite if the port number in the array is in use
			struct bpf_sock_tuple tuple = {saddr, daddr, new_sport, dport};
			struct bpf_sock *sk = bpf_sk_lookup_tcp(skb, &tuple, sizeof(tuple.ipv4), BPF_F_CURRENT_NETNS, 0);
			if (sk)
			{
				bpf_sk_release(sk);
				continue;
			}

			__u32 off = sizeof(struct ethhdr) + sizeof(struct iphdr) + __builtin_offsetof(struct tcphdr, source);
			bpf_skb_store_bytes(skb, off, &new_sport, sizeof(new_sport), BPF_F_RECOMPUTE_CSUM);

			bpf_clone_redirect(skb, skb->ifindex, 0);
		}

		return TC_ACT_STOLEN;
	}
	else
	{
		return TC_ACT_OK;
	}
}

char LICENSE[] SEC("license") = "Dual BSD/GPL";
