#!/bin/bash

# auto changes batch_size
# But need to modify freeports manually and update here in the variable

batch_size_list=(10 20 50 100 200)
num_freeports=1000 # manually change this

for batch_size in "${batch_size_list[@]}"; do
    # change "#define BATCH_SIZE 20" to "#define BATCH_SIZE $batch_size" in tc-egress-freeports.bpf.c
    echo "batch_size: $batch_size"
    sed -i "s/#define BATCH_SIZE [0-9]\+/#define BATCH_SIZE $batch_size/g" /vagrant/tc-egress-freeports.bpf.c
    sudo ../setup-freeports.sh
    ./prob_free_port_q.sh "$batch_size" "$num_freeports"
done