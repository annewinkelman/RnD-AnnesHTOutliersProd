#!/bin/bash

echo "Start time: $(date)"
# list of selected descriptions
ls -1v Jun21*status1.txt > list_Jun21_status1_files

# csv files
ls -1v Jun21*stats*csv > list_Jun21_outlier_stats_files
awk -F"-" '{print $2}' list_Jun21_status1_files > list_Jun21_status1_files_names
awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Jun21_status1_files_names list_Jun21_outlier_stats_files > selected_Jun21_outlier_stats_files

# count files
ls -1v Jun21*cnts*csv > list_Jun21_outlier_cnts_files
awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Jun21_status1_files_names list_Jun21_outlier_cnts_files > selected_Jun21_outlier_cnts_files

# .inp files
ls -1v Jun21/*inp > all_Jun21_inp_files
awk -F'[/.]' 'NR==FNR{a[$1]; next} $2 in a' list_Jun21_status1_files_names all_Jun21_inp_files > selected_Jun21_input_files

# create directories
#mkdir Jun21_sel_AM_VOL
#mkdir Jun21_sel_PM_VOL
#mkdir Jun21_sel_FAT_PCT
#mkdir Jun21_sel_PROT_PCT

R CMD BATCH selected_inp_data_Jun21_calcs.R selected_inp_data_Jun21_calcs.R.out

echo "Finish time: $(date)"

exit

