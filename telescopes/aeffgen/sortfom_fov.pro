pro sortFOM_fov,folder,funk,ndim

	;sortFOM,'funkabc_1r3','funkabc_1',4
	;sortFOM,outfolder,funzione,4

	outfile=folder+path_sep()+'correspondence.txt'
	sdfile=folder+path_sep()+'enddata.dat'
	sortedFile=folder+path_sep()+'enddata_sorted.dat'

	;read starting data and fom
	get_lun,nfend
	openr,nfend,sdfile
	line=strarr(1)
	readf,nfend,line,format='(a100)'  ;header
	pop=fltarr(ndim,ndim+1,1)
	tmp=fltarr(ndim+3,ndim+1)
	fom=fltarr(ndim+1)
	iter=lonarr(ndim+1)
	i=0l
	while ~eof(nfend) do begin
		CATCH, Error_status
		if Error_status ne 0 then begin
			if eof(nfend) ne 1 then begin
				print,"ERRORE, non fine file."
				free_lun,nfend
				stop
			endif
			break
		endif
		readf,nfend,tmp  ;,format='('+string(ndim)+'f)'
		CATCH, /CANCEL
		if i eq 0 then begin
			pop=tmp[0:ndim-1,0:ndim]
			fom=transpose(tmp[ndim,0:ndim])
			iter=transpose(tmp[ndim+1,0:ndim])
		endif else begin
			pop=[[[pop]],[[tmp[0:ndim-1,0:ndim]]]]
			fom=[[fom],[transpose(tmp[ndim,0:ndim])]]
			iter=[[iter],[transpose(tmp[ndim+1,0:ndim])]]
		endelse
		readf,nfend
		readf,nfend
		i=i+1
	endwhile
	ntry=i
	free_lun,nfend

	bestFom=min(fom,bestIndex,dimension=1)
	bestIndex=array_indices(fom,bestIndex)
	popBest=pop[*,bestIndex] ;best result for each simplex, corresponding fom in bestFom
	rank=sort(bestFom)

	;write correspondence file
	get_lun,corrfn
	openw,corrfn,outfile
	printf,corrfn,"rank, solution nr., pars, fom, "
	for i=0,ntry-1 do begin
		printf,corrfn,i,rank[i],popBest[*,rank[i]],bestFom[rank[i]],$
		format='(2i,'+string(ndim+1)+'f)'
	endfor
	free_lun,corrfn

	;write sorted final data
	get_lun,sortedfn
	openw,sortedfn,sortedFile
	for i=0,ntry-1 do begin
		k=rank[i]
		for j=0,ndim do begin
			printf,sortedfn,pop[*,j,k],fom[j,k],iter[j,k],k,format='('+string(ndim+1)+'f'+',2i)'
		endfor
		printf,sortedfn
		printf,sortedfn
	endfor
	free_lun,sortedfn
end