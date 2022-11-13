#!/bin/bash

echo "Start time: $(date)"
# list of selected descriptions
mapfile -t inpfilearray < fix_stats_names_all_info.txt

ninpfiles=${#inpfilearray[@]}

echo "There are $ninpfiles input data files in this run."

# a bit long
for (( i=0; i<$ninpfiles; i++ )); do echo "${inpfilearray[$i]}" ; done

placeholder="[1] 0000-00-00 00:00:00 NZST"
error_count=0

ifile=0

while [ $ifile -lt $ninpfiles ]; do
#while [ $ifile -lt 2 ]; do    
    filenum=$((1+$ifile))
    work_file=${inpfilearray[$ifile]}
    echo "Start file ${filenum}. Time  $(date)"
    R CMD BATCH --no-restore "--args "${work_file}"" htoutlier_pass1_id.R htoutlier_pass1_id_file_${filenum}.R.out
    
    let ifile++

done
    
echo "Finish time: $(date)"

exit

