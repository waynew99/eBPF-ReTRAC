import csv
import os.path


def find_avg(file_name):
    with open(file_name, newline='') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        next(reader, None) # skip header
        with_overhead_total = 0
        without_overhead_total = 0
        with_overhead_count = 0
        without_overhead_count = 0
        for row in reader:
            # if it's a success
            if row[1] == '0':
                if row[4] == '1':
                    with_overhead_total += float(row[2])
                    with_overhead_count += 1
                else:
                    without_overhead_total += float(row[2])
                    without_overhead_count += 1
        
        with_overhead_avg = with_overhead_total/with_overhead_count
        without_overhead_avg = without_overhead_total/without_overhead_count
        overhead_avg = with_overhead_avg - without_overhead_avg

        print('[Average]'+os.path.basename(file_name))
        print('With overhead: {:.6f}'.format(with_overhead_avg))
        print('Without overhead: {:.6f}'.format(without_overhead_avg))
        print('Overhead: {:.6f}'.format(overhead_avg))


find_avg('./results/ebpf_prog_overhead.csv')
find_avg('./results/router_overhead.csv')
