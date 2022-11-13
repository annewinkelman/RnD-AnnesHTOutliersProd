# read in the list containing the names of the data files
# ls -1v Dec21_sel_AM_VOL/*inp > list_Dec21_sel_AM_VOL_inp_files
# vars: "AGE_GRP_CD","SSN_CD","CARRY","SAMPLE_REGIME_CD","anmlkey","abnormal","AM_VOL","AM_VOL","FAT_PCT","PROT_PCT","TAG","Contemporary.Group"
flist_data <- read.table("list_Dec21_sel_AM_VOL_inp_files")
names(flist_data) <- "dir_file"
flist_data[1:4,]
nrow(flist_data)


split_list <- strsplit(as.character(flist_data$dir_file),"/", fixed=T)

split_list_df <- data.frame(do.call(rbind, split_list))
names(split_list_df) <- c("dir","file")

flist_data <- cbind(flist_data, split_list_df)

file_cnt <- as.data.frame(table(flist_data$file))

table(file_cnt$Freq)

split_list_df[1:4,]

# read in the files indicating outliers
# files
two_pass_data <- read.csv("Dec21_AM_VOL_twopassoutsum.csv")

two_pass_data[1:4,]

# pass1 keys
# vars: "file","anmlkey","Contemporary.Group","AM_VOL","hilo","ndata"
keys_pass1 <- read.csv("Dec21_AM_VOL_allkeysqt4rpass1.csv")
keys_pass1[1:4,]

keys_pass1$pass <- 1

# pass2 keys
# NOTE: there might not be any pass 2 records
# vars: "file","anmlkey","Contemporary.Group","AM_VOL","hilo","ndata"
if(file.exists("Dec21_AM_VOL_allkeysqt4rpass2.csv")){
keys_pass2 <- read.csv("Dec21_AM_VOL_allkeysqt4rpass2.csv")
keys_pass2[1:4,]
keys_pass2$pass <- 2
}

if(file.exists("Dec21_AM_VOL_allkeysqt4rpass2.csv")){
   keys_pass12 <- rbind(keys_pass1, keys_pass2)
   } else {
   keys_pass12 <- keys_pass1
   }

keys_pass12[1:4,]

# data for selected CGs
# all CGs with outliers, even if got relaxed out
data_sel_cat <- flist_data$file %in% two_pass_data$file
table(data_sel_cat)

flist_data_sel1 <- flist_data[data_sel_cat,]

# just the CGs in which outliers were ultimately identified

sum(two_pass_data$N == two_pass_data$N_final)

no_out_cat <- two_pass_data$N == two_pass_data$N_final

two_pass_data_sel <- two_pass_data[!no_out_cat,]

data_sel_cat2 <- flist_data$file %in% two_pass_data_sel$file

flist_data_sel2 <- flist_data[data_sel_cat2,]

flist_data_sel2[1:4,]

# double check that cgs in keyfiles are in the selected data (and vice versa)
# they're not the same.  Some outliers may have got relaxed.
# So use two_pass_data_sel

table(keys_pass12$file %in% flist_data_sel2$file)

table(flist_data_sel2$file %in% keys_pass12$file)

# they match both ways when using the flist_data_sel2 data

flist_data_sel2[1:5,]

n_files <- nrow(flist_data_sel2)

n_files

library(ggplot2)

pdf("Dec21_AM_VOL_outliers.pdf")

# loop
for (ifile in 1:n_files) {
#for (ifile in 1:1) {
     work_dir_file <- flist_data_sel2[ifile,"dir_file"]
     work_file <- flist_data_sel2[ifile,"file"]

     work_data <- read.csv(work_dir_file)

     # still need to split by CG
     work_data_OUT <- split(work_data, work_data$Contemporary.Group)
     print(paste("File",ifile," Work file",work_file, " N Cgrps",length(work_data_OUT))) 

     for (icgrp in 1:length(work_data_OUT)){
          work_data_cgrp <- work_data_OUT[[icgrp]]
	  work_size <- nrow(work_data_cgrp)
	  work_comtemporary_group <- work_data_cgrp$Contemporary.Group[1]
	  work_age_grp_cd <- work_data_cgrp$AGE_GRP_CD[1]
	  work_file_cat <- keys_pass12$file == work_file & keys_pass12$Contemporary.Group == work_comtemporary_group # needs to be limited to a specific cgroup
  	  # could be empty
	  if(sum(work_file_cat) > 0){
	     # Still need to get rid of records that are below the minimum cutoff
	     sel_cat <- work_data_cgrp$AM_VOL > 1.5 & work_data_cgrp$abnormal == 0
	     work_data_cgrp <- work_data_cgrp[sel_cat,]
	     work_sel_keys <- keys_pass12[work_file_cat,]
	     work_sel_keys_cat <- work_data_cgrp$anmlkey %in% work_sel_keys$anmlkey
	     work_m1 <- merge(work_data_cgrp, work_sel_keys[,c("anmlkey","Contemporary.Group","AM_VOL","hilo","pass")], all.x=T, all.y=T)
	     work_m1[is.na(work_m1)] <- 0
	     # title info
	     work_npass1 <- sum(work_m1$pass == 1)
	     work_npass2 <- sum(work_m1$pass == 2)     
	     work_title <- paste0(work_file, "; Contemp Group ", work_comtemporary_group,"; Size ",work_size,"\n", "N pass 1 outliers: ",work_npass1, "; N pass 2 outliers: ", work_npass2)
	     # ggplot     
	     work_plot <- ggplot(work_m1, aes(x=AM_VOL,fill=factor(pass))) +
	     geom_histogram(binwidth=0.25) +
	     scale_fill_manual(name="Status",  values = c("green", "blue","red")) +
	     ggtitle(work_title) + 
	     theme_minimal()
	     print(work_plot)
	  }
     }
}

dev.off()

# check: HXKW20210413000000001
quit("no")