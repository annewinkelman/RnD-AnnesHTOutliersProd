# ls -1v Nov21*status1.txt > list_Nov21_status1_files

#status1_file_list <- read.table("list_Nov21_status1_files")
#nrow(status1_file_list)

#split_list <- strsplit(as.character(status1_file_list[,1]),"-", fixed=T)

#split_list_df <- data.frame(do.call(rbind, split_list))
#names(split_list_df) <- c("dir","inpfile","status_file")

#nrow(split_list_df)

#split_list_df[1:10,]

# can also do:
# ls -1v Nov21*status1.txt > list_Nov21_status1_files
# ls -1v Nov21*stats*csv > list_Nov21_outlier_stats_files
# awk -F"-" '{print $2}' list_Nov21_status1_files > list_Nov21_status1_files_names
# awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Nov21_status1_files_names list_Nov21_outlier_stats_files > selected_Nov21_outlier_stats_files

sel_file_names_list <- read.table("list_Nov21_status1_files_names")
names(sel_file_names_list) <- "file_name"

nrow(sel_file_names_list)

sel_file_names_list[1:3,]

sel_stats_file_list <- read.table("selected_Nov21_outlier_stats_files")

sel_stats_file_list[1:5,]
nrow(sel_stats_file_list)

# ls -1v Nov21*cnts*csv > list_Nov21_outlier_cnts_files
# awk -F"-" 'NR==FNR{a[$1]; next} $2 in a' list_Nov21_status1_files_names list_Nov21_outlier_cnts_files > selected_Nov21_outlier_cnts_files

sel_cnts_file_list <- read.table("selected_Nov21_outlier_cnts_files")
sel_cnts_file_list[1:5,]
nrow(sel_cnts_file_list)


# ls -1v Nov21/*inp > all_Nov21_inp_files
# awk -F'[/.]' 'NR==FNR{a[$1]; next} $2 in a' list_Nov21_status1_files_names all_Nov21_inp_files > selected_Nov21_input_files

sel_data_file_list <- read.table("selected_Nov21_input_files")

sel_data_file_list[1:5,]
nrow(sel_data_file_list)

# trait list
trait_list <- c("AM_VOL","PM_VOL","FAT_PCT","PROT_PCT")
am_vol_stats <- c("AM_VOL_qt4","AM_VOL_mad","AM_VOL_med")
pm_vol_stats <- c("PM_VOL_qt4","PM_VOL_mad","PM_VOL_med")
fatpct_stats <- c("FAT_PCT_qt4","FAT_PCT_mad","FAT_PCT_med")
propct_stats <- c("PROT_PCT_qt4","PROT_PCT_mad","PROT_PCT_med")

stats_names <- as.data.frame(rbind(am_vol_stats, pm_vol_stats, fatpct_stats, propct_stats))
names(stats_names) <- c("qt4","mad","med")

stats_names

# sel_data_file_list

nrow(sel_data_file_list)

