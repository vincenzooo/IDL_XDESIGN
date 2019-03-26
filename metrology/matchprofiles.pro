
; Fit x and y offsets and a scale factor to match two profiles.
; The values returned are the values to be applied to the 's' profile 
; to make it match to the 'm' profile.
; The returned profile is the 's' profile with the transformation applied 
; and resampled on the coordinate x of the 'm' profile. 

function funk,pars
  common points, xs,ys,xm,ym
  xoffset=pars[0]
  yoffset=pars[1]
  if n_Elements(pars) gt 2 then scale=pars[2] else scale = 1.0
  
  ysim_int=interpol(ys,xs+xoffset,xm)  ;V, X, XOUT

  rms=total((ym-ysim_int*scale-yoffset)^2)
  ;plot,xm,ym,title=string(rms),back=255
  ;oplot,xm,ysim_int*scale+yoffset,color=200
  return, rms
  
end

function matchprofiles, xsim,ysim,xmeas,ymeas,p0,fomscale,outfile=outfile,$
                    best=best

common points, xs,ys,xm,ym

xs=xsim
ys=ysim
xm=xmeas
ym=ymeas

pars= AMOEBA( 10^(-6) ,FUNCTION_NAME='funk',  NMAX=50000, P0=p0, SCALE=fomscale,$
      SIMPLEX=simplex)
best=simplex[*,0]
if n_elements(best) eq 2 then best=[best,1.0] 
fit_profile=ys*best[2]+best[1]

if n_elements(pars) eq 1 then print,'FIT not converging!'
print,"BEST FIT:",best

plot,xm,ym, xtitle='Y(mm)',ytitle='Z(um)'
oplot,xs+best[0],fit_profile,color=200

if n_elements(outfile) ne 0 then $
writecol, outfile ,xs+best[0],fit_profile,$
          header='xsim(mm)  ysim(um)  pars:'+strjoin(string(best))

return,fit_profile
end
