#setwd("spongeEMPchemistry-master")

dir <-"3.results/phylum.run.ind.test.results/"
files <- list.files(dir)


results.df <- NULL
for (f in files){
  load(paste(dir, f, sep=""))
  results.df <- rbind(results.df, list.data[["data.frame"]])
  rm(list.data)
}
write.table(results.df, file="phylum.results.tsv", sep="\t")
