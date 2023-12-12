
import random
import os

# 1000 2000 4000 6000 8000 10000 15000 20000 25000 30000
NUM_FREE_PORTS=30000

START_PORT = 1000
END_PORT = 65535

free_ports = random.sample(range(START_PORT, END_PORT), NUM_FREE_PORTS)
free_ports.sort()
with open("free_ports.txt", "w") as f:
    for port in free_ports:
        f.write(str(port) + "\n")

free_ports_set = set(free_ports)


censored_ports_ranges = list()
start = None
end = None
for port in range(START_PORT, END_PORT):
    if port in free_ports_set:
        if start is not None:
            end = port - 1
            censored_ports_ranges.append((start, end))
            start = None
            end = None
    else:
        if start is None:
            start = port

with open("censored_ports_ranges.txt", "w") as f:
    for start, end in censored_ports_ranges:
        f.write(str(start) + "-" + str(end) + "\n")
