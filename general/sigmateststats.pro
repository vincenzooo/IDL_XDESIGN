pro sigmaTestStats,vector,$
  average=average,sigma=sigma,deltamax=deltamax,deltamin=deltamin,$
  relsigma=relsigma, deltarelmax=deltarelmax,deltarelmin=deltarelmin
  ;given a vector of data, return a vector with statistical
  ;information:
  ;average, sigma, max, min, sigma relative, delta max rel., delta min rel.

  npoints=n_elements(vector)
  average=total(vector)/npoints
  sigma=sqrt(total((vector-average)^2)/(npoints-1))
  relsigma=sigma/average
  deltamax=max(vector-average)
  deltamin=min(vector-average)
  deltarelmax=deltamax/average
  deltarelmin=deltamin/average
end