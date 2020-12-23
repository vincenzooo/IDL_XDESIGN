function opt_Rifle,th, lam,materials,z,sigma,E_range,c_mat,t_points=t_points,t_range=t_range
;trova il massimo con il raster scan

	if n_elements(t_range) eq 0 then t_range=[20.,270.]
	if n_elements(n_points) eq 0 then t_points=100
	t_step=(t_range[1]-t_range[0])/(t_points-1)
	t_vec=t_range[0]+t_step*indgen(t_points)
	if n_elements(c_mat) eq 0 then c_mat='a-C'

	;find indexes for E_range, define R_bare2
	en=12398.425/lam
	if n_elements(e_range) eq 0 then begin
		minind=0
		maxind=n_elements(en)-1
	endif else begin
		minind=fix(total(en lt E_range[0])-1)
		maxind=fix(total(en lt E_range[1]))
	endelse

	R_bare=Reflex_IMD(th, lam[minind:maxind],materials,z,sig)

	;inizia il ciclo e ottimizza la fom per ogni angInd
	bestTVec=fltarr(n_elements(th))
	bestR=fltarr(n_elements(th),n_elements(lam))
	for angInd=0,n_elements(th)-1 do begin
		best_fom=0
		best_t=100.
		for i=0,t_points-1 do begin
			R_coated=Reflex_IMD(th[angInd], lam[minind:maxind],materials,z,sig,t_vec[i],c_mat)
			fom=total((R_coated^2-R_bare[angInd,*]^2)/R_bare[angInd,*]^2)
			if fom gt best_fom then begin
				best_fom=fom
				best_t=t_vec[i]
			endif
			;print,fom
		end
		bestTVec[angInd]=best_t
		bestR[angInd,*]=Reflex_IMD(th[angInd], lam,materials,z,sig,best_t,c_mat)
	end
	print, bestTvec
	return,bestR
end




