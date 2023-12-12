#!/bin/bash
#

sudo apt-get update
sudo apt-get install -y net-tools traceroute
#apt-get install -y openvpn

sudo cp /vagrant/50-vagrant.yaml /etc/netplan/
sudo netplan apply

echo "net.ipv4.conf.all.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.default.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.lo.rp_filter=0" >> /etc/sysctl.conf
echo "net.ipv4.conf.eth1.rp_filter=0" >> /etc/sysctl.conf

sysctl -p

exit