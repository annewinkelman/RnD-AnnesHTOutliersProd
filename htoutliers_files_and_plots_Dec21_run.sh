#!/bin/bash

echo "Start time: $(date)"
# AM_VOL
R CMD BATCH AM_VOL_Dec21_outliers.R AM_VOL_Dec21_outliers.R.out
R CMD BATCH AM_VOL_Dec21_outliers_plot.R AM_VOL_Dec21_outliers_plot.R.out

dropbox_uploader.sh upload Dec21_AM_VOL_outliers.pdf HTOutliersProd/Plots/.

echo "Finishd AM_VOL: $(date)"

# PM_VOL
R CMD BATCH PM_VOL_Dec21_outliers.R PM_VOL_Dec21_outliers.R.out
R CMD BATCH PM_VOL_Dec21_outliers_plot.R PM_VOL_Dec21_outliers_plot.R.out

dropbox_uploader.sh upload Dec21_PM_VOL_outliers.pdf HTOutliersProd/Plots/.

echo "Finishd PM_VOL: $(date)"

# FAT_PCT
R CMD BATCH FAT_PCT_Dec21_outliers.R FAT_PCT_Dec21_outliers.R.out
R CMD BATCH FAT_PCT_Dec21_outliers_plot.R FAT_PCT_Dec21_outliers_plot.R.out

dropbox_uploader.sh upload Dec21_FAT_PCT_outliers.pdf HTOutliersProd/Plots/.

echo "Finishd FAT_PCT: $(date)"

# PROT_PCT
R CMD BATCH PROT_PCT_Dec21_outliers.R PROT_PCT_Dec21_outliers.R.out
R CMD BATCH PROT_PCT_Dec21_outliers_plot.R PROT_PCT_Dec21_outliers_plot.R.out

dropbox_uploader.sh upload Dec21_PROT_PCT_outliers.pdf HTOutliersProd/Plots/.

echo "Finishd PROT_PCT: $(date)"

echo "Finish time: $(date)"

exit

