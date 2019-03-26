
pro en_simulator,samples, theta, en_range,term=term
;simulate an angular scan with and without coating for each of the energies
;and samples in the lists. Write results on files.
;use gnuplot to create good quality plots, term can be set to 'png' (default) or 'ps's

  if n_elements(term) eq 0 then term = 'png'
	en_points=200
	en_step=(en_range[1]-en_range[0])/(en_points)
	en_vec=en_range[0]+en_step*indgen(en_points+1)
	th=90.-theta
	close,1
	close,2
	close,3
	c_mat='a-C'
	openw,2,'plotfileEn_oc.plt'
	printf,2,'set grid'
	printf,2,'set key top box'
	printf,2,'unset logscale y'
	printf,2,"set xlabel 'energy (keV)'"
	printf,2,"set ylabel 'Reflectivity'"
	printf,2,'set yrange [0:1]'
	openw,3,'stats_en.dat'
	printf,3,'Sample     Angle     Maximum_energy   energy_max_effect   R_bare   R_coated  %gain'
	for i=0, n_elements (samples)-1 do begin
		lam=12.398425/en_vec  ;entrano le energie in keV, le devo converire in A
		;sample structure without carbon
		z=[300.]
		mat=samples[i].material
		materials=[mat,'Ni']
		sigma=0.
		c_thick=samples[i].octhickness

		nc_bare=load_nc(lam,materials)
		nc_coated=load_nc(lam,materials,c_mat)
		fresnel,th, lam, nc_bare,z,sigma,ra=r_bare
		fresnel,th, lam, nc_coated,[c_thick,z],sigma,ra=R_coated

		for j=0,n_elements(th)-1 do begin
			;statistics

			edgepos=max(where( en_vec lt 0.5))+1 ;start from 0.5 to avoid carbon edge
			noneffen=where(R_coated[j,edgepos:en_points] lt R_bare[j,edgepos:en_points],ct)+edgepos
			if (ct ne 0) then begin
				maxen=min(noneffen)-1
				maxen4effect=en_vec[maxen]
			endif else begin
				maxen4effect=max(en_vec)
			endelse
			maxgain=max(R_coated[j,*]-R_bare[j,*],mindex)
			printf,3,samples[i].material,theta[j],maxen4effect,en_vec[mindex],$
					R_bare[j,mindex],R_coated[j,mindex],$
					100*(R_coated[j,mindex]-R_bare[j,mindex])/R_bare[j,mindex],format='(a,6f8.3)'
			;write results on file
			fn=samples[i].filename+'_'+$
				strcompress(string((90.-th[j]),format='(f8.4)'),/remove_all)
			openw,1,fn+'.dat'
			printf,1, '# angle: '+string(90.-th[j])+' deg'
			printf,1,'# sample structure: (',c_mat,')+ ',materials
			printf,1,'# thicknesses : (',c_thick,')+ ',z
			printf,1,'#----------------------------------'
			printf,1,'energy (keV)     Reflex(bare)    Reflex(coated)'
				for k = 0,n_elements (en_vec)-1 do begin
					printf,1,en_vec[k],R_bare[j,k],R_coated[j,k]
				endfor
			close,1
			;Pt={sample,material:'Pt',density:21.4,filename:'PtC',octhickness:80.}
			printf,2,'#'+samples[i].material
			printf,2,"set title '",samples[i].material," sample - ",90.-th[j]," deg'"
			printf,2,"plot '",fn+".dat' u 1:2 title '",samples[i].material,"' w l,\"
			printf,2,"'",fn+".dat' u 1:3 title '",samples[i].material,$
				" + ",c_mat,"(",samples[i].octhickness," A)' w l lt 3"

			printf,2,'pause -1'

			printf,2,'set terminal '+(term eq 'ps'? 'postscript color linewidth 2':'png')
			printf,2,"set out '",fn,"."+term+"'"
			printf,2,'replot'
			printf,2,'set term '+ (!VERSION.OS_FAMILY eq 'Windows'? 'win': 'X11')
			printf,2,'set output'
			printf,2,"#------------------------------"
			printf,2
			printf,2
		endfor
	endfor
	close,2
	close,3
end

Pt={sample,material:'Pt',density:21.4,filename:'PtC',octhickness:80.}
W={sample,material:'W',density:19.3,filename:'WC',octhickness:80.}
Ir={sample,material:'Ir',density:22.4,filename:'IrC',octhickness:105.}
Au={sample,material:'Au',density:19.3,filename:'AuC',octhickness:80.}
samples=[Pt,W,Ir,Au]

; launch energy scan simulator
en_range =[0.1,10.]
angles=[0.1,0.15, 0.2, 0.3,0.4, 0.5,0.6, 0.7,0.8,0.9, 1.0,1.1, 1.2]
en_simulator,samples, angles, en_range

end
