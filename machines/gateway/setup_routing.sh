#!/bin/bash
#

# check if ran as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


# Enable ip routing based on source port
echo "2 free" >> /etc/iproute2/rt_tables
echo "3 censored" >> /etc/iproute2/rt_tables

ip route add table 2 10.0.4.0/24 via 10.0.2.3 dev eth2
ip route add table 2 default via 10.0.2.3
ip route add table 3 10.0.4.0/24 via 10.0.3.4 dev eth3
ip route add table 3 default via 10.0.3.4

#/vagrant/del_all_ip_rules.sh
#/vagrant/gen_rand_port.sh
#/vagrant/add_ip_rule.sh