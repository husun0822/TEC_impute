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
SH = readMat(paste(path,"madrigal_mat_SH_LT/SH/SH_",date,".mat",sep=""))
SH = SH[["SH.fit"]]

# remove negative values
TEC[TEC<1e-5] = 1e-5
TEC_mask[TEC_mask<1e-5] = 1e-5
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
  TEC_mask = ((TEC_mask)^0.1-1)/0.1 # box-cox transformation, l=0.1
  all_mean = mean(TEC_mask[!is.nan(TEC_mask)])
  all_sd = sd(TEC_mask[!is.nan(TEC_mask)])
  TEC_mask = (TEC_mask - all_mean)/all_sd
  SH = (SH^0.1-1)/0.1
  SH = (SH - all_mean)/all_sd
}

# train model
impute = simpute_ts(x = TEC_mask[,,1:fit_t], igs = SH[,,1:fit_t], l1=0.9, l2=l2, l3=l3, maxit = 2000)
df = NULL

for (frame in 1:fit_t){
  imputation = impute$Impute[[frame]]
  if (scale_TEC==T){
    imputation = (imputation*all_sd + all_mean)
    imputation = (0.1*imputation + 1)^(10) # reverse box-cox transformation
  }
  orig = TEC[,,frame]
  test_set = !is.nan(orig) & is.nan(TEC_mask[,,frame])
  rse = norm(as.matrix((orig-imputation)[test_set]), type = "F")/norm(as.matrix(orig[test_set]), type = "F")
  df = rbind(df, c(l2, l3, frame, rse, impute$iter))
}

df = data.frame(df)
colnames(df) = c("lambda_2","lambda_3","frame","test_RSE","iter")
output_path = "./result/l2l3_fixed/"
fname = paste(output_path, date, '_l2l3', ".csv",sep="")
write.csv(df, fname)

