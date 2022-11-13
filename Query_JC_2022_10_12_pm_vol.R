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

# pm_vol

pm_sel_cat <- work_data$PM_VOL > 1.5 & work_data$MILK_ABNM_CD == 0

pm_vol_data <- work_data[pm_sel_cat,c("ANML_KEY","BIRTH_ID","CALVING_DATE","HT_DATE","PM_VOL")]

pm_vol_n <- nrow(pm_vol_data)	
pm_vol_qt4 <- qt(prob4,(pm_vol_n-1))
pm_vol_mad <- mad(pm_vol_data$PM_VOL)
pm_vol_med <- median(pm_vol_data$PM_VOL)
pm_vol_cgs <- pm_vol_data$Contemporary.Group[1]


# mad calc stats

pm_vol_data$qt4 <- pm_vol_qt4
pm_vol_data$mad <- pm_vol_mad
pm_vol_data$med <- pm_vol_med

# add to data
pm_vol_data$absvalue <- abs(pm_vol_data$PM_VOL - pm_vol_med)	
pm_vol_data$maddev <- pm_vol_data$absvalue/pm_vol_mad

# M−qt4 * MAD < xi < M+qt4 * MAD (Leys et al.)
pm_vol_data$pm_vol_lower1 <- pm_vol_med - (pm_vol_qt4 * pm_vol_mad)
pm_vol_data$pm_vol_upper1 <- pm_vol_med + (pm_vol_qt4 * pm_vol_mad)

pm_vol_data$outlier4 <- ifelse(pm_vol_data$maddev > pm_vol_qt4,1,0)

pm_vol_data[1:4,]

table(pm_vol_data$outlier4)

# first pass
ipass <- 1
minnotout <- aggregate(pm_vol_data$PM_VOL, list(pm_vol_data$outlier4), min)
maxnotout <- aggregate(pm_vol_data$PM_VOL, list(pm_vol_data$outlier4), max)
# Side-by-side allowances: expand the bounds
mincut <- max((minnotout[1,2] - 1),1.5)
maxcut <- maxnotout[1,2] + 2
pass1out4 <- pm_vol_data$PM_VOL < mincut | pm_vol_data$PM_VOL > maxcut
pm_vol_data$outlier4r <- ifelse(pass1out4,1,0)

pm_vol_data$pass <- ifelse(pm_vol_data$outlier4r == 1, 1, 0)

table(pm_vol_data[,c("outlier4","outlier4r")])

porder1 <- order(-pm_vol_data$PM_VOL)

pm_vol_data_o <- pm_vol_data[porder1,]

pm_vol_data_o[1:10,]

write.csv(pm_vol_data_o, "Query_JC_2022_10_12_pm_vol_pass1.csv")

# second pass
    ipass <- 2

    pm_vol_data2 <- pm_vol_data[!pass1out4,]
# RECALCS for reduced data - done CG by CG here
    ndata2 <- length(pm_vol_data2$PM_VOL)
    meandata2 <- mean(pm_vol_data2$PM_VOL)
# medians
    pm_vol_data2_med <- median(pm_vol_data2$PM_VOL)
# MAD default: mult by 1.4826
    pm_vol_data2_mad <- mad(pm_vol_data2$PM_VOL)

    # Calculate MAD: median(abs(x-6))
    pm_vol_data2$absvalue <- abs(pm_vol_data2$PM_VOL - pm_vol_data2_med)
    pm_vol_data2$maddev <- pm_vol_data2$absvalue/pm_vol_data2_mad
# Quantiles
    pm_vol_data2_qt4 <- qt(prob4,(ndata2-1))
    # MED−qt4 * MAD < xi < MED+qt4 * MAD (Leys et al.)
    pm_vol_data2$pm_vol_lower2 <- pm_vol_data2_med - (pm_vol_data2_qt4 * pm_vol_data2_mad)
    pm_vol_data2$pm_vol_upper2 <- pm_vol_data2_med + (pm_vol_data2_qt4 * pm_vol_data2_mad)


    pm_vol_data2$outlier4old <- pm_vol_data2$outlier4
# This is a RECALC - so may have some qt4 outliers already removed
    pm_vol_data2$outlier4 <- ifelse(pm_vol_data2$maddev > pm_vol_data2_qt4,1,0)

    minnotout <- aggregate(pm_vol_data2$PM_VOL, list(pm_vol_data2$outlier4), min)
    maxnotout <- aggregate(pm_vol_data2$PM_VOL, list(pm_vol_data2$outlier4), max)

    mincut <- max((minnotout[1,2] - 1),1.5)
    maxcut <- maxnotout[1,2] + 2
    pass2out4 <- pm_vol_data2$PM_VOL < mincut | pm_vol_data2$PM_VOL > maxcut
    pm_vol_data2$outlier4r <- ifelse(pass2out4, 1, 0)
    pm_vol_data2_med <- median(pm_vol_data2$PM_VOL)

# add to data

pass2_cat <- pm_vol_data2$outlier4r == 1

if(sum(pass2_cat) > 0){
   pm_vol_data2_out <- pm_vol_data2[pass2_cat,"ANML_KEY"]
   pass2_cat <- pm_vol_data$ANML_KEY %in% pm_vol_data2_out$ANML_KEY
   pm_vol_data[pass2_cat,"pass"] <- 2
   }

order2 <- order(-pm_vol_data2$PM_VOL)

pm_vol_data2_o <- pm_vol_data2[order2,]

pm_vol_data2_o[1:5,]

write.csv(pm_vol_data2_o, "Query_JC_2022_10_12_pm_vol_pass2.csv")

   
sum_pass1 <- sum(pm_vol_data$outlier4r > 0)
sum_pass2 <- sum(pm_vol_data2$outlier4r > 0)
work_ggtitle <- paste0("Herd ",herd," Test Date ",testdate," Trait: PM_VOL", "\n","Pass1 Outliers: ",sum_pass1, "; Pass2 Outliers: ",sum_pass2)

library(ggplot2)

upper_limit <- pm_vol_data$pm_vol_upper1[1]
upper_limit

lower_limit <- pm_vol_data$pm_vol_lower1[1]
lower_limit

x_lower <- max(0,lower_limit)
x_lower

x_upper <- upper_limit + 2
x_upper


pdf("Query_JC_2022_10_12_pm_vol.pdf")
     # ggplot     
p1 <- ggplot(pm_vol_data, aes(x=PM_VOL,fill=factor(pass))) +
     geom_histogram(binwidth=0.25) +
     scale_fill_manual(name="Status",  values = c("green", "blue","red")) +
     xlim(x_lower, x_upper) + 
     ggtitle(work_ggtitle) + 
     theme_minimal()

p1

p1 + geom_segment(aes(x = upper_limit, y = 0, xend = upper_limit, yend = 2.5))

dev.off()
