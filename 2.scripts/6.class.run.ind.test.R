#setwd("spongeEMPchemistry-master")

library(mvabund)

#Read input ----
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "out.txt"
}

rodada=as.numeric(args[1])


# load

load("3.results/class.create.data.output/emp.sum.final.class.RData")
load("3.results/class.create.data.output/index/data.index.RData")
load("3.results/class.create.data.output/index/list.data.RData")

abundance <- list.data[["abundance"]]
factors <- list.data[["factors"]]

# Set  variables

name.tax <- as.character(data.index[rodada, "tax"])
name.fac <- as.character(data.index[rodada, "factor"])

tax <- abundance[, name.tax]
fac <- factors[, name.fac]
data2test <- data.frame(cbind(tax, fac, emp.sum.final)) 
colnames(data2test) <- c(name.tax, name.fac, "lib")

##

# Set formula
fm <- as.formula(paste(name.tax, "~", name.fac))
#Set model
model <- manyglm(fm, offset = log(lib), data = data2test)

#Do anova
an <- anova(model, nBoot = 1)
p=an$table[rownames(an$table)==name.fac,"Pr(>Dev)"]
df=an$table[rownames(an$table)==name.fac,"Df.diff"]

s=tryCatch({summary(model, nBoot = 1)}, error=function(e){a=NA})
coef=tryCatch({s$est[rownames(s$est) == name.fac, name.tax]}, error=function(e){a=NA})
se=tryCatch({s$est.stderr[rownames(s$est.stderr) == name.fac, name.tax]}, error=function(e){a=NA})
wald=tryCatch({s$coefficients[rownames(s$coefficients)== name.fac, "wald value"]}, error=function(e){a=NA})


d <- data.frame(name.factpr = name.fac, name.taxon  = name.tax, p.value =  p, df = df, coef = coef, se = se, wald= wald)

list.data <- list(d, fm, model, an, s)
names(list.data) <- c( "data.frame", "formula", "model", "anova", "summary")

#Save
dir <- "3.results/class.run.ind.test.results/"
dir.create(dir,showWarnings = F)

save(list.data, file = paste(dir, rodada, ".",  name.tax, ".", name.fac, ".RData", sep = ""))

