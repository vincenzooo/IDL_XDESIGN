function fitCircleLimaison,th,cartData,xc=xcfit,yc=ycfit,r0=r0fit

n=n_elements(th)
xcfit=2*total(cartData*cos(th))/n
ycfit=2*total(cartData*sin(th))/n
r0fit=total(cartdata)/n
return,circle([xcfit,ycfit,r0fit],th)-cartData
end