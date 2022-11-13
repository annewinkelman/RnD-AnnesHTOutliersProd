# sel_cat <- work_info$PROT_PCT > 0.5 & work_info$abnormal == 0
# NOTE: mincut and maxcut for PROT_PCT
# mincut <- max((minnotout[1,2] - 0.25),0.5)
# maxcut <- maxnotout[1,2] + 0.25

# input data:
# ls -1v Nov21_sel_PROT_PCT/*inp > list_Nov21_sel_PROT_PCT_inp_files
# ls -1v Nov21_sel_PROT_PCT/*stats > list_Nov21_sel_PROT_PCT_stats_files

work_ls_num1_run <- paste0("ls -1v Nov21_sel_PROT_PCT/*inp > list_Nov21_sel_PROT_PCT_inp_files")
work_ls_num2_run <- paste0("ls -1v Nov21_sel_PROT_PCT/*stats > list_Nov21_sel_PROT_PCT_stats_files")


work_ls_num1_run
work_ls_num2_run

system(work_ls_num1_run)
system(work_ls_num2_run)

# read in the list containing the names of the data files
# vars: "AGE_GRP_CD","SSN_CD","CARRY","SAMPLE_REGIME_CD","anmlkey","abnormal","AM_VOL","PM_VOL","FAT_PCT","PROT_PCT","TAG","Contemporary.Group"
flist_data <- read.table("list_Nov21_sel_PROT_PCT_inp_files")
flist_data[1:4,]

ndata_file <- nrow(flist_data)

# read in the list containing the names of the stats files
flist_stats <- read.table("list_Nov21_sel_PROT_PCT_stats_files")
nstats_file <- nrow(flist_stats)
flist_stats[1:5,]

ndata_file
nstats_file

# check lengths
if(ndata_file != nstats_file){
   print(paste("Length Error.  Data N = ", ndata_file," Stats ", nstats_file))
   quit()
   }

# probs
sig<-10^-(3:6) # four levels
prob<-1-0.5*sig #two-sided (multiply by 0.5 )

sig4 <- 10^-6
prob4 <- 1-0.5*sig4 #two-sided (multiply by 0.5 )

# storage
allkeysqt4rpass1 <- c()
allkeysqt4rpass2 <- c()

pass2relax <- c()
twopassoutsum <- c()

