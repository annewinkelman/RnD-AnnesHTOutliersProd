# see htoutlier_pass1_id.R
# see AM_VOL_outliers.R
# see AM_VOL_outliers_plot.R
# significance
sig4 <- 10^-6
prob4 <- 1-0.5*sig4 #two-sided (multiply by 0.5 )

prob4

herd = "MVRP"

# vars: ANML_KEY,SIRE,YR,BIRTH_ID,CALVING_DATE,HT_DATE,UPD_TIME,MAP_REF,HERD_NUM,SSN,AM_VOL,PM_VOL,FAT_PCT,PROT_PCT,SCC,SAMPLE_REGIME_CD,MILK_ABNM_CD,FAT (ml),FAT_KGMS,PROT_KGMS,TOTAL_KGMS
work_data <- read.csv("Query_JC_2022_10_12.csv")

testdate <- work_data[1,"HT_DATE"]

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

# M−qt4 * MAD < xi < M+qt4 * MAD (Leys et al.)
am_vol_data$am_vol_lower1 <- am_vol_med - (am_vol_qt4 * am_vol_mad)
am_vol_data$am_vol_upper1 <- am_vol_med + (am_vol_qt4 * am_vol_mad)

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

am_vol_data$pass <- ifelse(am_vol_data$outlier4r == 1, 1, 0)

table(am_vol_data[,c("outlier4","outlier4r")])

order1 <- order(-am_vol_data$AM_VOL)

am_vol_data_o <- am_vol_data[order1,]

am_vol_data_o[1:5,]

write.csv(am_vol_data_o, "Query_JC_2022_10_12_am_vol_pass1.csv")

# second pass
    ipass <- 2

    am_vol_data2 <- am_vol_data[!pass1out4,]
# RECALCS for reduced data - done CG by CG here
    ndata2 <- length(am_vol_data2$AM_VOL)
    meandata2 <- mean(am_vol_data2$AM_VOL)
# medians
    am_vol_data2_med <- median(am_vol_data2$AM_VOL)
# MAD default: mult by 1.4826
    am_vol_data2_mad <- mad(am_vol_data2$AM_VOL)

    # Calculate MAD: median(abs(x-6))
    am_vol_data2$absvalue <- abs(am_vol_data2$AM_VOL - am_vol_data2_med)
    am_vol_data2$maddev <- am_vol_data2$absvalue/am_vol_data2_mad
# Quantiles
    am_vol_data2_qt4 <- qt(prob4,(ndata2-1))

    # M−qt4 * MAD < xi < M+qt4 * MAD (Leys et al.)
    am_vol_data2$am_vol_lower2 <- am_vol_data2_med - (am_vol_data2_qt4 * am_vol_data2_mad)
    am_vol_data2$am_vol_upper2 <- am_vol_data2_med + (am_vol_data2_qt4 * am_vol_data2_mad)


    am_vol_data2$outlier4old <- am_vol_data2$outlier4
# This is a RECALC - so may have some qt4 outliers already removed
    am_vol_data2$outlier4 <- ifelse(am_vol_data2$maddev > am_vol_data2_qt4,1,0)

    minnotout <- aggregate(am_vol_data2$AM_VOL, list(am_vol_data2$outlier4), min)
    maxnotout <- aggregate(am_vol_data2$AM_VOL, list(am_vol_data2$outlier4), max)

    mincut <- max((minnotout[1,2] - 1),1.5)
    maxcut <- maxnotout[1,2] + 2
    pass2out4 <- am_vol_data2$AM_VOL < mincut | am_vol_data2$AM_VOL > maxcut
    am_vol_data2$outlier4r <- ifelse(pass2out4, 1, 0)
    am_vol_data2_med <- median(am_vol_data2$AM_VOL)

# add to data

pass2_cat <- am_vol_data2$outlier4r == 1

if(sum(pass2_cat) > 0){
   am_vol_data2_out <- am_vol_data2[pass2_cat,"ANML_KEY"]
   pass2_cat <- am_vol_data$ANML_KEY %in% am_vol_data2_out$ANML_KEY
   am_vol_data[pass2_cat,"pass"] <- 2
   }

order2 <- order(-am_vol_data2$AM_VOL)

am_vol_data2_o <- am_vol_data2[order2,]

am_vol_data2_o[1:5,]

write.csv(am_vol_data2_o, "Query_JC_2022_10_12_am_vol_pass2.csv")

sum_pass1 <- sum(am_vol_data$outlier4r > 0)
sum_pass2 <- sum(am_vol_data2$outlier4r > 0)
work_ggtitle <- paste0("Herd ",herd," Test Date ",testdate," Trait: AM_VOL", "\n","Pass1 Outliers: ",sum_pass1, "; Pass2 Outliers: ",sum_pass2)

library(ggplot2)

upper_limit <- am_vol_data$am_vol_upper1[1]
upper_limit

pdf("Query_JC_2022_10_12_am_vol.pdf")
     # ggplot     
p1 <-  ggplot(am_vol_data, aes(x=AM_VOL,fill=factor(pass))) +
     geom_histogram(binwidth=0.25) +
     scale_fill_manual(name="Status",  values = c("green", "blue","red")) +
     ggtitle(work_ggtitle) + 
     theme_minimal()

p1

p1 + geom_segment(aes(x = upper_limit, y = 0, xend = upper_limit, yend = 2.5))

dev.off()
