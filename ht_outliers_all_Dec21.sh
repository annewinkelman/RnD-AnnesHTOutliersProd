#!/bin/bash

echo "Start time: $(date)"
# list of selected descriptions
inpfilearray=(`ls -1v Dec21/*.inp`)

ninpfiles=${#inpfilearray[@]}

echo "There are $ninpfiles input data files in this run."

# a bit long
#for (( i=0; i<$ninpfiles; i++ )); do echo "${inpfilearray[$i]}" ; done

placeholder="[1] 0000-00-00 00:00:00 NZST"
error_count=0

ifile=0

while [ $ifile -lt $ninpfiles ]; do
#while [ $ifile -lt 2 ]; do    
    filenum=$((1+$ifile))
    work_file=${inpfilearray[$ifile]}
    echo "Start file ${filenum}. Time  $(date)"
    R CMD BATCH --no-restore "--args "${work_file}"" htoutlier_pass1_id.R htoutlier_pass1_id_Dec21_file_${filenum}.R.out
    awk -v lines=2 '/end.time/ {for(i=lines;i;--i)getline; print $0 }' htoutlier_pass1_id_Dec21_file_${filenum}.R.out > work_temp_date
    nlength=$(wc -l work_temp_date | awk '{print $1}')
    if [ $nlength -eq 0 ]
    then
        let error_count++
	work_temp_date=$placeholder
    fi
    awk '{print $2, $3, $4}' work_temp_date >> htoutlier_pass1_id_Dec21_file.all.end.times
    echo "Finish herd test file: $(date) Error Count: ${error_count}"    
    let ifile++

done
    
echo "Finish time: $(date)"

exit

