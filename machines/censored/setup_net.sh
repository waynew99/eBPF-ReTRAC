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
echo "net.ipv4.conf.eth1.rp_filter=0" >> /etc/sysctl.conf

sysctl -p

sudo iptables -I INPUT 1 -p tcp -d 10.0.4.5/24 -j REJECT --reject-with tcp-reset

exit