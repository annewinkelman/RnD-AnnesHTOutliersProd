#!/bin/bash

# This uses the data produced by:
# R CMD BATCH selected_inp_data_Jul21_calcs.R selected_inp_data_Jul21_calcs.R.out
# which is run in: selected_inp_data_Jul21_prep.sh

echo "Start time: $(date)"
# AM_VOL
R CMD BATCH AM_VOL_Jul21_outliers.R AM_VOL_Jul21_outliers.R.out
R CMD BATCH AM_VOL_Jul21_outliers_plot.R AM_VOL_Jul21_outliers_plot.R.out

dropbox_uploader.sh upload Jul21_AM_VOL_outliers.pdf HTOutliersProd/Plots/.

# PM_VOL
R CMD BATCH PM_VOL_Jul21_outliers.R PM_VOL_Jul21_outliers.R.out
R CMD BATCH PM_VOL_Jul21_outliers_plot.R PM_VOL_Jul21_outliers_plot.R.out

dropbox_uploader.sh upload Jul21_PM_VOL_outliers.pdf HTOutliersProd/Plots/.

# FAT_PCT
R CMD BATCH FAT_PCT_Jul21_outliers.R FAT_PCT_Jul21_outliers.R.out
R CMD BATCH FAT_PCT_Jul21_outliers_plot.R FAT_PCT_Jul21_outliers_plot.R.out

dropbox_uploader.sh upload Jul21_FAT_PCT_outliers.pdf HTOutliersProd/Plots/.

# PROT_PCT
R CMD BATCH PROT_PCT_Jul21_outliers.R PROT_PCT_Jul21_outliers.R.out
R CMD BATCH PROT_PCT_Jul21_outliers_plot.R PROT_PCT_Jul21_outliers_plot.R.out

dropbox_uploader.sh upload Jul21_PROT_PCT_outliers.pdf HTOutliersProd/Plots/.



echo "Finish time: $(date)"

exit

