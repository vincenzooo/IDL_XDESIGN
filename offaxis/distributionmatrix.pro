function distributionMatrix,alpha,thetaVec,locations=locations,trimfactor=trimfactor
  
  ;given a shell slope alpha, return a matrix with in rows the distribution 
  ;of incidence angles for each value of offAxis angle theta in thetaVec.
  ;if locations is set return the values of incidence angles used for the bins.
  
  ntheta=n_elements(thetaVec)
  dMatrix=fltarr(ntheta,ntheta)
  
  tmp=oaangleDistr(alpha,abs(thetaVec[0]),nbins=ntheta,locations=a1x)
  x=fix(findex(alpha+thetaVec,a1x))
  dMatrix[0,x]=tmp
  
  for i =1,ntheta-1 do begin
    tmp=oaangleDistr(alpha,abs(thetaVec[i]),nbins=ntheta,locations=a1x)
    x=fix(findex(alpha+thetaVec,a1x))
    dMatrix[i,x]=tmp
  endfor
  locations=a1x
  return, dMatrix
  
end

      