# loop
for (ifile in 1:ndata_file){
#for (ifile in 24:24){
     # data (file contains a header)
     start_filename <- flist_data[ifile,]
     print(paste("File ",ifile," Work file ", start_filename))
     work_filename <- do.call(rbind,strsplit(as.character(start_filename),"/", fixed=T))[2]
     work_data <- read.csv(flist_data[ifile,])
     work_data_OUT <- split(work_data, work_data$Contemporary.Group)

     # stats (file contains a header)
     work_stats <- read.csv(flist_stats[ifile,])
     work_stats_OUT <- split(work_stats, work_stats$Contemporary.Group)

     # loop
     for (icgrp in 1:length(work_data_OUT)){

          work_data_sel <- work_data_OUT[[icgrp]]
#	  work_age_grp_cd <- work_data_sel$AGE_GRP_CD
	  work_stats_sel <- work_stats_OUT[[icgrp]]

	  cgnum <- work_data_sel$Contemporary.Group[1]     

	  work_info <- merge(work_data_sel, work_stats_sel)
	  sel_cat <- work_info$PROT_PCT > 0.5 & work_info$abnormal == 0
	  work_info <- work_info[sel_cat,]
	  work_info$file <- work_filename
	  ndata <- nrow(work_info)
	  # pass 1
	  ndata1 <- ndata
     
          work_qt4 <- qt(prob[4],(ndata-1))
	  work_med <- work_info$med[1]
	  work_mad <- work_info$mad[1]

	  # calc so that all valid data are included
	  work_med <- median(work_info$PROT_PCT)
	  work_mad <- mad(work_info$PROT_PCT)

	  work_info$absvalue <- abs(work_info$PROT_PCT - work_med)
	  work_info$maddev <- work_info$absvalue/work_mad
     
          work_info$outlier4 <- ifelse(work_info$maddev > work_qt4,1,0)
     	  # first pass
	  ipass <- 1
	  minnotout <- aggregate(work_info$PROT_PCT, list(work_info$outlier4), min)
	  maxnotout <- aggregate(work_info$PROT_PCT, list(work_info$outlier4), max)
	  # Side-by-side allowances: expand the bounds
	  mincut <- max((minnotout[1,2] - 0.25),0.5)
	  maxcut <- maxnotout[1,2] + 0.25
	  pass1out4 <- work_info$PROT_PCT < mincut | work_info$PROT_PCT > maxcut
	  work_info$outlier4r <- ifelse(pass1out4,1,0)

	  outpos <- which(work_info$outlier4r==1) # relaxed
	  # (Ramvol2passall.in)
	  # keys
	  # These are *** out *** with the first pass
	  if (sum(work_info$outlier4r==1) > 0){
	  workkey1 <- as.data.frame(work_info[outpos,c("file","anmlkey","Contemporary.Group","PROT_PCT")])
	  workkey1$hilo <- ifelse(work_info[outpos,"PROT_PCT"] < work_med,"low","high")
	  workkey1$ndata <- ndata1
	  allkeysqt4rpass1 <- rbind(allkeysqt4rpass1,workkey1)
	  }	
	  # big vs small
	  nsmall4r <- sum(work_info[outpos,"PROT_PCT"] < work_med)
	  nbig4r <- sum(work_info[outpos,"PROT_PCT"] > work_med)
	  # summary: start of CG
	  outsum1 <- cbind.data.frame(work_filename, cgnum, ndata, work_mad, sum(work_info$outlier4), sum(work_info$outlier4r),  nbig4r, nsmall4r)
	  names(outsum1) <- c("file","Contemporary.Group","N","mad","N_outlier4","N_outlier4r","nbig4r","nsmall4r")

	  ipass <- 2
	  # remove records identified as outliers
	  work_data2 <- work_info[!pass1out4,]
	  # RECALCS for reduced data - done CG by CG here
	  ndata2 <- length(work_data2$PROT_PCT)
	  meandata2 <- mean(work_data2$PROT_PCT)
	  # medians
	  work_data2_med <- median(work_data2$PROT_PCT)
	  # MAD default: mult by 1.4826
	  work_data2_mad <- mad(work_data2$PROT_PCT)

	  # Calculate MAD: median(abs(x-6))
	  work_data2$absvalue <- abs(work_data2$PROT_PCT - work_data2_med)
	  work_data2$maddev <- work_data2$absvalue/work_data2_mad
	  # Quantiles
	  work2_qt4 <- qt(prob[4],(ndata2-1))
	  work_data2$outlier4old <- work_data2$outlier4
	  # This is a RECALC - so may have some qt4 outliers already removed
	  work_data2$outlier4 <- ifelse(work_data2$maddev > work2_qt4,1,0)

	  minnotout <- aggregate(work_data2$PROT_PCT, list(work_data2$outlier4), min)
	  maxnotout <- aggregate(work_data2$PROT_PCT, list(work_data2$outlier4), max)

	  mincut <- max((minnotout[1,2] - 0.25),0.5)
	  maxcut <- maxnotout[1,2] + 0.25

	  pass2out4 <- work_data2$PROT_PCT < mincut | work_data2$PROT_PCT > maxcut
	  pass2change <- c(cgnum, sum(work_data2$outlier4), sum(pass2out4))
	  pass2relax <- rbind(pass2relax, pass2change)
	  work_data2$outlier4r <- ifelse(pass2out4, 1, 0)
	  work_data2_med <- median(work_data2$PROT_PCT)
	  outpos <- which(work_data2$outlier4r==1) # relaxed
	  N_final <- ndata2 - sum(pass2out4)

	  # keys out with the second pass
     	  if (sum(work_data2$outlier4r==1) > 0){
              workkey2 <- as.data.frame(work_data2[outpos,c("file","anmlkey","Contemporary.Group","PROT_PCT")])
	      workkey2$hilo <- ifelse(work_data2[outpos,"PROT_PCT"] < work_data2_med,"low","high")
   	      workkey2$ndata <- ndata1 # should be 2?
   	      allkeysqt4rpass2 <- rbind(allkeysqt4rpass2,workkey2)
	 }
	 # big vs small
       	 nsmall <- sum(work_data2[outpos,"PROT_PCT"] < work_data2_med)
       	 nbig <- sum(work_data2[outpos,"PROT_PCT"] > work_data2_med)
	 # summary
         outsum2 <- cbind.data.frame(ndata2, sum(work_data2$outlier4), sum(work_data2$outlier4old == 0 & work_data2$outlier4 == 1), sum(work_data2$outlier4r), nbig, nsmall,N_final)
         names(outsum2) <- c("N2","N2_outlier4","N2_new_outlier4","N2_outlier4r","nbig","nsmall","N_final")
         outsum12 <- cbind(outsum1, outsum2)

         twopassoutsum <- rbind.data.frame(twopassoutsum, outsum12)
    
}

}

