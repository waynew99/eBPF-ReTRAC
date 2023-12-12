#!/bin/bash
#

sudo apt-get update
sudo apt-get install -y net-tools traceroute nginx

sudo cp /vagrant/50-vagrant.yaml /etc/netplan/
sudo netplan apply

echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.lo.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth1.rp_filter=0" >> /etc/sysctl.conf

# Changing SYN_RECV timeout to about 3 seconds
# https://stackoverflow.com/questions/26671755/is-there-a-timeout-at-syn-rcvd-state-on-linux
echo "net.ipv4.tcp_synack_retries=1" >> /etc/sysctl.conf

sysctl -p

exit