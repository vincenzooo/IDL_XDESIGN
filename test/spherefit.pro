function _lssq,spherepars
  ;return the square sum of deviation from sphere.
  ;spherepars=[xc,yc,zc,R]
  common tofunk, surfpoints,pweight
  
  npoints3=(size(surfpoints,/dime))[0] ;n_elements(surfpoints)/3
  ndim=n_elements(surfpoints)/npoints3
  spherepoints=transpose(rebin(spherepars[0:2],ndim,npoints3))
  delta=sqrt(total((spherepoints-surfpoints)^2,2))-spherepars[3]
  return,total((delta*pweight)^2)
end

function sphereFit,points,residuals=residuals,toll=toll,guess=guess,_extra=extra,$
                   amoeba=am,weight=weight,fom=fom
  
  ;fom is a string containing a name of a procedure for the calculation of the fom.
  ; Default value '_lssq'.
  ;if /amoeba is set, uses amoeba algorithm, otherwise uses powell.
  
  common tofunk, surfpoints,pweight
  surfpoints=points
  npoints=(size(surfpoints,/dimensions))[0]
  ndim=n_elements(surfpoints)/npoints
  if n_elements(toll) eq 0 then toll=1e-12
  
  if n_elements(weight) eq 0 then  pweight=replicate(1.,npoints) else pweight=weight
  if n_elements(guess) ne 0 then guess=guess else begin 
    ;guess the center of sphere by combining two 2-d fit
    x=surfpoints[*,0]
    y=surfpoints[*,1]
    xy=transpose([[x],[y]])
    z=surfpoints[*,2]
    npline=20
    yline=vector(min(y),max(y),npline)
    xline=vector(min(x),max(x),npline)
    xcenter=total(range(x))/2
    ycenter=total(range(y))/2
    
    xprofile=griddata(xy,z,/grid,xout=[xcenter],yout=yline)   
    yprofile=griddata(xy,z,/grid,xout=[xline],yout=[ycenter])
    
    xfit=fit_circle(xline,xprofile)
    xguess=[xfit[0],ycenter,xfit[1],xfit[2]]
    yfit=fit_circle(yline,yprofile)
    yguess=[yfit[0],xcenter,yfit[1],yfit[2]]
    
    guess=(xguess+yguess)/2
    
  endelse
  print,'starting guess value'+strjoin(string(guess))
  ;guess=[10d,15.d,1000.d,900d]
  if n_elements(fom) eq 0 then fom='_lssq'
  if keyword_set(am) then begin
    result=amoeba(toll,function_name=fom,p0=guess,$
    scale=guess,nmax=500,simplex=final,FUNCTION_VALUE=fom)
    if n_elements(result) eq 1 then begin
      if result eq -1 then begin
        print,'non converging result, best result:'
        print,final[*,0]
        print,'FOM=',fom[0]
        print
        print,'(COMPLETE SIMPLEX:'
        print,final
        print, 'FUNCTION VALUES:'
        print, fom,')'
      endif else begin
        print,'solution found, best result:'
        print,result
        print,'FOM=',fom[0]
      endelse
    endif else begin
        print,'solution found, best result:'
        print,result
        print,'FOM=',fom[0]
    endelse  
    result=final[*,0]
  endif else begin
    xi=[[1.0,0.0,0.0,0.0],[0.0,1.0,0.0,0.0],[0.0,0.0,1.0,0.0],[0.0,0.0,0.0,1.0]]
    powell,guess, Xi, toll, Fmin, '_lssq',/double
    result=guess
  endelse
  
  print,'sphere fit result:'+strjoin(string(result))
  
  cp=rebin(result[0:n_elements(result)-2],ndim,npoints) ;replicate the center point to use for radius
  trans=transpose(surfpoints)-cp
  sppoints=CV_COORD(from_rect=trans,/to_sphere) ;polar coordinates of point wrt center, sppoints[ndim-1,*] is the radius of the surface points
  residuals=result[n_elements(result)-1]-sppoints[ndim-1,*] 
  ;however this should change sign if the surface is convex, the next line should do the work (not tested)
  if result[ndim-2] lt 0 then residuals=-residuals
  
  return,result
  
end

pro test_spherefit

  cr=[11d,18.d,1100.d,1000d] ;coordinates of center and radius in mm, mm, mm, mm
  ;x and y coordinates of points
  xgrid=vector(-40.,60,100)
  ygrid=vector(-30.,70,100)
  xy=grid(xgrid,ygrid)
  ;create a random perturbation on the xy grid (pm 0.5 micron= 0.0005 mm)
  pert=(randomu(1,n_elements(xy[*,0]),/double)-0.5)*0.001
  ;pert=pert*0
  ;build surface, sphere +perturbation
  z=cr[2]-sqrt(cr[3]^2-(xy[*,0]-cr[0])^2-(xy[*,1]-cr[1])^2)+pert
  
  cgsurface,reform(z,[n_elements(xgrid),n_elements(ygrid)]),xgrid,ygrid
  
  result=spherefit([[xy],[z]],residuals=residuals)
  res=reform(residuals,n_elements(xgrid),n_elements(ygrid))
  print,result
  setstandarddisplay,/notek
  
  zr=range(pert)
  if zr[1]-zr[0] eq 0 then zr=[0,0.0000000001] 
  window,1
  cgimage, res, position=plotpos, /Save,/scale,$
          /Axes,/keep_aspect,minus_one=0,xrange=range(xgrid),yrange=range(ygrid),$
          minvalue=zr[0],maxvalue=zr[1],$
          AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',title:'Residuals'}
  if n_elements(divisions) eq 0 then divisions=6
  if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
  cgcolorbar,/vertical,range=zr,divisions=divisions,$
          format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
          ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
          
  window,2
  cgimage, reform(-pert,size(res,/dimension)), position=plotpos, /Save,/scale,$
          /Axes,/keep_aspect,minus_one=0,xrange=range(xgrid),yrange=range(ygrid),$
          minvalue=zr[0],maxvalue=zr[1],$
          AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',title:'Perturbations'}
  if n_elements(divisions) eq 0 then divisions=6
  if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
  cgcolorbar,/vertical,range=zr,divisions=divisions,$
          format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
          ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
  
  window,3
  zr=range(res-reform(pert,size(res,/dimension)))
  cgimage, res-reform(pert,size(res,/dimension)), position=plotpos, /Save,/scale,$
          /Axes,/keep_aspect,minus_one=0,xrange=range(xgrid),yrange=range(ygrid),$
          minvalue=zr[0],maxvalue=zr[1],$
          AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',title:'Difference'}
  if n_elements(divisions) eq 0 then divisions=6
  if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
  cgcolorbar,/vertical,range=zr,divisions=divisions,$
          format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
          ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
end

test_spherefit

end