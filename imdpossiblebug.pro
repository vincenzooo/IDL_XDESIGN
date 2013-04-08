;riproduce il problema con imd

th_deg=findgen(201)/100
th=90.-th_deg
z=[300.]
materials=['a-C','Pt','Si']
sigma=10.		;the problem disappear if you put sigma=0,
;using 1 as interface reduces the problem, also if it should be the
;default.
lam=12.398425/2.98
nc=complexarr(4,1)
vac=complexarr(1)+1.
nc[0,*]=vac
nc[1,*]=IMD_NK('a-C',lam)
nc[2,*]=IMD_NK('Pt',lam)
nc[3,*]=IMD_NK('Si',lam)


fresnel,th, lam, nc,[80.,300.],sigma,1,ra=R_coated
plot,90-th,r_coated
print, nc

end

