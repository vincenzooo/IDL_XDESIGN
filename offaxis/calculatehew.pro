function calculateHEW,x,y,throughput=thr,xcenter=barx,ycenter=bary,xbar=xbarout,ybar=ybarout,percentile=perc
;calculate the HEW for lists of x and y photon positions
;xbar and ybar can be separately provided.
;the HEW is calculated in linear units (the same as x and y).
;A different percentile of integrated energy can be provided, 50%(hew) is otherwise assumed.

	nph=n_elements(x)
	r=dblarr(nph)
	xbarout=total(x)/nph
	ybarout=total(y)/nph
	if n_elements(barx) eq 0 then barx=xbarout
	if n_elements(bary) eq 0 then bary=ybarout
	if n_elements(perc) eq 0 then perc=double(0.5) 
	r=sqrt((x-barx)^2+(y-bary)^2)
	rSortedIndex=sort(r)

	nt=n_elements (thr)
	if nt eq 0 then begin
		half=fix(nph*perc)
		return, 2*r[rSortedIndex[half]]
	endif else begin
		if (nt ne nph) then message,'wrong number of elements in calculateHEW:'+nt+' for '+nph+' points'
	endelse

	;use throughput
	cumsum=total(thr[rSortedIndex],/cumulative) ;throughput integrato in ordine di raggio, la meta' determina hew
	halfEnergy=where(cumsum lt perc*total(thr),counthalf) ;counthalf:number of ph inside hew radius

	return,2*r[rSortedIndex[counthalf]] ;hew diameter
end