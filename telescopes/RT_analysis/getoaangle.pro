
function getOAangle, folder,index,file=file,arcmin=arcmin,deg=deg
	;return the offAxis angle in radians as read from the setting file
	;if index is given return the corresponding element. An alternative
	;setting file can be provided in file. If /arcmin or /deg are set
	; return the angles in the corresponding unit.


	if n_elements(arcmin) ne 0 then begin
		if n_elements(deg) ne 0 then MESSAGE, $
			'/arcmin and /deg cannot be both set in calling getOAangle.'
	endif
	if n_elements(folder) eq 0 then begin
		folderprefix=''
	endif else begin
		;mettere caso piu' generale in cui aggiunge il delimitatore solo se non gia' presente
		folderprefix=folder+path_sep()
	endelse
	if n_elements(file) eq 0 then file='imp_offAxis.txt'
	impfile=folderprefix+file
	ang0=float(readNamelistVar(impFile,'ang0Arcmin'))
	ang1=float(readNamelistVar(impFile,'ang1Arcmin'))
	step=float(readNamelistVar(impFile,'pasa'))

	na=1
	if (step ne 0) then na=fix((ang1-ang0)/step)+1 ; number of angular steps
	theta=findgen(na)*step+ang0
	if n_elements(index) ne 0 then theta=theta[index]

	if n_elements(arcmin) ne 0 then return,theta
	if n_elements(deg) ne 0 then return,theta/60.
	return, theta*!PI/180/60

end
