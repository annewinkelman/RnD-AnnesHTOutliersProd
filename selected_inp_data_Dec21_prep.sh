#!/bin/bash

echo "Start time: $(date)"
# list of selected descriptions
ls -1v Dec21*status1.txt > list_Dec21_status1_files

# csv files
ls -1v Dec21*stats*csv > list_Dec21_outlier_stats_files
awk -F"-" '{print $2}' list_Dec21_status1_files > list_Dec21_status1_files_names
awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Dec21_status1_files_names list_Dec21_outlier_stats_files > selected_Dec21_outlier_stats_files

# count files
ls -1v Dec21*cnts*csv > list_Dec21_outlier_cnts_files
awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Dec21_status1_files_names list_Dec21_outlier_cnts_files > selected_Dec21_outlier_cnts_files

# .inp files
ls -1v Dec21/*inp > all_Dec21_inp_files
awk -F'[/.]' 'NR==FNR{a[$1]; next} $2 in a' list_Dec21_status1_files_names all_Dec21_inp_files > selected_Dec21_input_files

# create directories
mkdir Dec21_sel_AM_VOL
mkdir Dec21_sel_PM_VOL
mkdir Dec21_sel_FAT_PCT
mkdir Dec21_sel_PROT_PCT

R CMD BATCH selected_inp_data_Dec21_calcs.R selected_inp_data_Dec21_calcs.R.out

echo "Finish time: $(date)"

exit

