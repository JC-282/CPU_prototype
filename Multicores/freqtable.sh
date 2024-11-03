#dam Busch - ECE437 Fall 2021
#! /bin/bash
fname="freq_table_$(date +"%Y_%m_%d_%I_%M_%p").txt"
echo "Frequency Sweep Report File $(date +"%Y_%m_%d_%I_%M_%p")" > $fname

for  ram_lat in 0 2 4 6 8 10
do
    sed -r "s|LAT = [0-9]+|LAT = $ram_lat|1" source/ram.sv | cat > temp_ram
    cat temp_ram > source/ram.sv
    rm temp_ram
    synthesize -t -f 200 system

    echo "Frequency table for LAT = $ram_lat 85C Model" >> $fname
    grep -A 7 "Slow 1200mV 85C Model Fmax Summary" ._system/system.sta.rpt | tail -n7 >> $fname
done

