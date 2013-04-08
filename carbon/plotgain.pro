
pro plotgain,filename,mat,c_mat,perc_gain=perc_gain,area_gain=area_gain,$
	density=density,optimize=optimize,t_range=t_range,E_range=E_range
	; plotta statistiche riguardanti il vantaggio dell'uso del carbonio
	; se optimize = 1 lo spessore viene ottimizzato per ogni angolo fissato
	; per ottenere guadagno sul range energetico Erange
	;-----------------------------------
	; -init-

	;common ind_vars, th, lam

	if n_elements(optimize) eq 0 then optimize=0
	if n_elements(filename) eq 0 then psplot=0
	if n_elements(c_mat) eq 0 then c_mat='a-C'
	;indipendent variables
	th_range=[200.,10000.]
	th_points=200
	th_step=(th_range[1]-th_range[0])/(th_points-1)
	th_sec=th_range[0]+th_step*indgen(th_points)
	th=90-th_sec/3600

	en_range=[100.,1600.]
	en_points=200
	en_step=(en_range[1]-en_range[0])/(en_points-1)
	en=en_range[0]+en_step*indgen(en_points)
	lam=12398.425/en  ;entrano le energie in eV, le devo converire in A

	;sample structure without carbon
	z=[300.]
	materials=[mat,'Si']
	sigma=2.
	c_thick=100.
	plotTif=1

	nc_bare=load_nc(lam,materials)
	nc_coated=load_nc(lam,materials,c_mat)
	window,4
	loadct,12
	fresnel,th, lam, nc_bare,z,sigma,ra=r_bare

	if optimize eq 0 then fresnel,th, lam, nc_coated,[c_thick,z],sigma,ra=R_coated $
	else begin
		if optimize eq 1 then t_points=100. else t_points=optimize
		if n_elements(t_range) eq 0 then t_range=[20.,270.]
		t_step=(t_range[1]-t_range[0])/(t_points-1)
		t_vec=t_range[0]+t_step*indgen(t_points)
		if n_elements(e_range) eq 0 then begin
			minind=0
			maxind=n_elements(en)-1
		endif else begin
			minind=fix(total(en lt E_range[0])-1)
			maxind=fix(total(en lt E_range[1]))
		endelse
		;inizia il ciclo e ottimizza la fom per ogni angInd
		bestTVec=fltarr(n_elements(th))
		R_coated=fltarr(n_elements(th),n_elements(en))
		for angInd=0,n_elements(th)-1 do begin
			best_fom=0
			best_t=100.
			for i=0,t_points-1 do begin
				fresnel,th[angInd], lam[minind:maxind], nc_coated[*,minind:maxind],[t_vec[i],z],sigma,ra=r_test
				fom=total((R_test^2-R_bare[angInd,*]^2)/R_bare[angInd,*]^2)
				if fom gt best_fom then begin
					best_fom=fom
					best_t=t_vec[i]
				endif
				fresnel,th[angInd], lam, nc_coated,[t_vec[i],z],sigma,ra=r_fullEn
				R_coated[angInd,*]=r_fullEn
			end
			bestTVec[angInd]=best_t
		end
		print,bestTVec
		plot,bestTVec
		maketif,filename+'_thick'
	endelse

	;R[n,*] e' la riflettivita' in funzione dell'energia
	pgain=100*(R_coated^2-R_bare^2)/R_bare^2

	IF ARG_present(perc_gain) then perc_gain=pgain
	IF ARG_present(area_gain) then area_gain=R_coated^2-R_bare^2
	dgtz_plot,pgain,[th[0],th[n_elements(th)-1]],[en[0],en[n_elements(en)-1]]

	ntracks=10
	pind=indgen(th_points)
	pind=pind[0:*:fix(th_points/ntracks)];vettore degli indici selezionati per il plot
	plot,en,pgain[pind[0],*],yrange=[-10,100],color=255, $
		xtitle='Energy (eV)',yTitle='Reflectivity'
	for i=0,n_elements(pind)-1 do begin
		oplot,en,pgain[pind[i],*],color=pind[i]
	end
	legend,string(fix(0.5+(90-th[pind])*3600))+' arcsec',color=pind,position=12
	maketif,filename+'_2D'

	window,5,xsize=600,ysize=400
	loadct,12
	cont_image,pgain,(90-th)*3600,en,/colorbar,bar_title='% gain',max_value=100
	if n_elements(density) ne 0 then $
		oplot,(90-th)*3600,19.83*sqrt(density)/((90-th)*!PI/180),thick=2,linestyle=2
	maketif,filename+'_3D'

end

;plotgain,filename,mat,c_mat,optimize=optimize,t_range=t_range,E_range=E_range

;plotgain,'Au_C','Au',c_mat
;densita'  --
;C:1.9/2.3(graph)
;Ni:8.9
;Au:19.3
;Ir:22.4
;W:19.3
;Pt:21.4
;Si:2.33

;oplot,(90-th)*3600,19.83*Dsqrt(density)/((90-th)*!PI/180)
;plotgain,'Au_C','Au',c_mat,density=19.3,perc_gain=gImg,area_gain=aImg
plotgain,'W_C','W',c_mat,density=19.3,perc_gain=gImg,area_gain=aImg
end

