#setwd("spongeEMPchemistry-master")

load(file="3.results/otu.create.data.output/factors.RData")
load(file="3.results/otu.create.data.output/abundance.RData")

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
dir <- "3.results/otu.create.data.output/index/"
dir.create(dir,showWarnings = F)

save(data.index, file = paste(dir, "data.index", ".RData", sep = ""))
save(list.data, file = paste(dir, "list.data", ".RData", sep = ""))
