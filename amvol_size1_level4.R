library(data.table)
library(plotrix)

# all CGs with outliers
# vars: "Contemporary.Group","anml_key","anml_num","map_ref","herd_num","spring","tdate","agecat","sample_regime_cd",
# "carryover","dim","actual_am_vol","milk_abnm_cd","species_descr","Nstart","cg","qt4","mad","med","absvalue","maddev","outlier4","small","big"
cgdata4 <- read.csv("am_vol_recalc_size1_data.csv")
nrow(cgdata4)

# age info already in file

# work wwith level 4
# Do the first pass for level 4 
# recalculate the MAD and maddev and check for level 3/4 again.

# ALL level 3
sig<-10^-(3:6) # four levels
prob<-1-0.5*sig #two-sided (multiply by 0.5 )

sig
prob

# 
OUT4 <- split(cgdata4, cgdata4$Contemporary.Group)
length(OUT4)

# Do ALL CGs with:
# 1. pass 1: expunge on relaxed qt4
# 2. pass 2: expunge on relaxed qt4

all_in_htdata <- c()
all_fin_htdata <- c()

allskew <- c()
allkurtosis <- c()
allcg <- c()
allmad <- c()

pass2relax <- c()
twopassoutsum <- c()

twopassinfo <- c()

allkeysqt4rpass1 <- c()
allkeysqt4rpass2 <- c()

allkeysqt4reprievepass1 <- c()
allkeysqt4reprievepass2 <- c()

