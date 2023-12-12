#!/bin/bash

echo "Removing maps ..."
rm /sys/fs/bpf/tc/globals/port_map 2> /dev/null
rm /sys/fs/bpf/tc/globals/conn_map 2> /dev/null
rm /sys/fs/bpf/tc/globals/free_map 2> /dev/null
rm /sys/fs/bpf/tc/globals/inner_map 2> /dev/null
rm /sys/fs/bpf/tc/globals/orig_to_rewritten_ports_map 2> /dev/null
echo "Removing XDP program from interface eth1 ..."
ip link set dev eth1 xdpgeneric off 2> /dev/null
echo "Unloading TC from interface eth1 ..."
tc qdisc del dev eth1 clsact 2> /dev/null

echo "Done. eBPF-ReTRAC fully removed."
