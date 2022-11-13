# see htoutlier_pass1_id.R
# see AM_VOL_outliers.R
# see AM_VOL_outliers_plot.R
# significance
sig4 <- 10^-6
prob4 <- 1-0.5*sig4 #two-sided (multiply by 0.5 )

# vars: ANML_KEY,SIRE,YR,BIRTH_ID,CALVING_DATE,HT_DATE,UPD_TIME,MAP_REF,HERD_NUM,SSN,AM_VOL,PM_VOL,FAT_PCT,PROT_PCT,SCC,SAMPLE_REGIME_CD,MILK_ABNM_CD,FAT (ml),FAT_KGMS,PROT_KGMS,TOTAL_KGMS
work_data <- read.csv("Query_JC_2022_10_12.csv")

# am_vol

am_sel_cat <- work_data$AM_VOL > 1.5 & work_data$MILK_ABNM_CD == 0

am_vol_data <- work_data[am_sel_cat,c("ANML_KEY","BIRTH_ID","CALVING_DATE","HT_DATE","AM_VOL")]

am_vol_n <- nrow(am_vol_data)	
am_vol_qt4 <- qt(prob4,(am_vol_n-1))
am_vol_mad <- mad(am_vol_data$AM_VOL)
am_vol_med <- median(am_vol_data$AM_VOL)
am_vol_cgs <- am_vol_data$Contemporary.Group[1]

# mad calc stats

am_vol_data$qt4 <- am_vol_qt4
am_vol_data$mad <- am_vol_mad
am_vol_data$med <- am_vol_med

# add to data
am_vol_data$absvalue <- abs(am_vol_data$AM_VOL - am_vol_med)	
am_vol_data$maddev <- am_vol_data$absvalue/am_vol_mad
am_vol_data$outlier4 <- ifelse(am_vol_data$maddev > am_vol_qt4,1,0)

am_vol_data[1:4,]

table(am_vol_data$outlier4)

# first pass
ipass <- 1
minnotout <- aggregate(am_vol_data$AM_VOL, list(am_vol_data$outlier4), min)
maxnotout <- aggregate(am_vol_data$AM_VOL, list(am_vol_data$outlier4), max)
# Side-by-side allowances: expand the bounds
mincut <- max((minnotout[1,2] - 1),1.5)
maxcut <- maxnotout[1,2] + 2
pass1out4 <- am_vol_data$AM_VOL < mincut | am_vol_data$AM_VOL > maxcut
am_vol_data$outlier4r <- ifelse(pass1out4,1,0)

table(am_vol_data[,c("outlier4","outlier4r")])

library(ggplot2)

pdf("
     # ggplot     
     work_plot <- ggplot(work_m1, aes(x=AM_VOL,fill=factor(pass))) +
     geom_histogram(binwidth=0.25) +
     scale_fill_manual(name="Status",  values = c("green", "blue","red")) +
     ggtitle(work_title) + 
     theme_minimal()
