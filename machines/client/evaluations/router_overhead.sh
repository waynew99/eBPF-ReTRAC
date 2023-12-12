#!/bin/bash

num_freeports=65535

with_router_overhead=0

num_successes=0
#while num_successes<100
while [ $num_successes -lt 100 ]; do
    echo "num_successes: $num_successes"
    output=$(curl 10.0.4.5/ -w "%{time_total},%{time_connect}" -o /dev/null -s --connect-timeout 1)
    success=$?
    
    if [ $success -eq 0 ]; then
        time_total=$(echo "$output" | cut -d',' -f1)
        time_connect=$(echo "$output" | cut -d',' -f2)
        success_code=0
        success_text="success"
        num_successes=$((num_successes+1))
        printf "%s. time_total: %.6f, time_connect: %.6f\n" "$success_text" "$time_total" "$time_connect"
        printf "%d,%d,%.6f,%.6f,%d\n" "$num_freeports" "$success_code" "$time_total" "$time_connect" "$with_router_overhead">> ../results/router_overhead.csv
    else
        success_code=1
        success_text="failed "
        printf "%s. \n"  "$success_text"
    fi

    
done