for (ifile in 1:nrow(sel_data_file_list)) {
#for (ifile in 14:14) {
     work_file_name <- sel_file_names_list[ifile,] # just the long part of the file name
     print(paste("File",ifile, "Work file ",work_file_name))
     work_stats <- read.csv(sel_stats_file_list[ifile,])
     # Contemporary.Group nrec age all_am_out4_cnt all_pm_out4_cnt all_fat_pct_out4_cnt all_prot_pct_out4_cnt all_out4
     work_cnts <- read.csv(sel_cnts_file_list[ifile,])     
     work_data <- read.csv(sel_data_file_list[ifile,], header=F)
     # number of affected cgroups in this file
     # have to do by trait
     # all_am_out4_cnt, all_pm_out4_cnt, all_fat_pct_out4_cnt, all_prot_pct_out4_cnt
     work_am_num_cgrps <- sum(work_cnts$all_am_out4_cnt > 0, na.rm=T)
     work_pm_num_cgrps <- sum(work_cnts$all_pm_out4_cnt > 0, na.rm=T)
     work_fat_pct_num_cgrps <- sum(work_cnts$all_fat_pct_out4_cnt > 0, na.rm=T)
     work_prot_pct_num_cgrps <- sum(work_cnts$all_prot_pct_out4_cnt > 0, na.rm=T)
     work_all_num_cgrps <- c(work_am_num_cgrps, work_pm_num_cgrps, work_fat_pct_num_cgrps, work_prot_pct_num_cgrps)
     # counts
     work_n_stats <- nrow(work_stats)
     work_n_cnts <- nrow(work_cnts)
     work_n_data <- nrow(work_data) # this is all the data (includes NON-selected CGs)
     print(paste("Counts: stats",work_n_stats," cnts ",work_n_cnts," data ",work_n_data))
     # data file names
     names(work_data) <- c("AGE_GRP_CD","SSN_CD","CARRY", "SAMPLE_REGIME_CD","anmlkey","abnormal","PM_VOL","AM_VOL","FAT_PCT","PROT_PCT","TAG")
     work_cgrp_cols <- c("AGE_GRP_CD","SSN_CD","CARRY", "SAMPLE_REGIME_CD")
     work_data$Contemporary.Group <- apply(work_data[ ,work_cgrp_cols] , 1 , paste , collapse = "-" )

     # get the cgroups with outliers identified in pass1 (before any relaxation).  Remember the ENTIRE herd test group was written out.  The group contains multiple CGs.  
     sel_cgrp_cat <- work_cnts$all_out4 > 0
     work_cnts_sel <- work_cnts[sel_cgrp_cat,]
     # Just get the required CG(s)
     work_data_sel_cat <- work_data$Contemporary.Group %in% work_cnts_sel$Contemporary.Group
     work_data_sel <- work_data[work_data_sel_cat,]

     # stats for CG
     work_stats_sel_cat <- work_stats$Contemporary.Group %in% work_cnts_sel$Contemporary.Group
     work_stats_sel <- work_stats[work_stats_sel_cat,]
     # separate by cgroup (probably almost always one)
     work_data_OUT <- split(work_data_sel, work_data_sel$Contemporary.Group)
     work_cnts_OUT <- split(work_cnts_sel, work_cnts_sel$Contemporary.Group)
     work_stats_OUT <- split(work_stats_sel, work_stats_sel$Contemporary.Group)
     # keep the file names the same - just a different directory
     # start files
     work_am_vol <- c()
     work_pm_vol <- c()
     work_fat_pct <- c()
     work_prot_pct <- c()
     work_all_start_files <- c("work_am_vol","work_pm_vol","work_fat_pct","work_prot_pct")
     work_cgrp_trait_ind <- matrix(0, nrow=length(work_data_OUT), ncol=4)
     # the the matrix showing the cgrps and traits of interest
     work_trait_all_sel <- c()
     for (icgrp in 1:length(work_data_OUT)){
	  work_out_cnts <- work_cnts_OUT[[icgrp]]     
	  work_out_list <- work_out_cnts[,c("all_am_out4_cnt","all_pm_out4_cnt","all_fat_pct_out4_cnt","all_prot_pct_out4_cnt")]
	  work_out_list[is.na(work_out_list)] <- 0
	  work_trait_sel <- which(work_out_list > 0)
	  work_trait_all_sel <- c(work_trait_all_sel, work_trait_sel)
          work_cgrp_trait_ind[icgrp, work_trait_sel] <- 1
      }
      work_trait_all_sel <- unique(work_trait_all_sel)
#      print("work_trait_all_sel",work_trait_all_sel)
      # now go through each trait one-by-one across the cgroups (may be only one cgrp)
      # go through all traits (10/11/2022)
      for (itrait in work_trait_all_sel){
           work_store_data <- c()
	   work_store_cnts <- c()
           work_store_stats <- c()
       # which cgrps	  
       work_cgrp_sel <- which(work_cgrp_trait_ind[,itrait] > 0)
       for (icgrp in work_cgrp_sel){
	    # 
            work_out_data <- work_data_OUT[[icgrp]]
	    work_out_cnts <- work_cnts_OUT[[icgrp]]
	    work_out_stats <- work_stats_OUT[[icgrp]]
	    # append the data
	    work_store_data <- rbind(work_store_data, work_out_data)
	    work_store_cnts <- rbind(work_store_cnts, work_out_cnts)
	    work_store_stats <- rbind(work_store_stats, work_out_stats)
	}

	# end of cgroup within the selected trait, write out if anything is there to write out
	work_file_size <- is.null(work_store_data)
	if(!work_file_size){
	   work_trait_name <- trait_list[itrait]
       	   work_dir <- paste0("Nov21_sel_",work_trait_name,"/")
       	   # cnts
	   work_num_cgrps <- work_all_num_cgrps[itrait]
	   work_num_cgrps_outfile_name <- paste0(work_dir,work_file_name,".ncgrps")
	   write.table(work_num_cgrps, work_num_cgrps_outfile_name, row.names=F, col.names=F)
	   # stats
	   work_stats_names <- stats_names[itrait,]
	   sel_trait_names <- as.character(stats_names[itrait,])
           sel_stats_names <-  c("Contemporary.Group", sel_trait_names)
	   work_store_stats_out <- work_store_stats[,sel_stats_names]
	   # *** Give the stats the same name for all traits ***
	   names(work_store_stats_out) <- c("Contemporary.Group","qt4","mad","med")
	   work_stats_outfile_name <- paste0(work_dir,work_file_name,".stats")
	   write.csv(work_store_stats_out, work_stats_outfile_name, row.names=F)
	   # data
            work_data_outfile_name <- paste0(work_dir,work_file_name,".inp")
	    write.csv(work_store_data,work_data_outfile_name, row.names=F)
	  }
	  }
	  }
	  


quit("yes")
     