twopassoutsum

allkeysqt4rpass1
allkeysqt4rpass2

#
write.csv(twopassoutsum,"Nov21_PROT_PCT_twopassoutsum.csv", row.names=F)

write.csv(allkeysqt4rpass1,"Nov21_PROT_PCT_allkeysqt4rpass1.csv", row.names=F)

if(length(allkeysqt4rpass2) > 0){
   write.csv(allkeysqt4rpass2,"Nov21_PROT_PCT_allkeysqt4rpass2.csv", row.names=F)
   allkeysqt4rpass1$pass <- 1
   allkeysqt4rpass2$pass <- 2
   allkeysqt4rpass12 <- rbind(allkeysqt4rpass1, allkeysqt4rpass2)
   write.csv(allkeysqt4rpass12,"Nov21_PROT_PCT_allkeysqt4rpass12.csv", row.names=F)
   } else {
   # just pass 1 but named as 12
   allkeysqt4rpass1$pass <- 1
   write.csv(allkeysqt4rpass1,"Nov21_PROT_PCT_allkeysqt4rpass12.csv", row.names=F)   
   }

# summary counts

pass1_hilo <- as.data.frame(table(allkeysqt4rpass1$hilo))

pass1_hilo <- cbind(data.frame(pass=1, pass1_hilo))

pass12_hilo <- pass1_hilo

if(length(allkeysqt4rpass2) > 0){
   pass2_hilo <- as.data.frame(table(allkeysqt4rpass2$hilo))
   pass2_hilo <- cbind(data.frame(pass=2, pass2_hilo))
   pass12_hilo <- rbind(pass12_hilo, pass2_hilo)

}
   
write.table(pass12_hilo,"Nov21_PROT_PCT_pass12_hilo.txt", row.names=F)

n_pass1 <- ifelse(length(allkeysqt4rpass1) == 0, 0, nrow(allkeysqt4rpass1))
n_pass2 <- ifelse(length(allkeysqt4rpass2) == 0, 0, nrow(allkeysqt4rpass2))

npass1and2 <- c(n_pass1, n_pass2, n_pass1+n_pass2)

npass1and2_df <- as.data.frame(npass1and2)
names(npass1and2_df) <- "N"

npass1and2_df <- data.frame(cbind(Pass=c("1","2","All"), npass1and2_df))

write.table(npass1and2_df,"Nov21_PROT_PCT_outlier_cnt.txt", row.names=F)

# NQXD20210124000000001.inp

quit("no")

