#!/bin/bash

sizelist=(1 2 5 10 20)

batch_size=200
num_freeports=65535

trials=30

with_retrac=1

for size in "${sizelist[@]}"
do
    echo "Testing with $size MB"
    trials=30
    for ((i=0; i<trials; i++)); do

        output=$(curl 10.0.4.5/"$size"MB -w "%{time_total},%{time_connect}" -o /dev/null -s)
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
        printf "%d,%d,%d,%.6f,%.6f,%d\n" "$batch_size" "$num_freeports" "$success_code" "$time_total" "$time_connect" "$size" "$with_retrac">> ../results/prob_results_size.csv
    done
done