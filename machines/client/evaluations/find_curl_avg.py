import csv

with open('./results/prob_results_no_ebpf.csv', newline='') as csvfile:
    reader = csv.reader(csvfile, delimiter=',')
    next(reader, None) # skip header
    total = 0
    count = 0
    for row in reader:
        # if it's a success
        if row[2] == '0':
            total += float(row[3])
            count += 1
    print(total/count)