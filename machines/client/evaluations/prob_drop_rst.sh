#!/bin/bash
trials=100

# check if we have $1 and $2
if [ $# -ne 2 ]; then
    echo "Usage: ./prob_drop_rst.sh <batch_size> <num_freeports>"
    exit 1
fi
batch_size=$1
num_freeports=$2

sum_real=0
for ((i=0; i<trials; i++)); do
    output=$(curl 10.0.4.5 -w "%{time_total},%{time_connect}" -o /dev/null -s --connect-timeout 1)
    success=$?
    time_total=$(echo "$output" | cut -d',' -f1)
    time_connect=$(echo "$output" | cut -d',' -f2)
    success_code=0
    success_text="success"
    
    if [ $success -eq 0 ]; then
        success_code=0
        success_text="success"
    else
        success_code=1
        success_text="failed "
    fi

    printf "%d %s. time_total: %.6f, time_connect: %.6f\n" "$i" "$success_text" "$time_total" "$time_connect"
    printf "%d,%d,%d,%.6f,%.6f\n" "$batch_size" "$num_freeports" "$success_code" "$time_total" "$time_connect" >> ../results/prob_results_drop_rst.csv
done
