#!/bin/bash

# check if ran as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


# While "eth1" exists in the output of "ip rule", delete ip rule
c=1
while ip rule | grep -q "eth1"; do
    if [ $((c % 100)) -eq 0 ]; then
        echo $c
    fi
    c=$((1 + $c)) 
    ip rule del iif eth1
done