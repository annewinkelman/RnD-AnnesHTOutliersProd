Sys.time()

#args=(commandArgs(TRUE))
#args



# vars: AGE_GRP_CD, SSN_CD, CARRY, SAMPLE_REGIME_CD, anmlkey, abnormal, PM_VOL, AM_VOL, FAT_PCT, PROT_PCT, TAG
#2,1,0,2,039931159,00,00.0,11.2,03.95,03.29,1100
#2,1,0,2,040655283,00,00.0,10.0,04.40,03.59,1102
#2,1,0,2,039904246,00,00.0,09.1,05.19,03.81,1104

work_infile <- "Jun21/HXKW20210412000000001.inp"

#work_infile <- args

work_infile

split_name <- list(strsplit(as.character(work_infile), split="[/|,.]")[[1]])

split_name_file <- do.call(rbind,split_name)

split_name_file

work_dir <- split_name_file[1]
work_file_prefix <- split_name_file[2]

ht_data <- read.csv(work_infile, header=F)
names(ht_data) <- c("AGE_GRP_CD","SSN_CD","CARRY", "SAMPLE_REGIME_CD","anmlkey","abnormal","PM_VOL","AM_VOL","FAT_PCT","PROT_PCT","TAG")
nrow(ht_data)

ht_cols <- c("AGE_GRP_CD","SSN_CD","CARRY", "SAMPLE_REGIME_CD")

ht_data$Contemporary.Group <- apply(ht_data[ ,ht_cols] , 1 , paste , collapse = "-" )

ht_data[1:10,]

OUT_HT <- split(ht_data, ht_data$Contemporary.Group)

length(OUT_HT)

# loop to select cgs
all_sel_cgrps <- c()
all_sel_cgrps_nrec <- c()
all_sel_age <- c()
all_am_present <- c()
all_pm_present <- c()

all_run_info <- c()

# min valus:
# pm_vol: 1.5
# am_vol: 1.5
# fat_pct: 0.5
# prot_pct: 0.5

