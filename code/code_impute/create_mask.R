library(reticulate)
library(Matrix)
library(softImpute)
library(R.matlab)
source("softALS_sync.R")
np = import("numpy")

# read TEC data (MATLAB version data)
path = "./madrigal_mat_SH_LT/"

# read command line argument
args = commandArgs(trailingOnly = TRUE)
p = as.integer(args[1])

if(p<10){
  date = paste('090', p, sep='')
} else{
  date = paste('09', p, sep='')
}

TEC_obj = readMat(paste(path,'gps17',date,'g.mat',sep=''))
TEC = TEC_obj$tecData[[7]] # geographical local time TEC whole day data
lat = TEC_obj$tecData[[4]] # latitude
lt = TEC_obj$tecData[[8]] # local time

# basic dim info
m = dim(TEC)[1]
n = dim(TEC)[2]
t = dim(TEC)[3]
fit_t = 288

# create "mask_out" region
set.seed(1) # fix random seed for reproducibility
xnas = is.nan(TEC)
newmiss = array(runif(m*n*t), dim=c(m,n,t)) < 0.2
mask = !xnas & newmiss
rm(.Random.seed, envir=globalenv())
TEC_mask = TEC
TEC_mask[mask] = np$nan 

fname = paste(path,"mask/TEC_",date,"_mask.mat",sep="")
writeMat(fname, tec = TEC, tec_mask = TEC_mask, latitude = lat, local_time = lt)
