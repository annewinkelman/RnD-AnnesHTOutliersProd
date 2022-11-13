Sys.time()

# Note that this script differs to pmvol_stats.R in that the herds are already chosen, and it is size specific.
# vars: Contemporary.Group,anml_key,anml_num,map_ref,herd_num,spring,tdate,agecat,sample_regime_cd,carryover,dim,actual_am_vol,milk_abnm_cd,species_descr,Nstart
data <- read.csv("all_selected_amvol_size1_data.csv")

# size1: 50 to 75 cows

# significance
sig4 <- 10^-6
prob4 <- 1-0.5*sig4 #two-sided (multiply by 0.5 )


#
all_size1_map_ref <- c()
all_size1_herd_num <- c()

all_size1_mad_calc <- c()

all_size1_age <- c()

all_size1_N <- c()

all_size1_out4_cnt <- c()

all_size1_samples <- c()

all_selected_size1_data <- c()


pdf("amvol_size1_samples.pdf")

OUT4 <- split(data, data$Contemporary.Group)

for (ic in 1:length(OUT4)){
    work_data <- OUT4[[ic]]
    # stats on cg data
    work_age <- work_data$agecat[1]
    work_n <- nrow(work_data)	
    work_qt4 <- qt(prob4,(work_n-1))
    work_mad <- mad(work_data$actual_am_vol)
    work_med <- median(work_data$actual_am_vol)
    work_sel1_cgs <- work_data$Contemporary.Group[1]
    work_size1_mad_calc <- c(work_sel1_cgs, work_qt4, work_mad, work_med)
    all_size1_mad_calc <- rbind(all_size1_mad_calc, work_size1_mad_calc)

    # mad calc stats
    work_data$qt4 <- work_qt4
    work_data$mad <- work_mad
    work_data$med <- work_med

    # add to data
    work_data$absvalue <- abs(work_data$actual_am_vol - work_data$med)	
    work_data$maddev <- work_data$absvalue/work_data$mad
    work_data$outlier4 <- ifelse(work_data$maddev > work_qt4,1,0)

    # map_ref and herd_num
    all_size1_map_ref <- c(all_size1_map_ref, work_data$map_ref[1])
    all_size1_herd_num <- c(all_size1_herd_num, work_data$herd_num[1])	
    # outlier count
    all_size1_N <- c(all_size1_N, work_n)

    all_size1_age <- c(all_size1_age, work_age)

    all_size1_out4_cnt <- c(all_size1_out4_cnt, sum(work_data$outlier4))
    # selected data
    work_name_sel1 <- paste("seldata_age",work_age,"_size1_sample",ic,sep="")
    work_info <- c(work_age, work_sel1_cgs, work_n)
    all_size1_samples <- rbind(all_size1_samples, work_info)
    all_selected_size1_data <- rbind(all_selected_size1_data, work_data)
    assign(work_name_sel1, work_data)
    hist(work_data$actual_am_vol, main=paste("Small CG", "Age",work_age, "Sample",ic,"N =",work_n), xlab="Protein Yield", col="lightblue")
}

dev.off()

# size1
rownames(all_size1_mad_calc) <- NULL
all_size1_mad_calc_df <- as.data.frame(all_size1_mad_calc)
names(all_size1_mad_calc_df) <- c("cg","qt4","mad","med")

write.csv(all_size1_mad_calc_df, "am_vol_size1_mad_calc.csv", row.names=F)

# all the data
nrow(all_selected_size1_data)

# write out all the data
write.csv(all_selected_size1_data,"am_vol_selected_size1_data.csv", row.names=F)