# No plots for this one.
for(ic in 1:length(OUT4)){
# for(ic in 1:2){
   workdata <- OUT4[[ic]]
   cgnum <- workdata$Contemporary.Group[1]   
   cggage <- workdata$agecat[1]   
   ndata <- length(workdata$actual_am_vol)
# pass 1
   ndata1 <- ndata
# The original outlier4 is used here
   ipass <- 1
   minnotout <- aggregate(workdata$actual_am_vol, list(workdata$outlier4), min)
   maxnotout <- aggregate(workdata$actual_am_vol, list(workdata$outlier4), max)
# Side-by-side allowances: expand the bounds
# have to have at least 1.5 litres
   mincut <- max((minnotout[1,2] - 1),1.5)
   maxcut <- maxnotout[1,2] + 2
# so what wasn't a low outlier under basic qt4 could become on with the new mincut.  Is that valid?
   pass1out4 <- workdata$actual_am_vol < mincut | workdata$actual_am_vol > maxcut
   workdata$outlier4r <- ifelse(pass1out4,1,0)
   workmed <- median(workdata$actual_am_vol)
   outpos <- which(workdata$outlier4r==1) # relaxed
# keys
# These are out with the first pass
   if (sum(workdata$outlier4r==1) > 0){
   workkey1 <- as.data.frame(workdata[outpos,c("anml_key","Contemporary.Group","actual_am_vol","qt4","maddev")])
   workkey1$mincut <- mincut
   workkey1$maxcut <- maxcut   
   workkey1$hilo <- ifelse(workdata[outpos,"actual_am_vol"] < workmed,"low","high")
   workkey1$ndata <- ndata1
   allkeysqt4rpass1 <- rbind(allkeysqt4rpass1,workkey1)
}

   outpos_reprieve <- which(workdata$outlier4==1 & workdata$outlier4r==0)
   if (sum(workdata$outlier4==1 & workdata$outlier4r==0) > 0){
      workkey1 <- as.data.frame(workdata[outpos_reprieve,c("anml_key","Contemporary.Group","actual_am_vol","qt4","maddev")])
      workkey1$mincut <- mincut
      workkey1$maxcut <- maxcut
      allkeysqt4reprievepass1 <- rbind(allkeysqt4reprievepass1,workkey1)
      }
      

# big vs small
   nsmall4r <- sum(workdata[outpos,"actual_am_vol"] < workmed)
   nbig4r <- sum(workdata[outpos,"actual_am_vol"] > workmed)

#   cat4 <- workdata$outlier4 == 1	
# reduced data set for pass 2 (same relaxation system as above)
# First do q4


   meandata <- mean(workdata$actual_am_vol)
# stats
   stddata <- sd(workdata$actual_am_vol)
   devdata <- workdata$actual_am_vol - meandata
   devdata3 <- devdata* devdata* devdata
   std3 <- stddata * stddata * stddata
   devdata4 <- devdata* devdata* devdata * devdata
   std4 <- stddata * stddata * stddata * stddata
   skewdata <-  sum(devdata3)/(std3*(ndata - 1))
   kurtosisdata <- sum(devdata4)/(std4*(ndata - 1))
   allcg <- c(allcg, as.character(workdata$Contemporary.Group[1]))
   allskew <- c(allskew, skewdata)
   allkurtosis <- c(allkurtosis, kurtosisdata)
   allmad <- c(allmad, workdata$mad[1])

# summary: start of CG
   outsum1 <- c(cgnum, cggage,ndata, workdata$mad[1], skewdata, kurtosisdata, sum(workdata$outlier4), sum(workdata$outlier4r),  nbig4r, nsmall4r)
      ipass <- 2
   all_in_htdata <- rbind(all_in_htdata, workdata)

#      data with first pass outliers removed (i.e. outlier4r removed from the data)

       print(paste("herd cnt",ic, "start out", sum(workdata$outlier4), "sum out", sum(pass1out4)))
       # if no outliers then don't need to process again

       if (sum(pass1out4) > 0){
       workdata <- workdata[!pass1out4,]
# How many absolutely new outlier4 (before relaxtation - yes)?
       workdata$outlier4old <- workdata$outlier4
       workdata$outlier4rold <- workdata$outlier4r

#       work_drops <- c("qt4", "mad", "med","absvalue","maddev","outlier4","outlier4r")
       work_drops <- c("qt4", "mad", "med","absvalue","maddev", "outlier4","outlier4r")
       workdata <- workdata[ , !(names(workdata) %in% work_drops)]

# RECALCS for reduced data - done CG by CG here
       ndata <- length(workdata$actual_am_vol)
       meandata <- mean(workdata$actual_am_vol)
# medians
       workdata$med <- median(workdata$actual_am_vol)
# mad default: mult by 1.4826
       workdata$mad <- mad(workdata$actual_am_vol)

       # Calculate mad: median(abs(x-6))
       workdata$absvalue <- abs(workdata$actual_am_vol - workdata$med)
       workdata$maddev <- workdata$absvalue/workdata$mad
# Quantiles
       qt4 <- qt(prob[4],(ndata-1))
       workdata$qt4 <- qt4

# This is a RECALC - so may have some qt4 outliers already removed
       workdata$outlier4 <- ifelse(workdata$maddev > qt4,1,0)
       worksize <- nrow(workdata)
# relaxation pass 2
# outpos
# 29 May 2018: Here we are working with outlier4!
       minnotout <- aggregate(workdata$actual_am_vol, list(workdata$outlier4), min)
       maxnotout <- aggregate(workdata$actual_am_vol, list(workdata$outlier4), max)

       mincut <- max((minnotout[1,2] - 1),1.5)
       maxcut <- maxnotout[1,2] + 2
       pass2out4 <- workdata$actual_am_vol < mincut | workdata$actual_am_vol > maxcut
       pass2change <- c(cgnum, sum(workdata$outlier4), sum(pass2out4))
       pass2relax <- rbind(pass2relax, pass2change)
       workdata$outlier4r <- ifelse(pass2out4, 1, 0)
       workmed <- median(workdata$actual_am_vol)
       outpos <- which(workdata$outlier4r==1) # relaxed
# keys out with the second pass
       if (sum(workdata$outlier4r==1) > 0){
          workkey2 <- as.data.frame(workdata[outpos,c("anml_key","Contemporary.Group","actual_am_vol")])
	  workkey2$hilo <- ifelse(workdata[outpos,"actual_am_vol"] < workmed,"low","high")
   	  workkey2$ndata <- ndata1
   	  allkeysqt4rpass2 <- rbind(allkeysqt4rpass2,workkey2)
}

# keys that got a reprieve in the second pass
   outpos_reprieve <- which(workdata$outlier4==1 & workdata$outlier4r==0)
   if (sum(workdata$outlier4==1 & workdata$outlier4r==0) > 0){
      workkey2 <- as.data.frame(workdata[outpos_reprieve,c("anml_key","Contemporary.Group","actual_am_vol","qt4","maddev")])
      workkey2$mincut <- mincut
      workkey2$maxcut <- maxcut
      allkeysqt4reprievepass2 <- rbind(allkeysqt4reprievepass2,workkey2)
      }

# big vs small
       nsmall <- sum(workdata[outpos,"actual_am_vol"] < workmed)
       nbig <- sum(workdata[outpos,"actual_am_vol"] > workmed)
# summary
# Just too see:      outsum1 <- c(cgnum, cggage,ndata, workdata$mad[1], skewdata, kurtosisdata, sum(workdata$outlier4), sum(workdata$outlier4r),  nbig4r, nsmall4r)
       outsum2 <- c(ndata, sum(workdata$outlier4), sum(workdata$outlier4old == 0 & workdata$outlier4 == 1), sum(workdata$outlier4r), nbig, nsmall)
       outsum12 <- c(outsum1, outsum2)

       twopassoutsum <- rbind(twopassoutsum, outsum12)
       work_info <- cbind(workdata$anml_key, workdata$actual_am_vol, workdata$outlier4, workdata$outlier4r, mincut, maxcut)
       all_fin_htdata <- rbind(all_fin_htdata, workdata)

}
} # end of loop



