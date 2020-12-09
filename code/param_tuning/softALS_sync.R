library(nloptr)

# softImpute ALS with temporal smoothing and prior information
Frob=function(Uold,Dsqold,Vold,U,Dsq,V){
  denom=sum(Dsqold^2)
  utu=Dsq* (t(U)%*%Uold)
  vtv=Dsqold* (t(Vold)%*%V)
  uvprod= sum(diag(utu%*%vtv))
  num=denom+sum(Dsq^2) -2*uvprod
  num/max(denom,1e-9)
}

# main code
simpute_ts = function(x, igs, l1 = 1.0, l2 = 1.0, l3 = 1.0, r = 180, 
                      thresh = 1e-05, maxit = 100){
  x_size = dim(x)
  m = x_size[1]
  n = x_size[2]
  t = x_size[3]
  if (is.na(t)){
    t = 1
    l2 = 0
    x = array(x, dim = c(m,n,1))
    igs = array(igs, dim = c(m,n,1))
  }
  
  xnas = is.nan(x) # the nan mask
  xfill = x
  
  U = list()
  V = list()
  Dsq = list()
  Impute = list()
  #U_new = list()
  #V_new = list()
  #Dsq_new = list()
  
  # initialize U, V, Dsq
  for (time in 1:t){
    u = matrix(rnorm(m*r),m,r)
    v = matrix(rnorm(n*r),n,r)
    U[[time]] = svd(u)$u
    V[[time]] = svd(v)$u
    Dsq[[time]] = rep(1,r)
    Impute[[time]] = U[[time]]%*%(rep(1,r)*t(V[[time]])) 
  }
  
  xfill[xnas] = 0
  ratio = rep(1,t)
  ratio_hist = c()
  iter = 1
  loss_hist = c()
  
  while((iter < maxit) & (max(ratio) > thresh)){
    iter = iter + 1
    U_old = U
    V_old = V
    Dsq_old = Dsq
    Impute_old = Impute
    
    # calculate the current loss
    loss = 0
    for (time in 1:t){
      A_t = U_old[[time]] %*% sqrt(Dsq_old[[time]])
      B_t = V_old[[time]] %*% sqrt(Dsq_old[[time]])
      x_star = Impute_old[[time]]
      resid_mat = x[,,time] - x_star
      resid_mat[xnas[,,time]] = 0
      loss = loss + norm(resid_mat, type="F") + 
        l1*(norm(A_t, type = "F") + norm(B_t, type = "F")) +
        l3*norm(igs[,,time]-x_star, type = "F")
      if (l2!=0){
        if (time>=2){
          loss = loss + l2*norm(x_star-Impute_old[[time-1]], type = "F")
        }
      }
    }
    loss_hist = c(loss_hist, loss/2)
    
    # U step for all time points
    for (time in 1:t){
      fill = xfill[,,time]
      fill_na = xnas[,,time]
      u = U[[time]]
      dsq = Dsq[[time]]
      v = V[[time]]
      
      if (t==1){
        ts = 0
        const = 1 + l3
      }else if (time==1){
        ts = Impute[[time+1]]*l2
        const = 1 + l2 + l3
      }else if (time==t){
        ts = Impute[[time-1]]*l2
        const = 1 + l2 + l3
      }else{
        ts = (Impute[[time+1]]*l2 + Impute[[time-1]]*l2)
        const = 1 + l2 + l2 + l3
      }
      
      B = t(u)%*%(fill + ts + l3*igs[,,time])
      B = B*dsq/(const*dsq+l1)
      Bsvd = svd(t(B))
      v=Bsvd$u
      dsq=(Bsvd$d)
      u=u%*%Bsvd$v
      xhat=u %*%(dsq*t(v))
      Impute[[time]] = xhat
      fill[fill_na] = xhat[fill_na]
      U[[time]] = u
      V[[time]] = v
      Dsq[[time]] = dsq
      xfill[,,time] = fill
    }
    
    # Impute_old = Impute
    
    # V step for all time points
    for (time in 1:t){
      fill = xfill[,,time]
      fill_na = xnas[,,time]
      u = U[[time]]
      dsq = Dsq[[time]]
      v = V[[time]]
      
      if (t==1){
        ts = 0
        const = 1 + l3
      }else if (time==1){
        ts = Impute[[time+1]]*l2
        const = 1 + l2 + l3
      }else if (time==t){
        ts = Impute[[time-1]]*l2
        const = 1 + l2 + l3
      }else{
        ts = (Impute[[time+1]]*l2 + Impute[[time-1]]*l2)
        const = 1 + l2 + l2 + l3
      }
      
      A = t((fill+ ts + l3*igs[,,time])%*%v)
      A = A*dsq/(const*dsq+l1)
      Asvd=svd(t(A))
      u=Asvd$u
      dsq=Asvd$d
      v=v %*% Asvd$v
      xhat=u %*%(dsq*t(v))
      Impute[[time]] = xhat
      fill[fill_na] = xhat[fill_na]
      U[[time]] = u
      V[[time]] = v
      Dsq[[time]] = dsq
      xfill[,,time] = fill
    }
    
    for (time in 1:t){
      ratio[time] = Frob(U_old[[time]], Dsq_old[[time]], V_old[[time]],
                         U[[time]], Dsq[[time]], V[[time]])
    }
    ratio_hist = c(ratio_hist,max(ratio))
    #U = U_new
    #V = V_new
    #Dsq = Dsq_new
  }
  
  U_final = list()
  V_final = list()
  Dsq_final = list()
  Impute_final = list()
  
  for (time in 1:t){
    u = xfill[,,time]%*%V[[time]]
    sU = svd(u)
    u=sU$u
    dsq=sU$d
    v=V[[time]]%*%sU$v
    dsq = pmax(dsq-l1,0) # soft-thresholding
    rout = min(sum(dsq>0)+1, r)
    U_final[[time]] = u[,seq(rout)]
    Dsq_final[[time]] = dsq[seq(rout)]
    V_final[[time]] = v[,seq(rout)]
    Impute_final[[time]] = u[,seq(rout)]%*%(dsq[seq(rout)]*t(v[,seq(rout)]))
  }
  
  return(out=list(U=U_final,V=V_final,Dsq=Dsq_final,
                  Impute=Impute_final,iter=iter, ratio=ratio, 
                  ratio_hist=ratio_hist, loss_hist=loss_hist))
}
