library(reticulate)
library(Matrix)
library(R.matlab)
source("softALS_sync.R")
np = import("numpy")
load('tuning_result.RData')

datelist = c(paste("09","0",1:9,sep=""),paste("09",10:30,sep=""))

# read command line argument
args = commandArgs(trailingOnly = TRUE)
p = as.integer(args[1]) # job-id
date = datelist[p]

# load the data
path = "./"
# date = datelist[date]
TEC = readMat(paste(path,"madrigal_mat_SH_LT/mask/TEC_",date,"_mask.mat",sep=""))
TEC_mask = TEC$tec.mask # tec data to fit
TEC = TEC$tec # tec data with observations on the masked region
SH = readMat(paste(path,"madrigal_mat_SH_LT/SH0/SH_",date,".mat",sep=""))
SH = SH[["SH.fit"]]

# remove negative values
TEC[TEC<1e-5] = 1e-5
# TEC_mask[TEC_mask<1e-5] = 1e-5
SH[SH<1e-5] = 1e-5

# basic dim info
m = dim(SH)[1]
n = dim(SH)[2]
t = dim(SH)[3]
fit_t = 288

# param_choice
l3 = 0.030
l2 = 0.268

rseed = 1
scale_TEC = T

# if scaling is needed, we basically 
# standardize all observed pixels with mean/sd of all observed pixels
if (scale_TEC==T){
  TEC = ((TEC)^0.1-1)/0.1 # box-cox transformation, l=0.1
  all_mean = mean(TEC[!is.nan(TEC)])
  all_sd = sd(TEC[!is.nan(TEC)])
  TEC = (TEC - all_mean)/all_sd
  SH = (SH^0.1-1)/0.1
  SH = (SH - all_mean)/all_sd
}

# train model
impute = simpute_ts(x = TEC[,,1:fit_t], igs = SH[,,1:fit_t], l1=0.9, l2=l2, l3=l3, maxit = 2000)


# save imputed result
for(i in 1:288){
  saveimputed = impute[["Impute"]][[i]]
  saveimputed = (saveimputed*all_sd + all_mean)
  saveimputed = (0.1*saveimputed + 1)^(10)
  fname = paste("imputed_result/imputed_",date, "_",i, ".csv",sep="")
  write.csv(saveimputed, fname)
}
