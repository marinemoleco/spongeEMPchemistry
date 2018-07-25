setwd("~/work/chemistry/v3/correlation/")

read.table("Metadata_manually_checked3.tsv", sep="\t", header = TRUE, row.names = 1) -> vari.data

combs <- combn(colnames(vari.data), 2)

vari.data.combs <-NULL

library(vcd)


for (i in 1:ncol(combs)){
# Get variables name
v1 <- combs[1,i]
v2 <- combs[2,i]


#Get variables data

v1d <- vari.data[,v1]
v2d <- vari.data[,v2]


# Do Kendals correltion if variables' data are both numeric
if (!is.numeric(v1d) & !is.numeric(v2d)){

  tbl <- table(vari.data[, c(v1, v2)])
  #Do the test
  f <- paste(v1, "~", v1)
  test <- chisq.test(tbl) # non-parametric
  value <- assocstats(tbl)$cramer
  sig <- test$p.value
  test.value <- "Cramer's V"
  test.sig <- "Chi-squared"

}

# Gather info out the iteration
d <- data.frame( v1= v1, v2 = v2, effect.size=value, significance=sig,
                 test.e.s=test.value, test.s=test.sig, stringsAsFactors = F)
vari.data.combs <- rbind(vari.data.combs, d)
}