for (icgrp in 1:length(OUT_HT)){
    work_data <- OUT_HT[[icgrp]]
    work_nrec <- nrow(work_data)
    work_age <- work_data$AGE_GRP_CD[1]
    # check the data:
    # vol > 1.5
    # abnormal code removed
    # maybe am-only or pm-only and don't want to delete the other records
    am_present <- !(sum(work_data$AM_VOL == 0.0) == work_nrec)
    pm_present <- !(sum(work_data$PM_VOL == 0.0) == work_nrec)
    work_am_vol_min_cat <- work_data$AM_VOL <= 1.5
    work_pm_vol_min_cat <- work_data$PM_VOL <= 1.5
    work_fat_pct_min_cat <- work_data$FAT_PCT <= 0.5
    work_prot_pct_min_cat <- work_data$PROT_PCT <= 0.5

    if(am_present & !pm_present){
        work_all_min_cat <- work_am_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else if (pm_present & !am_present) {
        work_all_min_cat <- work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else {
        work_all_min_cat <- work_am_vol_min_cat | work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    }
    work_abnormal_cat <- work_data$abnormal > 0
    work_data_sel <- work_data[!work_all_min_cat & !work_abnormal_cat,]
    work_nrec_update <- nrow(work_data_sel)
    work_run_info <- paste("icgrp ",icgrp," N recs ",work_nrec," Update N recs ",work_nrec_update)
    all_run_info <- rbind(all_run_info, work_run_info)
    print(paste("icgrp ",icgrp," N recs ",work_nrec," Update N recs ",work_nrec_update))
    if(work_nrec_update >= 20){
    
       work_sel_cgrp <- work_data[1,"Contemporary.Group"]
       work_sel_cgrp_nrec <- work_nrec_update
       all_sel_cgrps <- c(all_sel_cgrps, work_sel_cgrp)
       all_sel_cgrps_nrec <- c(all_sel_cgrps_nrec, work_sel_cgrp_nrec)
       all_sel_age <- c(all_sel_age, work_age)
       all_am_present <- c(all_am_present, sum(am_present))
       all_pm_present <- c(all_pm_present, sum(pm_present))       
       }

}

all_sel_cgrps

if (length(all_sel_cgrps) == 0){
    work_quit_file <- paste0(work_dir,"-",work_file_prefix,"-outlier_nobs_quit.txt")
    write.table(all_run_info,work_quit_file, row.names=F, col.names=F)
    end.time <- Sys.time()
    end.time
    quit()

}


all_sel_cgrps_df <- cbind.data.frame(all_sel_cgrps, all_sel_cgrps_nrec, all_sel_age, all_am_present, all_pm_present)

names(all_sel_cgrps_df) <- c("Contemporary.Group","nrec","age", "am_present","pm_present")

all_sel_cgrps_df

sum(all_sel_cgrps_df$nrec)


# now calculate the statistics within each CG

# significance
sig4 <- 10^-6
prob4 <- 1-0.5*sig4 #two-sided (multiply by 0.5 )

# loop function

loop_seq <- function(start,end) {
    if(end<start) return(integer(0))
    seq(start, end)
}

# this selects on contemporary group but does NOT get rid of the values that are below the cut-off point
cgrp_sel_cat <- ht_data$Contemporary.Group %in% all_sel_cgrps_df$Contemporary.Group
table(cgrp_sel_cat)

# work with this data
ht_data_sel <- ht_data[cgrp_sel_cat,]

ht_data_sel[1:4,]

# still need to expunge values below the cut-off point so they don't influence the outlier calcs
# this is done within the loop for each trait
# BUT still have AM-ONLY and PM_ONLY so don't want to zap the entire CG

# want to skip pm if am-only or am if pm-only

# loop for AM_VOL
am_present_cat <- all_sel_cgrps_df$am_present == 1

sel_am_present <- all_sel_cgrps_df[am_present_cat,]

am_ht_sel_cat <- ht_data_sel$Contemporary.Group %in% sel_am_present$Contemporary.Group

ht_data_sel_am_vol <- ht_data_sel[am_ht_sel_cat,]

if(nrow(ht_data_sel_am_vol) > 0){
   OUT4 <- split(ht_data_sel_am_vol, ht_data_sel_am_vol$Contemporary.Group)
   } else {
   OUT4 <- vector(mode="numeric", length=0)
   }

length(OUT4)

# all_sel_cgrps, all_N, all_age
all_sel_cgrps <- c()
all_N <- c()
all_age <- c()
all_am_mad_calc <- c()
all_am_out4_cnt <- c()

# only cgs that passed initial checks
for (ic in loop_seq(1,length(OUT4))){
    work_data <- OUT4[[ic]]
    work_nrec <- nrow(work_data)
    # get rid of zero values and abnormal codes
    # do this for ALL the traits so the nrec will be the same for all files
    am_present <- !(sum(work_data$AM_VOL == 0.0) == work_nrec)
    pm_present <- !(sum(work_data$PM_VOL == 0.0) == work_nrec)
    work_am_vol_min_cat <- work_data$AM_VOL <= 1.5
    work_pm_vol_min_cat <- work_data$PM_VOL <= 1.5
    work_fat_pct_min_cat <- work_data$FAT_PCT <= 0.5
    work_prot_pct_min_cat <- work_data$PROT_PCT <= 0.5

    if(am_present & !pm_present){
        work_all_min_cat <- work_am_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else if (pm_present & !am_present) {
        work_all_min_cat <- work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else {
        work_all_min_cat <- work_am_vol_min_cat | work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    }
    work_abnormal_cat <- work_data$abnormal > 0
    work_data <- work_data[!work_all_min_cat & !work_abnormal_cat,]
    # Stats on cg data
    work_age <- work_data$AGE_GRP_CD[1]
    work_n <- nrow(work_data)	
    work_qt4 <- qt(prob4,(work_n-1))
    work_mad <- mad(work_data$AM_VOL)
    work_med <- median(work_data$AM_VOL)
    work_cgs <- work_data$Contemporary.Group[1]
    work_mad_calc <- cbind.data.frame(work_cgs, work_qt4, work_mad, work_med)
    all_am_mad_calc <- rbind(all_am_mad_calc, work_mad_calc)

    # mad calc stats

    work_data$qt4 <- work_qt4
    work_data$mad <- work_mad
    work_data$med <- work_med

    # add to data
    work_data$absvalue <- abs(work_data$AM_VOL - work_data$med)	
    work_data$maddev <- work_data$absvalue/work_data$mad
    work_data$outlier4 <- ifelse(work_data$maddev > work_qt4,1,0)

    # cg info
    all_sel_cgrps <- c(all_sel_cgrps, work_cgs)

    all_N <- c(all_N, work_n)

    all_age <- c(all_age, work_age)

    # outlier count
    all_am_out4_cnt <- c(all_am_out4_cnt, sum(work_data$outlier4))

}

all_sel_cgrps

if(length(OUT4) > 0){
   am_vol_pass1_sum <- cbind.data.frame(all_sel_cgrps, all_N, all_age, all_am_out4_cnt)
   names(am_vol_pass1_sum)[1:3] <- c("Contemporary.Group","nrec","age")
   names(all_am_mad_calc) <- c("Contemporary.Group","AM_VOL_qt4","AM_VOL_mad","AM_VOL_med")   
} else {
  # all_sel_cgrps all_N all_age
  all_am_out4_cnt <- rep(NA, nrow(all_sel_cgrps_df)) # need the df here - the vector gets reset for each trait
  am_vol_pass1_sum <- cbind(all_sel_cgrps_df[,c("Contemporary.Group","nrec","age")], all_am_out4_cnt)
  all_am_mad_calc <- cbind.data.frame(all_sel_cgrps_df[,c("Contemporary.Group")], all_am_out4_cnt, all_am_out4_cnt, all_am_out4_cnt)
  names(all_am_mad_calc) <- c("Contemporary.Group","AM_VOL_qt4","AM_VOL_mad","AM_VOL_med")  
}

am_vol_pass1_sum

all_am_mad_calc
#   work_cgs work_qt4 work_mad work_med
#1  2-1-0-2 5.269581  1.48260     8.90
#2  3-1-0-2 5.699116  1.70499     9.90
#3  4-1-0-2 5.448948  2.96520    11.40

# loop for PM_VOL
pm_present_cat <- all_sel_cgrps_df$pm_present == 1

sel_pm_present <- all_sel_cgrps_df[pm_present_cat,]

pm_ht_sel_cat <- ht_data_sel$Contemporary.Group %in% sel_pm_present$Contemporary.Group

ht_data_sel_pm_vol <- ht_data_sel[pm_ht_sel_cat,]

if(nrow(ht_data_sel_pm_vol) > 0){
   OUT4 <- split(ht_data_sel_pm_vol, ht_data_sel_pm_vol$Contemporary.Group)
   } else {
   OUT4 <- vector(mode="numeric", length=0)
   }

length(OUT4)

# all_sel_cgrps, all_N, all_age
all_sel_cgrps <- c()
all_N <- c()
all_age <- c()
all_pm_mad_calc <- c()
all_pm_out4_cnt <- c()


# only cgs that passed initial checks
for (ic in loop_seq(1,length(OUT4))){
    work_data <- OUT4[[ic]]
    # get rid of zero values and abnormal codes
    work_nrec <- nrow(work_data)
    # do this for ALL the traits so the nrec will be the same for all files
    am_present <- !(sum(work_data$AM_VOL == 0.0) == work_nrec)
    pm_present <- !(sum(work_data$PM_VOL == 0.0) == work_nrec)
    work_am_vol_min_cat <- work_data$AM_VOL <= 1.5
    work_pm_vol_min_cat <- work_data$PM_VOL <= 1.5
    work_fat_pct_min_cat <- work_data$FAT_PCT <= 0.5
    work_prot_pct_min_cat <- work_data$PROT_PCT <= 0.5

    if(am_present & !pm_present){
        work_all_min_cat <- work_am_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else if (pm_present & !am_present) {
        work_all_min_cat <- work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else {
        work_all_min_cat <- work_am_vol_min_cat | work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    }
    work_abnormal_cat <- work_data$abnormal > 0
    work_data <- work_data[!work_all_min_cat & !work_abnormal_cat,]
    # Stats on cg data
    work_age <- work_data$AGE_GRP_CD[1]
    work_n <- nrow(work_data)	
    work_qt4 <- qt(prob4,(work_n-1))
    work_mad <- mad(work_data$PM_VOL)
    work_med <- median(work_data$PM_VOL)
    work_cgs <- work_data$Contemporary.Group[1]
    work_mad_calc <- cbind.data.frame(work_cgs, work_qt4, work_mad, work_med)
    all_pm_mad_calc <- rbind(all_pm_mad_calc, work_mad_calc)

    # mad calc stats

    work_data$qt4 <- work_qt4
    work_data$mad <- work_mad
    work_data$med <- work_med

    # add to data
    work_data$absvalue <- abs(work_data$PM_VOL - work_data$med)	
    work_data$maddev <- work_data$absvalue/work_data$mad
    work_data$outlier4 <- ifelse(work_data$maddev > work_qt4,1,0)

    # cg info
    all_sel_cgrps <- c(all_sel_cgrps, work_cgs)

    all_N <- c(all_N, work_n)

    all_age <- c(all_age, work_age)

    # outlier count
    all_pm_out4_cnt <- c(all_pm_out4_cnt, sum(work_data$outlier4))

}


if(length(OUT4) > 0){
   pm_vol_pass1_sum <- cbind.data.frame(all_sel_cgrps, all_N, all_age, all_pm_out4_cnt)
   names(pm_vol_pass1_sum)[1:3] <- c("Contemporary.Group","nrec","age")
   names(all_pm_mad_calc) <- c("Contemporary.Group","PM_VOL_qt4","PM_VOL_mad","PM_VOL_med")      
} else {
  # all_sel_cgrps all_N all_age
  all_pm_out4_cnt <- rep(NA, nrow(all_sel_cgrps_df))
  pm_vol_pass1_sum <- cbind.data.frame(all_sel_cgrps_df[,c("Contemporary.Group","nrec","age")], all_pm_out4_cnt)
  all_pm_mad_calc <- cbind.data.frame(all_sel_cgrps_df[,c("Contemporary.Group")], all_pm_out4_cnt, all_pm_out4_cnt, all_pm_out4_cnt)
  names(all_pm_mad_calc) <- c("Contemporary.Group","PM_VOL_qt4","PM_VOL_mad","PM_VOL_med")
}

is.numeric(all_pm_out4_cnt)

pm_vol_pass1_sum



# FAT_PCT
OUT4 <- split(ht_data_sel, ht_data_sel$Contemporary.Group)

# all_sel_cgrps, all_N, all_age
all_sel_cgrps <- c()
all_N <- c()
all_age <- c()
all_fat_pct_mad_calc <- c()
all_fat_pct_out4_cnt <- c()

# only cgs that passed initial checks
for (ic in loop_seq(1,length(OUT4))){
    work_data <- OUT4[[ic]]
    # get rid of zero values and abnormal codes
    work_nrec <- nrow(work_data)
    # do this for ALL the traits so the nrec will be the same for all files
    am_present <- !(sum(work_data$AM_VOL == 0.0) == work_nrec)
    pm_present <- !(sum(work_data$PM_VOL == 0.0) == work_nrec)
    work_am_vol_min_cat <- work_data$AM_VOL <= 1.5
    work_pm_vol_min_cat <- work_data$PM_VOL <= 1.5
    work_fat_pct_min_cat <- work_data$FAT_PCT <= 0.5
    work_prot_pct_min_cat <- work_data$PROT_PCT <= 0.5

    if(am_present & !pm_present){
        work_all_min_cat <- work_am_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else if (pm_present & !am_present) {
        work_all_min_cat <- work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else {
        work_all_min_cat <- work_am_vol_min_cat | work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    }
    work_abnormal_cat <- work_data$abnormal > 0
    work_data <- work_data[!work_all_min_cat & !work_abnormal_cat,]
    # Stats on cg data
    work_age <- work_data$AGE_GRP_CD[1]
    work_n <- nrow(work_data)	
    work_qt4 <- qt(prob4,(work_n-1))
    work_mad <- mad(work_data$FAT_PCT)
    work_med <- median(work_data$FAT_PCT)
    work_cgs <- work_data$Contemporary.Group[1]
    print(paste("fat ic ",ic, work_age, work_n, work_qt4, work_mad, work_med, work_cgs))
    work_mad_calc <- cbind.data.frame(work_cgs, work_qt4, work_mad, work_med)
    all_fat_pct_mad_calc <- rbind(all_fat_pct_mad_calc, work_mad_calc)

    # mad calc stats

    work_data$qt4 <- work_qt4
    work_data$mad <- work_mad
    work_data$med <- work_med

    # add to data
    work_data$absvalue <- abs(work_data$FAT_PCT - work_data$med)	
    work_data$maddev <- work_data$absvalue/work_data$mad
    work_data$outlier4 <- ifelse(work_data$maddev > work_qt4,1,0)

    # cg info
    all_sel_cgrps <- c(all_sel_cgrps, work_cgs)

    all_N <- c(all_N, work_n)

    all_age <- c(all_age, work_age)

    # outlier count
    all_fat_pct_out4_cnt <- c(all_fat_pct_out4_cnt, sum(work_data$outlier4))

}

fat_pct_pass1_sum <- cbind.data.frame(all_sel_cgrps, all_N, all_age, all_fat_pct_out4_cnt)
names(fat_pct_pass1_sum)[1:3] <- c("Contemporary.Group","nrec","age")
fat_pct_pass1_sum

names(all_fat_pct_mad_calc) <- c("Contemporary.Group","FAT_PCT_qt4","FAT_PCT_mad","FAT_PCT_med")      

all_fat_pct_mad_calc

# PROT_PCT
OUT4 <- split(ht_data_sel, ht_data_sel$Contemporary.Group)

# all_sel_cgrps, all_N, all_age
all_sel_cgrps <- c()
all_N <- c()
all_age <- c()
all_prot_pct_mad_calc <- c()
all_prot_pct_out4_cnt <- c()

# only cgs that passed initial checks
for (ic in loop_seq(1,length(OUT4))){
    work_data <- OUT4[[ic]]
    # get rid of zero values and abnormal codes
    work_nrec <- nrow(work_data)
    # do this for ALL the traits so the nrec will be the same for all files
    am_present <- !(sum(work_data$AM_VOL == 0.0) == work_nrec)
    pm_present <- !(sum(work_data$PM_VOL == 0.0) == work_nrec)
    work_am_vol_min_cat <- work_data$AM_VOL <= 1.5
    work_pm_vol_min_cat <- work_data$PM_VOL <= 1.5
    work_fat_pct_min_cat <- work_data$FAT_PCT <= 0.5
    work_prot_pct_min_cat <- work_data$PROT_PCT <= 0.5

    if(am_present & !pm_present){
        work_all_min_cat <- work_am_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else if (pm_present & !am_present) {
        work_all_min_cat <- work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else {
        work_all_min_cat <- work_am_vol_min_cat | work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    }
    work_abnormal_cat <- work_data$abnormal > 0
    work_data <- work_data[!work_all_min_cat & !work_abnormal_cat,]
    # Stats on cg data
    work_age <- work_data$AGE_GRP_CD[1]
    work_n <- nrow(work_data)	
    work_qt4 <- qt(prob4,(work_n-1))
    work_mad <- mad(work_data$PROT_PCT)
    work_med <- median(work_data$PROT_PCT)
    work_cgs <- work_data$Contemporary.Group[1]
    work_mad_calc <- cbind.data.frame(work_cgs, work_qt4, work_mad, work_med)
    all_prot_pct_mad_calc <- rbind(all_prot_pct_mad_calc, work_mad_calc)

    # mad calc stats

    work_data$qt4 <- work_qt4
    work_data$mad <- work_mad
    work_data$med <- work_med

    # add to data
    work_data$absvalue <- abs(work_data$PROT_PCT - work_data$med)	
    work_data$maddev <- work_data$absvalue/work_data$mad
    work_data$outlier4 <- ifelse(work_data$maddev > work_qt4,1,0)

    # cg info
    all_sel_cgrps <- c(all_sel_cgrps, work_cgs)

    all_N <- c(all_N, work_n)

    all_age <- c(all_age, work_age)

    # outlier count
    all_prot_pct_out4_cnt <- c(all_prot_pct_out4_cnt, sum(work_data$outlier4))

}

prot_pct_pass1_sum <- cbind.data.frame(all_sel_cgrps, all_N, all_age, all_prot_pct_out4_cnt)
names(prot_pct_pass1_sum)[1:3] <- c("Contemporary.Group","nrec","age")

names(all_prot_pct_mad_calc) <- c("Contemporary.Group","PROT_PCT_qt4","PROT_PCT_mad","PROT_PCT_med")      
all_prot_pct_mad_calc


am_vol_pass1_sum
pm_vol_pass1_sum
fat_pct_pass1_sum
prot_pct_pass1_sum

library(dplyr)
library(tidyverse)

is.numeric(all_am_out4_cnt)
is.numeric(all_prot_pct_out4_cnt)
is.numeric(all_fat_pct_out4_cnt)
is.numeric(all_prot_pct_out4_cnt)

am_vol_pass1_sum
pm_vol_pass1_sum
fat_pct_pass1_sum
prot_pct_pass1_sum

all_pass1_sum <- list(am_vol_pass1_sum, pm_vol_pass1_sum, fat_pct_pass1_sum, prot_pct_pass1_sum) %>% reduce(full_join, by = c("Contemporary.Group","nrec","age"))

all_pass1_sum

is.numeric(all_pass1_sum$all_pass1_sum$all_am_out4_cnt)
is.numeric(all_pass1_sum$all_pass1_sum$all_pm_out4_cnt)
is.numeric(all_pass1_sum$all_fat_pct_out4_cnt)
is.numeric(all_pass1_sum$all_prot_pct_out4_cnt)

all_am_mad_calc
all_pm_mad_calc
all_fat_pct_mad_calc
all_prot_pct_mad_calc

all_mad_calc <- list(all_am_mad_calc, all_pm_mad_calc, all_fat_pct_mad_calc, all_prot_pct_mad_calc) %>% reduce(full_join, by = c("Contemporary.Group"))

all_mad_calc

# check for the presence of outliers

is.numeric(all_am_out4_cnt)
is.numeric(all_fat_pct_out4_cnt)

all_out4_df <- all_pass1_sum[,c("all_am_out4_cnt","all_pm_out4_cnt","all_fat_pct_out4_cnt","all_prot_pct_out4_cnt")]

all_out4_df

is.na(all_out4_df)

all_pass1_sum$all_out4 <- rowSums(all_out4_df, na.rm=T)

all_pass1_sum

# write out the data
# 1. all selected cgs (excludes those that didn'y have enough valid animals)
#    a) all counts
#    b) all mad calcs
work_outlier_cnt_file <- paste0(work_dir,"-",work_file_prefix,"-outlier_cnts.csv")

work_outlier_stat_file <- paste0(work_dir,"-",work_file_prefix,"-outlier_stats.csv")

work_outlier_cnt_file
work_outlier_stat_file

quit("yes")

write.csv(all_pass1_sum, work_outlier_cnt_file, row.names=F)
write.csv(all_mad_calc,work_outlier_stat_file, row.names=F)

# 2. cgs with ANY outliers whatsoever: just the file names (which can be matched to the big list and used for the remaining steps of the process)
#

work_outlier_status <- ifelse(sum(all_pass1_sum$all_out4) > 0,1,0)

if(work_outlier_status == 1){
   work_outlier_status_file <- paste0(work_dir,"-",work_file_prefix,"-outlier_status1.txt")
   } else {
    work_outlier_status_file <- paste0(work_dir,"-",work_file_prefix,"-outlier_status0.txt")
}

file.create(work_outlier_status_file)

write.table(work_outlier_status_file, row.names=F, col.names=F)

quit("yes")