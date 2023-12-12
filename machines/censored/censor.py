from scapy.all import *

censored_ip = "10.0.4.5"


def process_tcp_packet(packet):
    if TCP in packet and packet[TCP].flags:
        if packet[IP].dst == censored_ip:
            print(f"Source IP: {packet[IP].src}, Destination IP: {packet[IP].dst}, TCP Flags: {packet[TCP].flags}")
            # send a TCP RST packet to the srouce IP
            rst_pkt = IP(id=30000, src=censored_ip, dst=packet[IP].src) / TCP(flags="R", sport=packet[TCP].dport, dport=packet[TCP].sport, seq=packet[TCP].ack)
            send(rst_pkt, verbose=0)

if __name__ == "__main__":
    sniff(filter="tcp", prn=process_tcp_packet, store=0)
    
