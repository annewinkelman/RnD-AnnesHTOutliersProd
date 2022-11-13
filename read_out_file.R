#
#    0,2001,38951481,0,1,0,0,0, 0,000000.0,000012.6,00005.33,00003.81,0,0,0,0, 3108,
#    1,2001,39108992,0,1,0,0,0, 0,000000.0,000012.5,00005.97,00003.62,0,0,0,0, 3238,
#    2,2001,38864012,0,1,0,0,0, 0,000000.0,000018.3,00005.41,00003.91,0,0,0,0, 3195,
#    3,2001,38951445,0,1,0,0,0, 0,000000.0,000016.6,00005.28,00003.47,0,0,0,0, 3294,
#    4,2001,39108974,0,1,0,0,0, 0,000000.0,000019.1,00004.89,00003.76,0,0,0,0, 3149,
#    5,2001,38951480,0,1,0,0,0, 0,000000.0,000003.4,00003.43,00004.07,0,0,0,0, 3206,
#    6,2001,39042155,0,1,0,0,0, 0,000000.0,000009.0,00004.47,000003.9,0,0,0,0, 3301,

# 1. line number
# 2. CG
# 3. anmlkey
# 4. record bypass key
# 5. PM_VOL bypass key
# 6. AM_VOL bypass key 
# 7. FAT_PCT bypass key
# 8. PROT_PCT bypass key
# 9. abnormal code (
#10. PM_VOL
#11. AM_VOL
#12. FAT_PCT
#13. PROT_PCT
#14. out_PM_VOL (0,1,2,9)
#15. out_AM_VOL (0,1,2,9)
#16. out_FAT_PCT (0,1,2,9)
#17. out_PROT_PCT (0,1,2,9)
#18. anmltag
#19. nothing


data_out <- read.csv("/data/ls/anwin0/HTOutliersProd/Jul21/outputs/GLWV20201022000000001.out", header=F)
names(data_out) <- c("line","CG","anmlkey","ind1","ind2","ind3","ind4","ind5","ind6","PM_VOL","AM_VOL","FAT_PCT","PROT_PCT","out_PM_VOL","out_AM_VOL","out_FAT_PCT","out_PROT_PCT","number","nothing")

data_out[1:10,]

out_AM_VOL_out_cat <- data_out$out_AM_VOL > 0 & data_out$out_AM_VOL < 9

data_out[out_AM_VOL_out_cat,c("out_PM_VOL","out_AM_VOL","out_FAT_PCT","out_PROT_PCT")]

table(data_out$CG)

table(data_out[,c("CG","out_AM_VOL")])

ncol(data_out)
nrow(data_out)

table(data_out$ind1)
table(data_out$ind2)
table(data_out$ind3)
table(data_out$ind4)
table(data_out$ind5)
table(data_out$ind6)

colSums(data_out[,c("out_PM_VOL","out_AM_VOL","out_FAT_PCT","out_PROT_PCT")])

apply(data_out[,c("out_PM_VOL","out_AM_VOL","out_FAT_PCT","out_PROT_PCT")], 2, sum)
apply(data_out[,c("out_PM_VOL","out_AM_VOL","out_FAT_PCT","out_PROT_PCT")], 2, max)

table(data_out$out_PM_VOL)
table(data_out$out_AM_VOL)
table(data_out$out_FAT_PCT)
table(data_out$out_PROT_PCT)
