#setwd("spongeEMPchemistry-master")

##### phylum #####

as.data.frame(t(read.table(file="1.data/phylum.raw.data/phylum_level.txt", sep="\t", header=TRUE, row.names = 1, check.names = FALSE))) -> abundance_orig # 2486 x 63
read.table(file="1.data/shared.raw.data/sponge_samples_and_ML_data.filtered.txt", sep="\t", header = TRUE, row.names = 1) -> factors # 2486 x 57 # updated filtered file

# cleanup abundance table if necessary
abundance_orig -> abundance

abundance <- droplevels(abundance[rowSums(abundance) !=0, ]) # 2478 x 63
abundance <- droplevels(abundance[, colSums(abundance) !=0 ]) # 2478 x 53

fac_abund_merge <- droplevels(merge(factors, abundance, by="row.names", keep=F)) # 2478 x 111
rownames(fac_abund_merge) <- fac_abund_merge[,1] #
fac_abund_merge$Row.names <- NULL # 2478 x 110
factors <- droplevels(fac_abund_merge[,1:57]) # 2478 x 57

library(plyr)
# data transformation summarise taxa abundance and factors
# abundance data - long and complicated
hostID <- as.data.frame(factors$host_scientific_name)
rownames(hostID) <- rownames(factors)
factors$host_scientific_name <- NULL # 2478 x 56

# keep sponge taxa > 2
names(hostID)[1] <- "taxa"
hostID$names <- rownames(hostID) # 2478
hostID <- droplevels(data.frame(hostID[hostID$taxa %in% names(which(table(hostID$taxa) > 2)), ])) # 2447
hostID$names <- NULL

#short factors here
factors_short <- merge(hostID, factors, by="row.names", keep=FALSE) # 2447 x 58
factors_short$taxa <- NULL # 2447 x 57
rownames(factors_short) <- factors_short[,1]
factors_short$Row.names <- NULL
factors <- droplevels(factors_short) # 2447 x 56

abundance <- merge(abundance, factors, by="row.names", keep=FALSE) # 2478 x 53 -> 2447 x 110
rownames(abundance) <- abundance[,1]
abundance[,1] <- NULL # 2447 x 109
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

factors <- droplevels(fac) # 2447 x 55
abundance <- droplevels(abundance)
hostID <- droplevels(hostID)

rm(fac_abund_merge)
rm(abundance_orig)
rm(factors_short)
rm(results)
rm(fac)

row_names <- data.frame(rownames(abundance))
write.table(row_names, file="2.scripts/4.phylum.create.offset/phylum_samples.txt", row.names = F, quote=FALSE, sep="\t") # save sample IDs to create with final.withtax.v14.tsv.tar.gz the offset-calculation-file-table

dir <- "3.results/phylum.create.data.output/"
dir.create(dir,showWarnings = F)

save(abundance, file="3.results/phylum.create.data.output/abundance.RData")
save(factors, file="3.results/phylum.create.data.output/factors.RData")
