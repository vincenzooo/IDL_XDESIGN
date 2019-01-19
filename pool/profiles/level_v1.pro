;
;function level2,y,coeff=coeff
;  ;remove piston, tilt and sag
;  ;(i.e. mean, line and second order legendre polynomial)
;  ;TODO: extend to a generic grade using recursion formola to generate npolinomyal
;  
;  grade=3
;  N=n_elements(Y)
;  yres=Y
;  x=vector(-1.d,1.d,n) ;xvector
;  L=max(x,/nan)-min(x,/nan)
;  coeff=fltarr(grade)
;  
;  ;legendre normalized polynomials
;  Leg0=sqrt(1.d/2)
;  Leg1=x*sqrt(3.d/2)
;  Leg2=(3.*x^2-1)/2*sqrt(5.d/2)
;  
;  a0=total(y*Leg0,/nan)*L/n
;  yres=y-a0*Leg0
;  
;  a1=total(y*Leg1,/nan)*L/n
;  Yres=Yres-a1*Leg1
;
;  a2=total(y*Leg2,/nan)*L/n
;  sag=a2*Leg2
;  Yres=Yres-sag
;  
;  coeff=[a0,a1,a2]
;  
;  return, Yres
;
;end

function level,x,y,coeff=coeff,degree=degree,$
  partialdegree=partialdegree,partialstats=partialstats,$
  index=index,_extra=extra,legendre=legendre
;  perform a fit of y vs x using a polynomial of degree DEGREE.
;  
;KEYWORDS:
;  COEFF: (out) coefficients of the polynomial fit, according to P(x)=sum(coeff[i]*x^i) i=0,DEGREE
;     coefficients are determined by best fit with svdfit. Beware, the canonical basis is not 
;     orthogonal, this means that the coefficients for the best approximation (in sense of least square) 
;     to the n-th degree are not the truncation of the coefficients of an expansion to m-th degree (m>n). 
;  LEGENDRE (TODO): if set, the coefficients returned are the coefficients with respect to the legendre polynomials
;     as returned by Result = LEGENDRE( X, L , /DOUBLE ), where L is the polynomial degree.
;     Note that I don't understand the following (I would expect to get 0)
;     IDL> n=3 & m=5 & print,total(legendre(a,n)*legendre(a,m))
;      1.00701    
;     
;  DEGREE: (in) degree of the polynomial for the fit
;  PARTIALDEGREE: (in) if provided, PARTIALSTATS is evaluated.
;      useful for comparison with the values from the machine (linear leveling <-> partialdegree=1).
;  PARTIALSTATS: (out) array [rms, ra, PV] for the residuals after the subtraction of the first PARTIALDEGREE degrees of the polynomial
;  INDEX: if provided as vector of integers, only the points at that indices are considered for the leveling.

if n_elements(degree) eq 0 then degree=1
if n_elements(index) ne 0 then begin
  xsel=x[index]
  ysel=y[index]
endif else begin
  xsel=x
  ysel=y
endelse

pn=dblarr(n_elements(x),degree+1) ;first n-th basis polynomial over x
n=n_elements(x)
;if keyword_set(legendre) then begin
;  ;build the legendre polynomials to degree, used for reconstruction
;  coeff=dblarr(degree+1)
;  yfit=dblarr(n)
;  for i=0,degree do begin
;    ;pn[*,i]=x^i/total(x^i)
;    pn[*,i]= legendre(x,n)
;    ;calculate coefficients by scalar product     
;    coeff=[coeff,total((y)*pn[*,i])/n_elements(y)]
;    yfit=yfit+coeff*pn[*,i]  
;  endfor    
;end else begin
;  ;build the canonical basis in pn, used for reconstruction
;  for i=0,degree-1 do begin
;    pn[*,i]=x^i/total(x^i)
;  endfor 
;  ;calculate coefficients, it is done independently from the base construction
;  coeff = svdfit(Xsel, Ysel, Degree,yfit=yfit,_extra=extra)
;endelse

if keyword_set(legendre) then begin
  ;message,'fix the function following comments, only a small part is missing'
  ;build the legendre polynomials to degree, used for reconstruction
  ; I first did it in this way:
  ;for i=0,degree do pn[*,i]= legendre(x,n)
  ; and then call svdfit with /legendre
  ; That way does not work:
  ; IDL> x=vector(-1.,1.,100)
  ; x=     -1.00000    -0.979798    -0.959596,.., 0.959596   0.979798      1.00000
  ; IDL> y=legendre(x,2)
  ; Y               FLOAT     = Array[100]
  ; y=      1.00000     0.940006     0.881237,.., 0.881236     0.940006      1.00000
  ; IDL> print,svdfit(x,y,1)
  ;      0.0101010
  ;IDL> print,svdfit(x,y,2)
  ;    0.0101010-2.04422e-008
  ;IDL> print,svdfit(x,y,3)
  ;    -0.500001 1.62772e-007      1.50000
  ;IDL> print,svdfit(x,y,4)
  ;    -0.500001-1.48014e-007      1.50000 5.65276e-007
  ;
  ;This is better (calculate the coefficient by scalar product in function
  ; level):
