#!/bin/bash
# from: annotate_protein_genes_rohFinfo.sh but loops over all descriptions in that had a frequency of >= 100 (across all chromosomes)
# uses this R script: annotate_chrnumx_sel100_descy_genex_fracF.R

# NOTE: the individual chr num is NOT included in the file names.  All files have the same names.  The directories have the chr number.

echo "Start time: $(date)"
# list of selected descriptions
mapfile -t linearray < <(awk '{print $1}' annotate_all_chrnum_gene_chr_desc_final.txt)
mapfile -t descarray < <(awk '{print $2}' annotate_all_chrnum_gene_chr_desc_final.txt)

nlines=${#linearray[@]}

echo "There are $nlines lines in the selected annotated genes file"

MYSPACE=' '

# a bit long
for (( i=0; i<$nlines; i++ )); do echo "${linearray[$i]} ${descarray[$i]}" ; done

# how many in each chromosome
awk '{count[$1]++} END {for (key in count) print key, count[key]}' annotate_all_chrnum_gene_chr_desc_final.txt > annotate_all_chrnum_gene_chr_desc_final_totals.txt

mapfile -t chrarray < <(awk '{print $1}' annotate_all_chrnum_gene_chr_desc_final_totals.txt)
nchrs=${#chrarray[@]}

# get the description number - some are missing
mapfile -t countarray < <(awk '{print $2}' annotate_all_chrnum_gene_chr_desc_final_totals.txt)
nchrs=${#countarray[@]}

echo "There are $nchrs chromosomes in the selected annotated genes file"

for (( i=0; i<$nchrs; i++ )); do echo "${chrarray[$i]} ${countarray[$i]}" ; done


# directory of imputed data

# start of directory where the results will go
parentdir=/data/ls/anwin0/genomicinbreeding/

# next part of directory for the output
outbase=hdplusfilledgschr

# across chrs file
# printf "%s %s %s %s %s %s %s %s\n" "chrnum,linenum,start_pos,end_pos,Gene,Name,biotype,description" >  annotate_all_chrnum_gene_more_info.csv

# don't need the chr because they are in separate directories

placeholder="[1] 0000-00-00 00:00:00 NZST"
error_count=0

# if starting in the first directory
ifile=0
# starting from a different directory
#ifile=1

iline=0

while [ $ifile -lt $nchrs ]; do
#while [ $ifile -lt 2 ]; do 
	echo "ifile ${ifile}"
	filenum=${chrarray[$ifile]}
	echo "Start chromosome ${filenum}. Time  $(date)"
	outdir="${parentdir}${outbase}${filenum}"
	cd $outdir
	echo "In ${PWD}. Time  $(date)"

	ndesc=${countarray[$ifile]}
        idesc=0
	while [ $idesc -lt $ndesc ]; do
	    work_desc=${descarray[$iline]}
	    let iline++
	# now do a loop within each chromosome (i.e. loop over all the annotated genes within a given description
	# the is 1 (i.e. the number) NOT l (the letter)
	#    genearray=(`ls -1v annotate_sel100_desc${work_desc}_gene*pos.txt`)
	    ls -1v annotate_sel100_desc${work_desc}_gene*pos.txt > work_array
 	    genearray=(`awk -F_ '{print $4}' work_array | awk '{text=$0; gsub(/gene/,"",text); print text}'`)
	    
	    genelen=${#genearray[*]}
	    echo "There are $genelen annotated gene files in description ${work_desc} of chr ${filenum}"

	igene=0

	while [ $igene -lt $genelen ]; do
	    genenum=${genearray[$igene]}
	    echo "Chromosome ${filenum} Description $work_desc Gene $genenum"
	    let igene++	    
	done
	    
	    let idesc++
	done
	echo "Chr ${filenum} Finish Test Time  $(date) "

	cd $parentdir
	
       let ifile++	

done

echo "Finish time: $(date)"

exit

