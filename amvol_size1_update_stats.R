Sys.time()

# read in the data for which outliers have been created.
# calculate the statistics and determine the number of outliers basd on level 4

# from: pmvol_size1_perturb.R
# vars: "qt4","mad","med","Contemporary.Group","anml_key","anml_num","map_ref","herd_num","spring","tdate","agecat",
# "sample_regime_cd","carryover","dim","actual_am_vol","milk_abnm_cd","species_descr","Nstart","absvalue","maddev","outlier4","cg","lower","upper"

cgdata4 <- read.csv("am_vol_adjusted_size1_data.csv")

cgdata4[1:4,1:4]

as.data.frame(names(cgdata4))

# get rid of old stats (qt4, mad, med) so don't get mixed up
drops <- c("qt4", "mad", "med","absvalue","maddev","outlier4","lower","upper")
cgdata4 <- cgdata4[ , !(names(cgdata4) %in% drops)]

cgdata4[1:4,1:4]

as.data.frame(names(cgdata4))

# significance
sig4 <- 10^-6
prob4 <- 1-0.5*sig4 #two-sided (multiply by 0.5 )

OUT4 <- split(cgdata4, cgdata4$Contemporary.Group)

all_cgs <- c()
all_cgs_stats <- c()

for(ic in 1:length(OUT4)){
    work_data <- OUT4[[ic]]
    # stats on cg data
    work_n <- nrow(work_data)
    work_age <- work_data$agecat[1]
    work_cg <- work_data$Contemporary.Group[1]
    work_map_ref <- work_data$map_ref[1]
    work_herd_num <- work_data$herd_num[1]    
    work_qt4 <- qt(prob4,(work_n-1))
    work_mad <- mad(work_data$actual_am_vol)
    work_med <- median(work_data$actual_am_vol)
# mad calc stats
    work_data$qt4 <- work_qt4
    work_data$mad <- work_mad
    work_data$med <- work_med
    # add to data
    work_data$absvalue <- abs(work_data$actual_am_vol - work_data$med)	
    work_data$maddev <- work_data$absvalue/work_data$mad
    work_data$outlier4 <- ifelse(work_data$maddev > work_qt4,1,0)
    n_total_outlier4 <- sum(work_data$outlier4)
    # big versus small
    nsmall <- sum(work_data$actual_am_vol < work_med & work_data$outlier4 == 1)
    nbig <- sum(work_data$actual_am_vol > work_med & work_data$outlier4 == 1)   
    # cg id
    work_cg_id <- c(work_cg, work_map_ref, work_herd_num, work_age, work_n, n_total_outlier4, nsmall, nbig)
    all_cgs_stats <- rbind(all_cgs_stats, work_cg_id)

# all the data
    work_data$small <- ifelse(work_data$actual_am_vol < work_med & work_data$outlier4 == 1,1,0)
    work_data$big <- ifelse(work_data$actual_am_vol > work_med & work_data$outlier4 == 1,1,0)
    all_cgs <- rbind(all_cgs, work_data)

}


rownames(all_cgs_stats) <- NULL

all_cgs_stats_df <- as.data.frame(all_cgs_stats, stringsAsFactors = FALSE)

# c(work_cg, work_map_ref, work_herd_num, work_age, work_n, n_total_outlier4, nsmall, nbig)
names(all_cgs_stats_df) <- c("Contemporary.Group","map_ref","herd_num", "agecat","N","outlier4", "nsmall","nbig")
all_cgs_stats_df

all_cgs[1:4,]

#
write.csv(all_cgs,"am_vol_recalc_size1_data.csv", row.names=F)

# check

outlier4_df <- aggregate(all_cgs$outlier4, list(all_cgs$Contemporary.Group), sum)
names(outlier4_df) <- c("Contemporary.Group","outlier4")

nsmall_df <- aggregate(all_cgs$small, list(all_cgs$Contemporary.Group), sum)
names(nsmall_df) <- c("Contemporary.Group","nsmall")

nbig_df <- aggregate(all_cgs$big, list(all_cgs$Contemporary.Group), sum)
names(nbig_df) <- c("Contemporary.Group","nbig")

library(tidyverse)

all_cgs_calc_stats <- list(outlier4_df, nsmall_df, nbig_df) %>% reduce(full_join, by = "Contemporary.Group")

all_cgs_calc_stats

write.table(all_cgs_calc_stats,"amvol_size1_update_stats.txt",  row.names=F)

quit("yes")