; 
;  pn[*,i]= legendre(x,i)  
;  coeff[i]=total(y*pn[*,i])/L
;  yfit=yfit+coeff[i]*pn[*,i]
;  
;  gives:
;y1=level(x,y,coeff=c,degree=0,legendre=legendre) & print,c
;     0.028569974
;IDL> y1=level(x,y,coeff=c,degree=1,legendre=legendre) & print,c
;     0.028569974  6.8502187e-010
;IDL> y1=level(x,y,coeff=c,degree=2,legendre=legendre) & print,c
;     0.028569974  6.8502187e-010      0.26335703
;IDL> y1=level(x,y,coeff=c,degree=3,legendre=legendre) & print,c
;     0.028569974  6.8502187e-010      0.26335703  2.9838416e-009
;but not clear why the first coefficient of lagrange(2) is not 0 (not orthogonal?)
; 
;The magnitude of the first term is related to the number of points,
; is it normal for a rounding error to be so large?:
;IDL> n=1 & m=3 & np=100 & x=vector(-1.,1,np) & print,total(legendre(x,n,/doub)*legendre(x,m,/Doub))/(float(np)/2)
;     0.020471356
;IDL> n=1 & m=3 & np=1000 & x=vector(-1.,1,np) & print,total(legendre(x,n,/doub)*legendre(x,m,/Doub))/(float(np)/2)
;    0.0020046789
;IDL> n=1 & m=3 & np=10000 & x=vector(-1.,1,np) & print,total(legendre(x,n,/doub)*legendre(x,m,/Doub))/(float(np)/2)
;   0.00020004664
;IDL> n=3 & m=3 & np=10000 & x=vector(-1.,1,np) & print,total(legendre(x,n,/doub)*legendre(x,m,/Doub))/(float(np)/2),2.d/(2.d*n+1)
;      0.28588579      0.28571429
;            
;Also, the above "works" on -1:1, x should be readapted for the general case
    
    L=2.
    coeff=dblarr(degree+1)
    yfit=dblarr(n)
    for i=0,degree do begin
      pn[*,i]= legendre(x,i,/double)*sqrt(2.d/(2*i+1))
      ;calculate coefficients by scalar product     
      coeff[i]=total(y*pn[*,i])*L/n
      yfit=yfit+coeff[i]*pn[*,i]  
    endfor    
  
end else begin
  ;build the canonical basis in pn, used for reconstruction
  for i=0,degree-1 do pn[*,i]=x^i/total(x^i)
  coeff = svdfit(Xsel, Ysel, Degree+1,yfit=yfit,_extra=extra)
endelse


if n_elements(partialdegree) ne 0 then begin
  reconstructed=dblarr(n_elements(x))
  for i=0,partialdegree do begin
    reconstructed=reconstructed+coeff[i]*pn[*,i]
  endfor
  pr=reconstructed-y
  rms=sqrt(total(pr^2,/nan)/n_elements(pr))
  ra=total(abs(pr),/nan)/n_elements(pr)
  pv=range(pr,/size)
  partialstats=[rms,ra,pv]
endif

return,y-yfit ;return residuals
end

pro test_level
;create a x and y
x=dindgen(100)
y=100+3*x+4*X^2
plot,x,y

;yl piston removed
yl=level(x,y,degree=0,coeff=coeff)
print,yl
oplot,x,yl,color=3
print,coeff

;calling level with degree=1 after calling with deg=0 gives non-zero
; first coefficient.
;The final result is the same as if the leveling1 was directly applied to raw data
;If two consecutive level0 are done, the second don't change the result and gives coeff=0.

;this happens because canonical polynomial are not orthogonal
yl1=level(x,yl,degree=1,coeff=coeff)
print,coeff
yl1=level(x,yl,degree=0,coeff=coeff)
print,coeff
yl1=level(x,yl,degree=0,coeff=coeff)
print,coeff
yl1=level(x,yl,degree=1,coeff=coeff)
print,coeff
yl1b=level(x,y,degree=1,coeff=coeff)
print,coeff
print,yl1,yl1b
plot,yl1-yl1b
print,range(yl1-yl1b)
end

;pro test_level,legendre=legendre
  setstandarddisplay
  legendre=1
  ;create a function that is the 3rd legendre polynomial
  x=vector(-1.,1,100)
  y=legendre(x,2,/double)
  plot,x,y
  
  ctest=[1.,2.,3.]
  Leg0=sqrt(1.d/2)
  Leg1=x*sqrt(3.d/2)
  Leg2=(3.*x^2-1)/2*sqrt(5.d/2)
  ;y=ctest[0]*leg0+ctest[1]*leg1+ctest[2]*leg2
  window,1
  plot,x,level(x,y,coeff=c,degree=1,legendre=legendre),title='Residuals'
  print,"Coefficients from level (degree=1)",c
  stop
  window,2 
  plot,x,y,title='Profile to be fitted'
  oplot,x,c[0]*leg0+c[1]*leg1+c[2]*leg2,color=100,linestyle=2
  window,3 
  plot,x,c[0]*leg0+c[1]*leg1+c[2]*leg2,linestyle=2,title='Hopefully fitting profile'
end

