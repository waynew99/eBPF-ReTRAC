#!/bin/bash

# check if ran as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# the first argument must specify the network interface, second argument is optional
# Usage: ./setup_ebpf_retrac.sh <interface> [--teardown]
# teardown removes the eBPF program from the interface and also cleans cached free ports
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Usage: ./setup_ebpf_retrac.sh <interface> [--teardown]"
    echo "Optional teardown removes the eBPF program from the interface and cleans cached free ports"
    exit
fi

# check if the interface exists
if ! ip link show $1 &>/dev/null; then
    echo "Interface $1 does not exist"
    exit
fi

cleanup() {
    rm /sys/fs/bpf/tc/globals/port_map 2>/dev/null
    rm /sys/fs/bpf/tc/globals/orig_to_rewritten_ports_map 2>/dev/null
    ip link set dev $1 xdpgeneric off 2>/dev/null
    tc qdisc del dev $1 clsact 2>/dev/null
}

fun_stuff() {
    for i in {1..10}; do
        echo -e "\033[1;34m      _______________________________      __________     _____________________    _____  _________   \033[0m"
        echo -e "\033[1;32m  ____\______   \______   \_   _____/      \______   \ ___\__    ___/\______   \  /  _  \ \_   ___ \  \033[0m"
        echo -e "\033[1;36m_/ __ \|    |  _/|     ___/|    __)  ______ |       _// __ \|    |    |       _/ /  /_\  \/    \  \/  \033[0m"
        echo -e "\033[1;33m\  ___/|    |   \|    |    |     \  /_____/ |    |   \  ___/|    |    |    |   \/    |    \     \____ \033[0m"
        echo -e "\033[1;35m \___  >______  /|____|    \___  /          |____|_  /\___  >____|    |____|_  /\____|__  /\______  / \033[0m"
        echo -e "\033[1;31m     \/       \/               \/                  \/     \/                 \/         \/        \/  \033[0m"

        sleep 0.1
        clear
        sleep 0.1
    done

    echo -e "\033[1;34m      _______________________________      __________     _____________________    _____  _________   \033[0m"
    echo -e "\033[1;32m  ____\______   \______   \_   _____/      \______   \ ___\__    ___/\______   \  /  _  \ \_   ___ \  \033[0m"
    echo -e "\033[1;36m_/ __ \|    |  _/|     ___/|    __)  ______ |       _// __ \|    |    |       _/ /  /_\  \/    \  \/  \033[0m"
    echo -e "\033[1;33m\  ___/|    |   \|    |    |     \  /_____/ |    |   \  ___/|    |    |    |   \/    |    \     \____ \033[0m"
    echo -e "\033[1;35m \___  >______  /|____|    \___  /          |____|_  /\___  >____|    |____|_  /\____|__  /\______  / \033[0m"
    echo -e "\033[1;31m     \/       \/               \/                  \/     \/                 \/         \/        \/  \033[0m"

    echo -e "\033[1;34m                       _____          __  .__               __             .___                       \033[0m"
    echo -e "\033[1;32m                      /  _  \   _____/  |_|__|__  _______ _/  |_  ____   __| _/                       \033[0m"
    echo -e "\033[1;36m                     /  /_\  \_/ ___\   __\  \  \/ /\__  \\   __\/ __ \ / __ |                        \033[0m"
    echo -e "\033[1;33m                    /    |    \  \___|  | |  |\   /  / __ \|  | \  ___// /_/ |                        \033[0m"
    echo -e "\033[1;35m                    \____|__  /\___  >__| |__| \_/  (____  /__|  \___  >____ |                        \033[0m"
    echo -e "\033[1;31m                            \/     \/                    \/          \/     \/                        \033[0m"
}

# check if the option --teardown is specified
if [ "$#" -eq 2 ] && [ "$2" == "--teardown" ]; then
    rm /sys/fs/bpf/tc/globals/free_ports_pool 2>/dev/null
    cleanup
    echo "Done. eBPF-ReTRAC fully removed."
    exit
else
    echo "Setting up eBPF-ReTRAC..."
    cleanup
    clang -O2 -target bpf -c ./ebpf-retrac.bpf.c -o ebpf-retrac.bpf.o
    ip link set dev $1 xdpgeneric obj ebpf-retrac.bpf.o sec xdp
    tc qdisc add dev $1 clsact
    tc filter add dev $1 egress bpf direct-action obj ebpf-retrac.bpf.o sec tc
    fun_stuff
fi
