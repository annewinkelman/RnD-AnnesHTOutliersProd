#!/bin/bash

echo "Start time: $(date)"
# AM_VOL
R CMD BATCH AM_VOL_Jan22_outliers.R AM_VOL_Jan22_outliers.R.out
R CMD BATCH AM_VOL_Jan22_outliers_plot.R AM_VOL_Jan22_outliers_plot.R.out

dropbox_uploader.sh upload Jan22_AM_VOL_outliers.pdf HTOutliersProd/Plots/.

echo "Finishd AM_VOL: $(date)"

# PM_VOL
R CMD BATCH PM_VOL_Jan22_outliers.R PM_VOL_Jan22_outliers.R.out
R CMD BATCH PM_VOL_Jan22_outliers_plot.R PM_VOL_Jan22_outliers_plot.R.out

dropbox_uploader.sh upload Jan22_PM_VOL_outliers.pdf HTOutliersProd/Plots/.

echo "Finishd PM_VOL: $(date)"

# FAT_PCT
R CMD BATCH FAT_PCT_Jan22_outliers.R FAT_PCT_Jan22_outliers.R.out
R CMD BATCH FAT_PCT_Jan22_outliers_plot.R FAT_PCT_Jan22_outliers_plot.R.out

dropbox_uploader.sh upload Jan22_FAT_PCT_outliers.pdf HTOutliersProd/Plots/.

echo "Finishd FAT_PCT: $(date)"

# PROT_PCT
R CMD BATCH PROT_PCT_Jan22_outliers.R PROT_PCT_Jan22_outliers.R.out
R CMD BATCH PROT_PCT_Jan22_outliers_plot.R PROT_PCT_Jan22_outliers_plot.R.out

dropbox_uploader.sh upload Jan22_PROT_PCT_outliers.pdf HTOutliersProd/Plots/.

echo "Finishd PROT_PCT: $(date)"

echo "Finish time: $(date)"

exit

