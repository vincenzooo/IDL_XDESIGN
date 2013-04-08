
;caratteristiche della shell
r0=300.D
a=0.02D
b=0.01D
shellpars=[a,b,r0]
n=1000
th=vector(0d,2*!PI,n+1)
th=th[0:n-1] ;esclude che il secondo estremo compaia (ripetendo lo zero)

;caratteristiche dello strumdnto
rsup=599.6/2 ;raggio soppresso

;;prova a fittare i dati cartesiani da circonferenza perfetta
;dati iniziali
print
print,"--------------------"
print,"--------------------"

cartData=circle(shellPars,th)  ;dati cartesiani
plot,cartData,th,/isotropic,/polar
oplot,[0],[0],psym=4,color=100
print,"dati di partenza:"
print,"xc,yc,r0:",a,b,r0
;media
xav=total(cartData*cos(th))/n
yav=total(cartData*sin(th))/n
rav=total(cartdata)/n
print,"--------------------"
avCircle=circle([xav,yav,rav],th)
res1=avCircle-cartData
print,"average:"
print,"xc,yc,r0:",xav,yav,rav
print,"doppio xc,yc:",xav*2,yav*2
print,"rmedxcyc,rmed2xc2yc:",total(sqrt((avCircle*cos(th)-xav)^2+(avCircle*sin(th)-yav)^2))/n,$
    total(sqrt((avCircle*cos(th)-xav*2)^2+(avCircle*sin(th)-yav*2)^2))/n
print,"residual PV: ",max(res1)-min(res1)
print,"residual rms:",sqrt(total(res1^2)/(n-1))
;fit con limaison analitico
print,"---"
print,"Dati fit analitico limaison"
res1=fitCircleLimaison(th,cartData,xc=xcfit,yc=ycfit,r0=r0fit)
print,"xc,yc,r0:",xcfit,ycfit,r0fit
print,"Errori % su xc,yc,r0:",100.*([xcfit,ycfit,r0fit]-shellpars)/shellpars
print,"residual PV: ",max(res1)-min(res1)
print,"residual rms:",sqrt(total(res1^2)/(n-1))
;fit con fit fourier
;segue lo schema del programma vb
m=(th[n-1]-th[0])/(n-1)
thflat=th-th[0]-dindgen(n)*m
;c0=
;fit con fit ottimizzazione cerchio
range=[[-0.5d,-0.5d,290.d],[0.5d,0.5d,310.d]]
pars=fitCircleLS(th,cartData,nsim=100,itmax=2000,$
  funzione='circle',fom='minquad',range=range)
print,"---"
print,"Dati fit numerico cerchio (simplex)"
print,"xc,yc,r0:",pars[0],pars[1],pars[2]
res1=circle(pars,th)-cartData
print,"Errori % su xc,yc,r0:",100.*(pars-shellpars)/shellpars
print,"residual PV: ",max(res1)-min(res1)
print,"residual rms:",sqrt(total(res1^2)/(n-1))

;; proviamo con dati misurati (cioe' dopo soppressione del raggio)
;; 
measured=circle(shellPars,th)-rsup  ;misure rotondimetro

;;ora dati non circolari
;;prova a fittare i dati misurati

end