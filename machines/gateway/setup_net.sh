#!/bin/bash
#

sudo apt-get update
sudo apt-get install -y net-tools traceroute
#apt-get install -y openvpn

sudo cp /vagrant/50-vagrant.yaml /etc/netplan/
sudo netplan apply

# Enable ip forwarding
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.lo.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth1.rp_filter=2" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth2.rp_filter=2" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth3.rp_filter=2" >> /etc/sysctl.conf

sysctl -p


# Enable ip routing based on source port
#echo "2 free" >> /etc/iproute2/rt_tables
#echo "3 censored" >> /etc/iproute2/rt_tables

# ip route add table 2 10.0.4.0/24 via 10.0.2.3 dev eth2
# ip route add table 2 default via 10.0.2.3
# ip route add table 3 10.0.4.0/24 via 10.0.3.4 dev eth3
# ip route add table 3 default via 10.0.3.4

# /vagrant/del_all_ip_rules.sh
# /vagrant/gen_rand_port.sh
# /vagrant/add_ip_rule.sh

exit