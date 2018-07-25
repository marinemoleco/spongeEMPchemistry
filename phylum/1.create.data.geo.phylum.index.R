getwd() 
setwd("~/work/chemistry/v3/")

##### phylum #####

as.data.frame(t(read.table(file="phylum_level.txt", sep="\t", header=TRUE, row.names = 1, check.names = FALSE))) -> abundance_orig # 2486 x 63
read.table(file="sponge_samples_and_ML_data.txt", sep="\t", header = TRUE, row.names = 1) -> factors # 2486 x 59

# cleanup abundance table if necessary
abundance_orig -> abundance

abundance <- droplevels(abundance[rowSums(abundance) !=0, ]) # 2478 x 63
abundance <- droplevels(abundance[, colSums(abundance) !=0 ]) # 2478 x 53

fac_abund_merge <- droplevels(merge(factors, abundance, by="row.names", keep=F)) # 2478 x 113
rownames(fac_abund_merge) <- fac_abund_merge[,1] #
fac_abund_merge$Row.names <- NULL # 2478 x 112
factors <- droplevels(fac_abund_merge[,1:59]) # 2478 x 59

library(plyr)
# data transformation summarise taxa abundance and factors
# abundance data - long and complicated
hostID <- as.data.frame(factors$host_scientific_name)
rownames(hostID) <- rownames(factors)
factors$host_scientific_name <- NULL # 2478 x 58

# keep sponge taxa > 2
names(hostID)[1] <- "taxa"
hostID$names <- rownames(hostID) # 2478
hostID <- droplevels(data.frame(hostID[hostID$taxa %in% names(which(table(hostID$taxa) > 2)), ])) # 2447
hostID$names <- NULL

#short factors here
factors_short <- merge(hostID, factors, by="row.names", keep=FALSE) # 2447 x 60
factors_short$taxa <- NULL # 2447 x 59
rownames(factors_short) <- factors_short[,1]
factors_short$Row.names <- NULL
factors <- droplevels(factors_short) # 2447 x 58

abundance <- merge(abundance, factors, by="row.names", keep=FALSE) # 2478 x 53 -> 2447 x 112
rownames(abundance) <- abundance[,1]
abundance[,1] <- NULL # 2447 x 111
abundance <- droplevels(abundance[,1:53]) # 2447 x 53

abundance <- droplevels(abundance[, colSums(abundance) !=0]) #
abundance <- droplevels(abundance[rowSums(abundance) !=0, ]) # 


hostID <- merge(hostID, factors, by="row.names", keep=FALSE)
rownames(hostID) <- hostID[,1]
hostID[,1] <- NULL
hostID <- hostID[,1]

# cleanup factors / keep only if YES and NO
sapply(factors, function(col) length(unique(col)))

library(dplyr)
fac <- factors
fac <- fac[, sapply(fac, function(x) !is.factor(x) | sum(tabulate(x) > 1) >= 2)] 
as.data.frame(summary(fac)) -> results
results

factors <- droplevels(fac) # 2447 x 57
abundance <- droplevels(abundance)
hostID <- droplevels(hostID)

rm(fac_abund_merge)
rm(factors_short)
rm(results)
rm(fac)

row_names <- data.frame(rownames(abundance))
write.table(row_names, file="phylum_samples.txt", row.names = F) # save sample IDs to create with final.with.tax.table the offset-calculation-file-table / awk.txt = awk -F'\t' 'NR==FNR{arr[$1]++;next}{for(i=1; i<=NF; i++) if ($i in arr){a[i]++;}} { for (i in a) printf "%s\t", $i; printf "\n"}' phylum_samples.txt final.withtax.v14.tsv > final.phylum.txt
system('awk -F'\t' 'NR==FNR{arr[$1]++;next}{for(i=1; i<=NF; i++) if ($i in arr){a[i]++;}} { for (i in a) printf "%s\t", $i; printf "\n"}' phylum_samples.txt final.withtax.v14.tsv > final.phylum.txt')
read.table(file="final.phylum.txt", sep="\t", header=TRUE, row.names="OTU_ID", check.names = FALSE) -> emp.orig_all # this is the offset-calculation-file-table

emp.orig <- droplevels(emp.orig_all[,-2448]) # the awk script adds an NA column to the end, hence I need to remove that here

emp.sum <- apply(emp.orig, 2, sum)
emp.sum.df <- as.data.frame(emp.sum)
emp.sum.df <- droplevels(merge(emp.sum.df, factors, by="row.names", keep=FALSE)) # sum file same obs. order as factor and abundance 
rownames(emp.sum.df) <- emp.sum.df[,1]
emp.sum.df[,1] <- NULL
emp.sum.final <- emp.sum.df[,1]
save(emp.sum.final, file = "emp.sum.final.phylum.RData")

list.data <- list(abundance, factors)
names(list.data) <- c("abundance", "factors")

#Lucas Adds ----
data.index <- NULL
index <- 0
for (i in 1:ncol(abundance)){
  for (z in 1:ncol(factors)){
    index = index + 1
    d <- data.frame(index = index,
                    tax = colnames(abundance)[i],
                    factor = colnames(factors)[z])
    data.index <- rbind(data.index, d)
  }
}

#Save
dir <- "./index/"
dir.create(dir,showWarnings = F)
save(data.index, file = paste(dir, "data.index", ".RData", sep = ""))

save(list.data, file = paste(dir, "list.data", ".RData", sep = ""))



