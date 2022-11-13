#!/bin/bash

echo "Start time: $(date)"

parentdir=/data/ls/anwin0/HTOutliersProd/

Jun21_outdir=/data/ls/anwin0/HTOutliersProd/Jun21/outputs/

cd $Jun21_outdir

# AM_VOL
awk -F, '$15 > 0 && $15 < 9{ print FILENAME "," $0 }' *.out > Jun21_AM_VOL_outliers_AC.csv
cp Jun21_AM_VOL_outliers_AC.csv $parentdir

# PM_VOL
awk -F, '$14 > 0 && $14 < 9{ print FILENAME "," $0 }' *.out > Jun21_PM_VOL_outliers_AC.csv
cp Jun21_PM_VOL_outliers_AC.csv $parentdir

# FAT_PCT
awk -F, '$16 > 0 && $16 < 9{ print FILENAME "," $0 }' *.out > Jun21_FAT_PCT_outliers_AC.csv
cp Jun21_FAT_PCT_outliers_AC.csv $parentdir

# PROT_PCT
awk -F, '$17 > 0 && $17 < 9{ print FILENAME "," $0 }' *.out > Jun21_PROT_PCT_outliers_AC.csv
cp Jun21_PROT_PCT_outliers_AC.csv $parentdir

cd $parentdir

# run the R scripts
R CMD BATCH Jun21_comp_AM_VOL_AC_vs_AW.R Jun21_comp_AM_VOL_AC_vs_AW.R.out
R CMD BATCH Jun21_comp_PM_VOL_AC_vs_AW.R Jun21_comp_PM_VOL_AC_vs_AW.R.out
R CMD BATCH Jun21_comp_FAT_PCT_AC_vs_AW.R Jun21_comp_FAT_PCT_AC_vs_AW.R.out
R CMD BATCH Jun21_comp_PROT_PCT_AC_vs_AW.R Jun21_comp_PROT_PCT_AC_vs_AW.R.out



echo "Finish time: $(date)"

exit

