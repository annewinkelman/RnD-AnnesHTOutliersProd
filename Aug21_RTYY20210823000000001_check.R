work_infile <- "Aug21/RTYY20210823000000001.inp"

ht_data <- read.csv(work_infile, header=F)
names(ht_data) <- c("AGE_GRP_CD","SSN_CD","CARRY", "SAMPLE_REGIME_CD","anmlkey","abnormal","PM_VOL","AM_VOL","FAT_PCT","PROT_PCT","TAG")
nrow(ht_data)

ht_cols <- c("AGE_GRP_CD","SSN_CD","CARRY", "SAMPLE_REGIME_CD")

ht_data$Contemporary.Group <- apply(ht_data[ ,ht_cols] , 1 , paste , collapse = "-" )

ht_data$CG <- gsub("-", "", ht_data$Contemporary.Group)

table(ht_data$abnormal)

sum(ht_data$PM_VOL == 0.0)

sum(ht_data$AM_VOL == 0.0)

min(ht_data$PM_VOL)
min(ht_data$AM_VOL)

min(ht_data$FAT_PCT)
min(ht_data$PROT_PCT)

cat_4002 <- ht_data$CG == 4002
table(cat_4002)

#2022-10-19 11:18:38,787 - INFO -  calc for cg 4002 pm pass # : 1
#2022-10-19 11:18:38,788 - INFO -     significance lvl : 6
#2022-10-19 11:18:38,788 - INFO -     samples in cg component : 75
#2022-10-19 11:18:38,788 - INFO -     ttable MF : 5.3355 median : 11.5 MAD : 1.0 offset range : 7.910412299999999
#2022-10-19 11:18:38,788 - INFO -     lower limit : 3.589587700000001 upper limit : 19.410412299999997

ht_data_4002 <- ht_data[cat_4002,]

min(ht_data_4002$PM_VOL)
min(ht_data_4002$AM_VOL)

min(ht_data_4002$FAT_PCT)
min(ht_data_4002$PROT_PCT)


ndata <- nrow(ht_data_4002)

work_mean <- mean(ht_data_4002$PM_VOL)
work_med <- median(ht_data_4002$PM_VOL)
work_mad <- mad(ht_data_4002$PM_VOL)

sig4 <- 10^-6
prob4 <- 1-0.5*sig4 #two-sided (multiply by 0.5 )

work_qt4 <- qt(prob4,(ndata-1))

work_absvalue <- abs(ht_data_4002$PM_VOL - work_med)
work_maddev <- work_absvalue/work_mad

work_upper <- work_med + (work_qt4 * work_mad)
work_lower <- work_med - (work_qt4 * work_mad)

work_mean
work_med

work_mad
work_mad_unscale <- work_mad/1.4826
format(work_mad_unscale,digits=10)


work_upper
work_lower

work_data <- ht_data_4002

work_nrec <- nrow(work_data)

# Now edit based on ALL data
    # get rid of zero values and abnormal codes
    # do this for ALL the traits so the nrec will be the same for all files
    am_present <- !(sum(work_data$PM_VOL == 0.0) == work_nrec)
    pm_present <- !(sum(work_data$PM_VOL == 0.0) == work_nrec)
    work_am_vol_min_cat <- work_data$PM_VOL <= 1.5
    work_pm_vol_min_cat <- work_data$PM_VOL <= 1.5
    work_fat_pct_min_cat <- work_data$PM_VOL <= 0.5
    work_prot_pct_min_cat <- work_data$PROT_PCT <= 0.5

    if(am_present & !pm_present){
        work_all_min_cat <- work_am_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else if (pm_present & !am_present) {
        work_all_min_cat <- work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    } else {
        work_all_min_cat <- work_am_vol_min_cat | work_pm_vol_min_cat | work_fat_pct_min_cat | work_prot_pct_min_cat
    }

    sum(work_all_min_cat)
    work_abnormal_cat <- work_data$abnormal > 0
    sum(work_abnormal_cat)
    work_data <- work_data[!work_all_min_cat & !work_abnormal_cat,]
    nrow(work_data)
    # Stats on cg data
    work_age <- work_data$AGE_GRP_CD[1]
    work_n <- nrow(work_data)	
    work_qt4 <- qt(prob4,(work_n-1))
    work_mad <- mad(work_data$PM_VOL)
    work_med <- median(work_data$PM_VOL)


work_n
work_qt4
work_mad
work_med
