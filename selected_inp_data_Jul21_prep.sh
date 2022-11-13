#!/bin/bash

echo "Start time: $(date)"
# list of selected descriptions
ls -1v Jul21*status1.txt > list_Jul21_status1_files

# csv files
ls -1v Jul21*stats*csv > list_Jul21_outlier_stats_files
awk -F"-" '{print $2}' list_Jul21_status1_files > list_Jul21_status1_files_names
awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Jul21_status1_files_names list_Jul21_outlier_stats_files > selected_Jul21_outlier_stats_files

# count files
ls -1v Jul21*cnts*csv > list_Jul21_outlier_cnts_files
awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Jul21_status1_files_names list_Jul21_outlier_cnts_files > selected_Jul21_outlier_cnts_files

# .inp files
ls -1v Jul21/*inp > all_Jul21_inp_files
awk -F'[/.]' 'NR==FNR{a[$1]; next} $2 in a' list_Jul21_status1_files_names all_Jul21_inp_files > selected_Jul21_input_files

# create directories
mkdir Jul21_sel_AM_VOL
mkdir Jul21_sel_PM_VOL
mkdir Jul21_sel_FAT_PCT
mkdir Jul21_sel_PROT_PCT

echo "Finish time: $(date)"

exit

