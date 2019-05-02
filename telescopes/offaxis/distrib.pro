function distrib,slope, offAxisAng, impactAng,nonormalize=nonormalize
  ;+
  ;return the distribution of slope.
  ;  return component N eq.7 in paper cotroneo 2010 SPIE 
  ;  (primary impact angle probability distribution),
  ;  unless nonormalize is set, in which case return only the
  ;  first factor (not sure what it is for). 
  ;  
  ;Formula is valid for alpha-theta<=alpha_i<=alpha
  ;
  ;I don't see this function used anywhere, it is rather used distributionMatrix
  ;-
  theta=offAxisAng
  alpha_i=impactAng
  alpha=slope
  
  nonvalid=where ((alpha_i lt alpha-theta) or (alpha_i gt alpha),count)
  if count ne 0 then begin
    print, "alpha= ",alpha
    print, "theta (off-axis)=",theta
    print, "alpha_i (independent variable) in range ",min(alphas_i),"--",max(alpha_i)
    print, "for index ",nonvalid
    print, "square root is negative, alpha_i="
    print, alpha_i[nonvalid]
    print, "alpha_i should be in the range [",alpha-theta,",",alpha+theta,"]"
    message, "function <distrib>: error, the value under square root is less than zero."
  endif
  
  if keyword_Set(nonormalize) then norm=1.0 $ 
  else norm=1./(!PI/2*alpha-theta)

  factor=alpha_i/sqrt(theta^2-(alpha_i-alpha)^2)
  return, norm*factor
  
end