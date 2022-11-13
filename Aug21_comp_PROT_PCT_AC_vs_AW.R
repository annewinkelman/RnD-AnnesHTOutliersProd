# AC data
# In the directory
# awk -F, '$15 > 0 && $15 < 9{ print FILENAME "," $0 }' *out > Aug21_PROT_PCT_outliers_AC.csv

# BGNV20210705000000001.out,   40,2102,39879376,0,0,0,0,0, 0,000013.5,000032.1,00003.48,00003.16,0,1,0,0,  227,
# BGNV20210705000000001.out,  126,3102,38510954,0,0,0,0,0, 0,000011.6,000036.0,00003.89,00003.49,0,1,0,0,  346,
# BMTY20210705000000001.out,   22,2102,39872622,0,1,0,0,0, 0,000000.0,000022.4,00003.51,00003.79,0,1,0,0,  188,

# has one more column than Arnold's .out data (i.e. FILENAME in the first column)

# 1. FILENAME
# 2. line number
# 3. CG
# 4. anmlkey
# 5. record bypass key
# 6. PM_VOL bypass key
# 7. AM_VOL bypass key 
# 8. FAT_PCT bypass key
# 9. PROT_PCT bypass key
#10. abnormal code (
#11. PM_VOL
#12. AM_VOL
#13. FAT_PCT
#14. PROT_PCT
#15. out_PM_VOL (0,1,2,9)
#16. out_AM_VOL (0,1,2,9)
#17. out_FAT_PCT (0,1,2,9)
#18. out_PROT_PCT (0,1,2,9)
#19. anmltag
#20. nothing

ac_data <- read.csv("Aug21_PROT_PCT_outliers_AC.csv", header=F)
ncol(ac_data)

ac_data[1:4,]

names(ac_data) <- c("outfile", "line","CG","anmlkey","rec_bp", "PM_VOL_bp","AM_VOL_bp","FAT_PCT_bp","PROT_PCT_bp","abnormal", "PM_VOL","AM_VOL","FAT_PCT","PROT_PCT","out_PM_VOL","out_AM_VOL","out_FAT_PCT","out_
PROT_PCT","anmltag","nothing")

ac_data$fileprefix <- sapply(strsplit(ac_data$outfile,"[.]"), '[', 1)

ac_data[1:4,]

# AW data
# vars: "file","anmlkey","Contemporary.Group","PROT_PCT","hilo","ndata","pass"
aw_data <- read.csv("Aug21_PROT_PCT_allkeysqt4rpass12.csv")

aw_data$CG <- gsub("-", "", aw_data$Contemporary.Group)

aw_data$fileprefix <- sapply(strsplit(aw_data$file,"[.]"), '[', 1)

aw_data[1:4,]

# ========================================================================
# AC vs AW
# ========================================================================

ac_cat <- ac_data$fileprefix %in% aw_data$fileprefix & ac_data$anmlkey %in% aw_data$anmlkey & ac_data$CG %in% aw_data$CG
table(ac_cat)

ac_data$aw_out <- ac_cat

# in AC but not AW

ac_data_noaw <- ac_data[!ac_cat,]

if(sum(!ac_cat) > 0){
   write.csv(ac_data_noaw, "Aug21_comp_PROT_PCT_AC_noAW.csv", row.names=F)
   }

# ========================================================================
# AW vs AC
# ========================================================================

aw_cat <- aw_data$fileprefix %in% ac_data$fileprefix & aw_data$anmlkey %in% ac_data$anmlkey & aw_data$CG %in% ac_data$CG
table(aw_cat)

aw_data$ac_out <- aw_cat

# in AW but not AC

aw_data_noac <- aw_data[!aw_cat,]

if(sum(!aw_cat) > 0){
   write.csv(aw_data_noac, "Aug21_comp_PROT_PCT_AW_noAC.csv", row.names=F)
   }



# ========================================================================
# Together (counts)
# ========================================================================
ac_counts <- c(sum(ac_cat), sum(!ac_cat))
aw_counts <- c(sum(aw_cat), sum(!aw_cat))

ac_aw_counts <- as.data.frame(rbind(ac_counts, aw_counts))
names(ac_aw_counts) <- c("TRUE","FALSE")

write.table(ac_aw_counts,"Aug21_comp_PROT_PCT_AC_vs_AW_counts.txt")

quit("no")
