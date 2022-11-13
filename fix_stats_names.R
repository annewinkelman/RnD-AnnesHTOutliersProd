#
# grep -l PM_VOL_qt4.x *outlier_stats.csv > wrong_label_list
# awk -F"-" '{print $2}' wrong_label_list > fix_stats_names.txt
list <-  read.table("fix_stats_names.txt")
names(list) <- "main"

list$all <- paste0("Jun21/",list$main,".inp")

list

#
write.table(list$all, "fix_stats_names_all_info.txt", row.names=F, col.names=F, quote=F)

