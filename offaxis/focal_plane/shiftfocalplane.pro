pro shiftFocalPlane,deltaz,x,y,cosx1,cosy1,cosz1,xstart=xstart,ystart=ystart,plot=plot,window=wnumber
	;shift the focal plane in z direction, positive from optics to focal plane
	;return the new photon positions in x and y
	;the starting values are copied in xstart and ystart.
	;N.B.: the first axis in the fortran program (x) corresponds
	;to the optical axis direction (z, here).
	
	; N.B.: modificato il 2/10/09,
	; prima funzionava usando x e y solo se xstart ed ystart non erano forniti.
	
  xstart=x
  ystart=y
  
  if n_elements(deltaz) gt 1 then begin
    print, "deltaz, first argument of routine shiftFocalPlane, is not a scalar"
    help, deltaz
    stop
  endif

	t=deltaz/cosz1
	x=x+t*cosx1
	y=y+t*cosy1

	if n_elements(plot) ne 0 then begin
		if n_elements (wnumber) ne 0 then window,wnumber
		plot,x,y,title='focal spot with z shifted by '+string(deltaz),psym=3 ;,xlabel="X "
		wait,1
	endif
end


;test 
device, decomposed =0
tek_color
loadct, 39
deltaz=10

;location of the test program
Stack = Scope_Traceback(/Structure)
Filename = Stack[N_elements(Stack) - 2].Filename
fpfile=File_DirName(Filename)+path_sep()+'\psf_Data_03.txt'

readFP,fpfile,xfp=x,yfp=y,cosx1=cz1,cosy1=cy1,cosz1=cx1,qtarget=15
shiftfocalplane,deltaz,x,y,cx1,cy1,cz1,xstart=xs,ystart=ys,/plot,window=2
wshow,2
;window,1
wait,2
oplot, xs,ys,psym=3,color=50
legend,['Original','Shifted'],color=[50,255]
end
