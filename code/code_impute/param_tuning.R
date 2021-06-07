# empirical analysis on real-data: TEC median-filtered data
library(reticulate)
library(Matrix)
library(R.matlab)
source("softALS_sync.R")
np = import("numpy")

datelist = c(paste("09","0",1:9,sep=""),paste("09",10:30,sep=""))
which2tune = c(2,3)
number_lambda = 1:100
param_table = expand.grid(number_lambda, which2tune, datelist)

# read command line argument
args = commandArgs(trailingOnly = TRUE)
p = as.integer(args[1]) # job-id
p = p+3000
numoflambda = param_table[p, 1] # which one of the lambda2/3
date = param_table[p, 3] # date-id
which2tune = param_table[p, 2] # indicator of which param to tune, 2 for lambda_2, 3 for lambda_3

# load the data
path = "./"
date = datelist[date]
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
l3 = seq(0.001,0.05,length.out = 100)
l2 = seq(0.01,1,length.out = 100)

# choose the parameter to tune
if (which2tune==2){
  l2_choice = l2[numoflambda]
  l3_choice = 0
}else{
  l2_choice = 0
  l3_choice = l3[numoflambda]
}

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
impute = simpute_ts(x = TEC_mask[,,1:fit_t], igs = SH[,,1:fit_t], l1=0.9, l2=l2_choice, l3=l3_choice, maxit = 2000)
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
  df = rbind(df, c(l2_choice, l3_choice, frame, rse, impute$iter))
}

df = data.frame(df)
colnames(df) = c("lambda_2","lambda_3","frame","test_RSE","iter")
output_path = "./result/lambda"
fname = paste(output_path, which2tune,'/',date,'_', numoflambda, ".csv",sep="")
write.csv(df, fname)

