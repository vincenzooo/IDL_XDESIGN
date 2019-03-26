function primitive,alpha,theta,alpha_i

if alpha_i le alpha-theta then return, -alpha*!PI/2
if alpha_i ge alpha then return,alpha_i=-theta

return,-sqrt(-(alpha-alpha_i)^2+theta^2)+alpha*atan((-alpha+alpha_i)$
    /sqrt(-(alpha-alpha_i)^2+theta^2))

;it would be, for alpha_i>alpha (the first term changes sign)
;p=sqrt(-(alpha-alpha_i)^2+theta^2)+alpha*atan((-alpha+alpha_i)$
;    /sqrt(-(alpha-alpha_i)^2)+theta^2)

end


function distrib_primitive,slope, offAxisAng, impactAng,nonormalize=nonormalize
  ;calculate the probability for the impact angle
  ;in the interval defined by the 2 elements vector impactAng=[start,end].
  ;A 2-el slice can be passed, e.g. to cycle over a vector to integrate.
  ;Uses the primitive of the distribution formula in SPIE 2010.
  ;Valid for alpha-theta<=alpha_i<=alpha
  
  theta=offAxisAng
  alpha_i=impactAng
  alpha=slope
  
  ;the limit of the primitive for alpha_i->alpha-theta is  -alpha*!PI/2
  
  if keyword_Set(nonormalize) then norm = 1.0 $ 
  else norm=1./(!PI/2*alpha-theta)

  
  return, norm*(primitive(alpha,theta,alpha_i[1])-primitive(alpha,theta,alpha_i[0]))
  
end

np=100
alpha=0.0037
theta=3./60*!PI/180
x=vector(alpha-theta,alpha,np)
y=fltarr(np-1)
for i=0,np-2 do begin
  y[i]=distrib_primitive(alpha,theta,x[i:i+1])
endfor
step=theta/np
x2=x[0:np-2]+step/2.

plot,x2,y,psym=10
print,total(y)
end
