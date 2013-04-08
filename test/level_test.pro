
function level,x,y,coeff=coeff,degree=degree,svd=svd
if n_elements(degree) eq 0 then degree=2
if keyword_set(svd) then begin
  print,'SVD'
  coeff = SVDFIT(X, Y, Degree+1,yfit=yfit)
endif else begin
  print,'Poly_fit'
  coeff = POLY_FIT(X, Y, Degree,yfit=yfit)
endelse
return,y-yfit ;return residuals
end

setstandarddisplay
x_roi=vector(-1.d,1.d,1000)
y_roi=3.*legendre(x_roi,2,/double)-2.*legendre(x_roi,4,/double)

;leveling
yor=y_roi
y_roi=level(x_roi,y_roi,coeff=coeff,degree=2) ;level(y_roi,coeff=coeff)
coeff=reform(coeff,3)

y_svd=level(x_roi,y_roi,coeff=coeffSVD,degree=2,/svd)
;SET_PLOT, 'PS'
;DEVICE, filename='fit_A01_90F_L.eps', /COLOR,/encapsulated  
plot,x_roi,yor,yrange=range([yor,y_roi]),background=255,color=0
oplot,x_roi,y_roi,color=50
oplot,x_roi,y_svd,color=100
oplot,x_roi,coeff[0]+coeff[1]*x_roi+coeff[2]*x_roi^2,color=2
oplot,x_roi,coeffSVD[0]+coeffSVD[1]*x_roi+coeffSVD[2]*x_roi^2,color=3
legend,['data','poly_fit','SVDfit','residuals Poly','residuals SVD'],$
  color=[0,50,100,2,3],position=6
;  DEVICE, /CLOSE 
;  SET_PLOT_default


end