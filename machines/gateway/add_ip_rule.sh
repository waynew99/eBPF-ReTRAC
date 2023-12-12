#!/bin/bash

# check if ran as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

#sudo ip rule add iif eth1 ipproto tcp sport 1000-2000 lookup 2


echo $(cat free_ports.txt | wc -l) free ports
echo $(cat censored_ports_ranges.txt | wc -l) censored port ranges

# wait enter to continue
read -p "Press enter to continue"

# Iterate through free_ports.txt and add rules
free=1
while read port; do
    if [ $((free % 100)) -eq 0 ]; then
        echo $free free complete
    fi
    free=$((1 + $free)) 
    ip rule add iif eth1 ipproto tcp sport $port lookup 2
    # sudo ip rule add iif eth1 ipproto udp sport $port lookup 2
done < /vagrant/free_ports.txt

#Iterate through censored_ports_ranges.txt.txt and add rules
censored=1
while read range; do
    if [ $((censored % 100)) -eq 0 ]; then
        echo $censored censored ranges complete
    fi
    censored=$((1 + $censored))
    sudo ip rule add iif eth1 ipproto tcp sport $range lookup 3
done < /vagrant/censored_ports_ranges.txt

ip rule add iif eth1 ipproto udp lookup 2
