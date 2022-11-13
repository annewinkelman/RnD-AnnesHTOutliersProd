#!/bin/bash

echo "Start time: $(date)"
# list of selected descriptions
ls -1v Jan22*status1.txt > list_Jan22_status1_files

# csv files
ls -1v Jan22*stats*csv > list_Jan22_outlier_stats_files
awk -F"-" '{print $2}' list_Jan22_status1_files > list_Jan22_status1_files_names
awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Jan22_status1_files_names list_Jan22_outlier_stats_files > selected_Jan22_outlier_stats_files

# count files
ls -1v Jan22*cnts*csv > list_Jan22_outlier_cnts_files
awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Jan22_status1_files_names list_Jan22_outlier_cnts_files > selected_Jan22_outlier_cnts_files

# .inp files
ls -1v Jan22/*inp > all_Jan22_inp_files
awk -F'[/.]' 'NR==FNR{a[$1]; next} $2 in a' list_Jan22_status1_files_names all_Jan22_inp_files > selected_Jan22_input_files

# create directories
mkdir Jan22_sel_AM_VOL
mkdir Jan22_sel_PM_VOL
mkdir Jan22_sel_FAT_PCT
mkdir Jan22_sel_PROT_PCT

R CMD BATCH selected_inp_data_Jan22_calcs.R selected_inp_data_Jan22_calcs.R.out

echo "Finish time: $(date)"

exit

