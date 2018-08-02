#setwd("spongeEMPchemistry-master")

read.table(file="1.data/shared.raw.data/sponge_samples_and_ML_data.txt", sep="\t", header = TRUE, row.names = 1) -> factors # 2486 x 59
load("3.results/correlation.variables.output/vari.data.combs.RData")

large.effect.size <- vari.data.combs[ which(vari.data.combs$effect.size >= 0.7), ]

drop.list <- c(large.effect.size$v1)

factors2 = factors[,!(names(factors) %in% drop.list)]

write.table(factors2, file="1.data/shared.raw.data/sponge_samples_and_ML_data.filtered.txt", quote=FALSE, sep="\t")
