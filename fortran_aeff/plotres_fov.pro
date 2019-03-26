pro plotRes_fov,file,func
;func as string, file is a file "bestSolutions.dat", containing one
;set <par1, par2, par3, func> per line.
;copy the data in a file "resultsFOM.dat" (in the same folder as file) adding
;two columns with the normalized integrated ref^2 and ref^2*ener.
;the square reflectivity of each solution is plotted during the calculation.

  common shared,ang,rough,ener,dVector,th
  common ref,rmatrix,dSpac
	matrix=read_datamatrix(file)
	matrix=float(matrix)
	matrixsize=size(matrix,/dimension)
	ncols=matrixsize[0]
	if n_elements(matrixsize) eq 1 then nrows= 1 $
		else nrows=matrixsize[1]
	;fom=matrix[ncols-1,*]
	fom1=fltarr(nrows)
	fom2=fltarr(nrows)
	for i=0,nrows-1 do begin
		fom=call_function(func,matrix[0:ncols-2,i]) ;the return value is not used.
				;the call is needed just to calculate the reflectivity.
;		plot,ener,ref,title=string(i+1)
;		oplot,ener,ref^2,color=100
;		legend,['R','R^2'],color=[255,100],position=12
		tmatrix=rmatrix*reverse(rmatrix,2)
		
    cont_image,tMatrix,ener,(ang+th)*180/!PI,/colorbar,$
    bar_title='Throughput',$
    ytitle='Incidence angle (deg)', xtitle='Energy (keV)',$
    title='Throughput Opt. Res.',nocontour=nocontour,$
    min_value=0,max_value=1
    ;outfolder='E:\work\documenti in progress\Cotroneo2010_FovOptSPIE\poster'
    ;writetif,outfolder+path_sep()+'ThroughputOptRes.tif'
    
		;if i eq 0 then bestref=ref
		fom1[i]=total(total(tmatrix,1)*dvector) ;total(ref^2)/n_elements(ref)
		fom2[i]=total(total(tmatrix,1)*dvector)  ;total(ref^2*ener)/total(ener)
		wait,0.5
	endfor
	folder=file_dirname(file)
	get_lun,nf
	openw,nf,folder+path_sep()+"resultsFOM.dat"
	for i=0,nrows-1 do begin
		printf,nf,matrix[*,i],fom1[i],fom2[i],format='('+string(ncols+2)+'f23.8)'
	endfor
	free_lun,nf
;	plot,ener,bestref,title='Best Solution'
;	oplot,ener,bestref^2,color=100
;	legend,['R','R^2'],color=[255,100],position=12

end
;plotres,outfolder+path_sep()+"bestSolutions.dat",funzione

;function,fmtStr,npoints
;;return a formatString to write <npoints> floats
;formatstring='('+string(npoints)+'f23.8)'
;return,formatstring
;end