library(reticulate)
library(Matrix)
library(softImpute)
library(R.matlab)
source("softALS_sync.R")
np = import("numpy")

# read TEC data (MATLAB version data)
path = "./"
date = "0908"
TEC_obj = readMat(paste(path,"gps","17",date,"g.005.mat",sep=""))
TEC = TEC_obj$tecData[[15]] # geographical local time TEC whole day data
lat = TEC_obj$tecData[[6]] # latitude
lt = TEC_obj$tecData[[16]] # local time

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

fname = paste(path,"TEC_",date,"_mask.mat",sep="")
writeMat(fname, tec = TEC, tec_mask = TEC_mask, latitude = lat, local_time = lt)
