library(reticulate)
library(Matrix)
library(R.matlab)
source("softALS_sync.R")
np = import("numpy")
# load('tuning_result.RData')

datelist = c()
daylist = c(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
for(i in 1:12){
  for (j in 1:daylist[i]){
    if (i<10 & j<10){
      date = paste('0',i,'0',j, sep='')
      datelist = c(datelist, date)
    }else if (i<10 & j>=10){
      date = paste('0',i,j, sep='')
      datelist = c(datelist, date)
    }else if (i>=10 & j<10){
      date = paste(i,'0',j, sep='')
      datelist = c(datelist, date)
    }else{
      date = paste(i,j, sep='')
      datelist = c(datelist, date)
    }
  }
}

# read command line argument
args = commandArgs(trailingOnly = TRUE)
p = as.integer(args[1]) # job-id
# p = p+31+62+50+50+50+30+80
# datelist = c('0216', '0218','0228','0301','0302','0307','0414','0429','0503','0515','0626','0704','0710','0803','0805','0828','0829','1006','1115','1120','1129','1201','1208','1218','1219','1227')
date = datelist[p]

# load the data
path = "./"
# date = datelist[date]
TEC = readMat(paste(path,"madrigal_mat_SH_LT/2017/gps17",date,"g.mat",sep=""))
TEC = TEC[["tecData"]][[7]] # tec data with observations on the masked region
SH = readMat(paste(path,"madrigal_mat_SH_LT/SH_2017/SH_17",date,".mat",sep=""))
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
l1 = 0.9

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
impute = simpute_ts(x = TEC[,,1:fit_t], igs = SH[,,1:fit_t], l1=l1, l2=l2, l3=l3, maxit = 2000)


# save imputed result
imputed_map = array(NA, dim=c(181, 361, 288))

for (i in 1:288){
  imputed_i = impute[["Impute"]][[i]]
  imputed_i = (imputed_i*all_sd + all_mean)
  imputed_i = (0.1*imputed_i + 1)^(10)
  imputed_map[,,i] = imputed_i
}


fname = paste("imputed_result/2017/imputed_17",date, ".mat",sep="")
writeMat(fname, imputed = imputed_map)

