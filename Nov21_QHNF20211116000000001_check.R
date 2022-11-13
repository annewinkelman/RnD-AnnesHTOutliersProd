work_infile <- "Nov21/QHNF20211116000000001.inp"

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

cat_5012 <- ht_data$CG == 5012
table(cat_5012)

#2022-10-19 14:19:07,367 - INFO -  calc for cg 5012 pm pass # : 1
#2022-10-19 14:19:07,367 - INFO -     significance lvl : 6
#2022-10-19 14:19:07,367 - INFO -     samples in cg component : 21
#2022-10-19 14:19:07,367 - INFO -     ttable MF : 6.927 median : 7.3 MAD : 0.8999999999999995 offset range : 9.242973179999995
#2022-10-19 14:19:07,367 - INFO -     lower limit : -1.9429731799999947 adjusted to zero :
#2022-10-19 14:19:07,367 - INFO -     lower limit : 0 upper limit : 16.542973179999994

ht_data_5012 <- ht_data[cat_5012,]

max(ht_data_5012$PM_VOL)

ndata <- nrow(ht_data_5012)
ndata

work_mean <- mean(ht_data_5012$PM_VOL)
work_med <- median(ht_data_5012$PM_VOL)
work_mad <- mad(ht_data_5012$PM_VOL)

sig4 <- 10^-6
prob4 <- 1-0.5*sig4 #two-sided (multiply by 0.5 )

work_qt4 <- qt(prob4,(ndata-1))
work_qt4

work_absvalue <- abs(ht_data_5012$PM_VOL - work_med)
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

work_data <- ht_data_5012
work_nrec <- nrow(ht_data_5012)

# Now edit based on ALL data
    # get rid of zero values and abnormal codes
    # do this for ALL the traits so the nrec will be the same for all files
    am_present <- !(sum(work_data$AM_VOL == 0.0) == work_nrec)
    pm_present <- !(sum(work_data$PM_VOL == 0.0) == work_nrec)
    work_am_vol_min_cat <- work_data$AM_VOL <= 1.5
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
    work_abnormal_cat <- work_data$abnormal > 0
    work_data <- work_data[!work_all_min_cat & !work_abnormal_cat,]
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
