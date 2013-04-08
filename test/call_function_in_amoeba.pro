function _lssq,spherepars
  ;return the square sum of deviation from sphere.
  ;spherepars=[xc,yc,zc,R]
  common tofunk, surfpoints,pweight
  
  return,total((randomu(seed,10)^2))
end

function protozoo,function_name=func,p0=p0
  common tofunk, surfpoints,pweight
  
  ndim=4
  mpts=ndim+1
  
  p = p0 # replicate(1.0, ndim+1)
  
  y = replicate(call_function(func, p[*,0]), mpts)  ;Init Y to proper type
  
  help,func
  help,y
  return,'end'
end

