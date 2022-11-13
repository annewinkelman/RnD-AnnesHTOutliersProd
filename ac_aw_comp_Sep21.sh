#!/bin/bash

echo "Start time: $(date)"

parentdir=/data/ls/anwin0/HTOutliersProd/

Sep21_outdir=/data/ls/anwin0/HTOutliersProd/Sep21/outputs/

cd $Sep21_outdir

# AM_VOL
awk -F, '$15 > 0 && $15 < 9{ print FILENAME "," $0 }' *.out > Sep21_AM_VOL_outliers_AC.csv
cp Sep21_AM_VOL_outliers_AC.csv $parentdir

# PM_VOL
awk -F, '$14 > 0 && $14 < 9{ print FILENAME "," $0 }' *.out > Sep21_PM_VOL_outliers_AC.csv
cp Sep21_PM_VOL_outliers_AC.csv $parentdir

# FAT_PCT
awk -F, '$16 > 0 && $16 < 9{ print FILENAME "," $0 }' *.out > Sep21_FAT_PCT_outliers_AC.csv
cp Sep21_FAT_PCT_outliers_AC.csv $parentdir

# PROT_PCT
awk -F, '$17 > 0 && $17 < 9{ print FILENAME "," $0 }' *.out > Sep21_PROT_PCT_outliers_AC.csv
cp Sep21_PROT_PCT_outliers_AC.csv $parentdir

cd $parentdir

# run the R scripts
R CMD BATCH Sep21_comp_AM_VOL_AC_vs_AW.R Sep21_comp_AM_VOL_AC_vs_AW.R.out
R CMD BATCH Sep21_comp_PM_VOL_AC_vs_AW.R Sep21_comp_PM_VOL_AC_vs_AW.R.out
R CMD BATCH Sep21_comp_FAT_PCT_AC_vs_AW.R Sep21_comp_FAT_PCT_AC_vs_AW.R.out
R CMD BATCH Sep21_comp_PROT_PCT_AC_vs_AW.R Sep21_comp_PROT_PCT_AC_vs_AW.R.out



echo "Finish time: $(date)"

exit

