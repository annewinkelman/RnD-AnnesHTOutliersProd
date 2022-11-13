#!/bin/bash

echo "Start time: $(date)"

parentdir=/data/ls/anwin0/HTOutliersProd/

Dec21_outdir=/data/ls/anwin0/HTOutliersProd/Dec21/outputs/

cd $Dec21_outdir

echo "Extract outliers from Arnold's data. time: $(date)"

# AM_VOL
awk -F, '$15 > 0 && $15 < 9{ print FILENAME "," $0 }' *.out > Dec21_AM_VOL_outliers_AC.csv
cp Dec21_AM_VOL_outliers_AC.csv $parentdir

# PM_VOL
awk -F, '$14 > 0 && $14 < 9{ print FILENAME "," $0 }' *.out > Dec21_PM_VOL_outliers_AC.csv
cp Dec21_PM_VOL_outliers_AC.csv $parentdir

# FAT_PCT
awk -F, '$16 > 0 && $16 < 9{ print FILENAME "," $0 }' *.out > Dec21_FAT_PCT_outliers_AC.csv
cp Dec21_FAT_PCT_outliers_AC.csv $parentdir

# PROT_PCT
awk -F, '$17 > 0 && $17 < 9{ print FILENAME "," $0 }' *.out > Dec21_PROT_PCT_outliers_AC.csv
cp Dec21_PROT_PCT_outliers_AC.csv $parentdir

cd $parentdir

echo "Start R scripts. time: $(date)"

# run the R scripts
R CMD BATCH Dec21_comp_AM_VOL_AC_vs_AW.R Dec21_comp_AM_VOL_AC_vs_AW.R.out
echo "Finish AM_VOL. time: $(date)"

R CMD BATCH Dec21_comp_PM_VOL_AC_vs_AW.R Dec21_comp_PM_VOL_AC_vs_AW.R.out
echo "Finish PM_VOL. time: $(date)"

R CMD BATCH Dec21_comp_FAT_PCT_AC_vs_AW.R Dec21_comp_FAT_PCT_AC_vs_AW.R.out
echo "Finish FAT_PCT. time: $(date)"

R CMD BATCH Dec21_comp_PROT_PCT_AC_vs_AW.R Dec21_comp_PROT_PCT_AC_vs_AW.R.out
echo "Finish PROT_PCT. time: $(date)"

echo "Finish R scripts. time: $(date)"

# To see summary results:
more Dec21_comp_*_AC_vs_AW_counts.txt

echo "Finish time: $(date)"

exit

