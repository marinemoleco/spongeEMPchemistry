#setwd("spongeEMPchemistry-master")

##paths

dir <- "3.results/otu.create.data.output/"

#after running 1.filter.awk.sh

read.table(file="2.scripts/4.otu.create.offset/final.otu.txt", sep="\t", header=TRUE, check.names = FALSE) -> emp.orig_all # this is the data for the offset-calculation-file-table
load(file="3.results/otu.create.data.output/factors.RData")

emp.orig <- droplevels(emp.orig_all[,-2420]) # the awk script adds an NA column to the end, hence I need to remove that here

emp.sum <- apply(emp.orig, 2, sum, na.rm=TRUE)
emp.sum.df <- as.data.frame(emp.sum)
emp.sum.df <- droplevels(merge(emp.sum.df, factors, by="row.names", keep=FALSE)) # sum file same obs. order as factor and abundance 
rownames(emp.sum.df) <- emp.sum.df[,1]
emp.sum.df[,1] <- NULL
emp.sum.final <- emp.sum.df[,1]

save(emp.sum.final, file = paste(dir, "emp.sum.final.otu", ".RData", sep = ""))
rm(dir)