length(outsum1)
length(outsum2)

outsum1
outsum2


rownames(twopassoutsum) <- NULL

twopassoutsum <- as.data.frame(twopassoutsum)
nrow(twopassoutsum)

twopassoutsum

ncol(twopassoutsum)

length(c("Contemporary.Group","CG Age","Nstart","mad","skewdata","kurtosisdata", "outlier4","outlier4r", "nbig4r","nsmall4r","N2","outlier4New","Notoutpass1","outlier4F\
inal","nbig","nsmall"))





# twopassoutsum 


#    outsum1 <- c(cgnum, ndata, skewdata, kurtosisdata, sum(workdata$outlier4), sum(workdata$outlier4r))
names(twopassoutsum) <- c("Contemporary.Group","CG Age","Nstart","mad","skewdata","kurtosisdata", "outlier4","outlier4r", "nbig4r","nsmall4r","N2","outlier4New","Notoutpass1","outlier4Final","nbig","nsmall")



twopassoutsum$Nfinal <- twopassoutsum$N2 - twopassoutsum$outlier4Final
twopassoutsum$Nout <- twopassoutsum$Nstart - twopassoutsum$Nfinal

sum(twopassoutsum$Nfinal)/sum(twopassoutsum$Nstart)


write.csv(twopassoutsum,"amvol_size1_all2passum.csv", row.names=F)

# quit("yes")

# "saved"
sum(twopassoutsum$outlier4) - sum(twopassoutsum$outlier4r+twopassoutsum$outlier4Final)

# keys
# pass 1
write.csv(allkeysqt4rpass1,"amvol_size1_allkeysqt4rpass1.csv", row.names=F, quote=F)

# pass2
write.csv(allkeysqt4rpass2,"amvol_size1_allkeysqt4rpass2.csv", row.names=F, quote=F)


# data sets
all_in_selcols <- all_in_htdata[,c("Contemporary.Group", "anml_key","actual_am_vol","Nstart","outlier4","outlier4r")]

all_fin_selcols <- all_fin_htdata[,c("Contemporary.Group", "anml_key","actual_am_vol","outlier4","outlier4r")]

outlier_names <- c("outlier4","outlier4r")

pass1_names <- c("outlier4p1","outlier4rp1")
pass2_names <- c("outlier4p2","outlier4rp2")

#names(all_in_selcols)[5:6] <- pass1_names
#names(all_fin_selcols)[4:5] <- pass2_names

#all_in_selcols[1:4,]

#all_fin_selcols[1:4,]

# add removal data to input data

library(dplyr)

df = data.frame(q = 1, w = 2, e = 3)

df

oldnames = c("q","e")
newnames = c("A","B")

df %>% rename_at(vars(oldnames), ~ newnames)

df = data.frame(q = 1, w = 2, e = 3)

df %>% rename_with(~ newnames[which(oldnames == .x)], .cols = oldnames)

# test
all_in_selcols <- all_in_htdata[,c("Contemporary.Group", "anml_key","actual_am_vol","Nstart","outlier4","outlier4r")]

pass1_oldnames <- c("outlier4","outlier4r")
pass1_newnames <- c("outlier4p1","outlier4rp1")

all_in_selcols_rename <- all_in_selcols %>% rename_with(~ pass1_newnames[which(pass1_oldnames == .x)], .cols = pass1_oldnames)

all_in_selcols[1:4,]
all_in_selcols_rename[1:4,]

all_fin_selcols <- all_fin_htdata[,c("Contemporary.Group", "anml_key","actual_am_vol","Nstart","outlier4","outlier4r")]

pass2_oldnames <- c("outlier4","outlier4r")
pass2_newnames <- c("outlier4p2","outlier4rp2")

all_fin_selcols_rename <- all_fin_selcols %>% rename_with(~ pass2_newnames[which(pass2_oldnames == .x)], .cols = pass2_oldnames)

all_fin_selcols[1:4,]
all_fin_selcols_rename[1:4,]

all_in_fin_selcols <- merge(all_in_selcols_rename, all_fin_selcols_rename, all.x=T)
nrow(all_in_fin_selcols)

all_in_fin_selcols[1:3,]

final_data <- merge(all_in_htdata, all_in_fin_selcols)
nrow(final_data)

as.data.frame(names(final_data))

table(final_data$species_descr)

# get rid of some columnss
drops <- c("small","big","outlier4","outlier4r")

final_data <- final_data[ , !(names(final_data) %in% drops)]

#
write.csv(final_data,"amvol_size1_level4_outlier_id.csv", row.names=F)



quit("yes")

