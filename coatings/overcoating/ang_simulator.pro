
pro ang_simulator,samples, energy, th_range
;simulate an angular scan with and without coating for each of the energies
;and samples in the lists. Write results on files.
; launch .run imdstart before this program 

	th_points=200
	th_step=(th_range[1]-th_range[0])/(th_points)
	th_deg=th_range[0]+th_step*indgen(th_points+1)
	th=90.-th_deg
	close,1
	close,2
	close,3
	c_mat='a-C'
	openw,2,'plotfile_oc.plt'
	printf,2,'set grid'
	printf,2,'set key top box'
	printf,2,'unset logscale y'
	printf,2,"set xlabel 'th angle (deg)'"
	printf,2,"set ylabel 'Reflectivity'"
	printf,2,'set yrange [0:1]'
	openw,3,'stats.dat'
	printf,3,'Sample     Energy     Maximum_angle   angle_max_effect   R_bare   R_coated'
	for i=0, n_elements (samples)-1 do begin
		lam=12.398425/energy  ;entrano le energie in keV, le devo converire in A
		;sample structure without carbon
		z=[300.]
		mat=samples[i].material
		materials=[mat,'Si']
		sigma=0.
		c_thick=samples[i].octhickness

		nc_bare=load_nc(lam,materials)
		nc_coated=load_nc(lam,materials,c_mat)
		fresnel,th, lam, nc_bare,z,sigma,ra=r_bare
		fresnel,th, lam, nc_coated,[c_thick,z],sigma,ra=R_coated

		for j=0,n_elements(energy)-1 do begin
			;statistics
			noneffang=where(R_coated[*,j] lt R_bare[*,j],ct)
			if (ct ne 0) then begin
				maxan=min(noneffang)-1
				maxang4effect=90-th[maxan]
			endif else begin
				maxang4effect=90-min(th)
			endelse
			maxgain=max(R_coated[*,j]-R_bare[*,j],mindex)
			printf,3,samples[i].material,energy[j],maxang4effect,90.-th[mindex],$
					R_bare[mindex,j],R_coated[mindex,j],format='(a,5f8.3)'
			;write results on file
			fn=samples[i].filename+'_'+$
				strcompress(string(energy[j]*1000,format='(f6.0)'),/remove_all)
			openw,1,fn+'dat'
			printf,1, '# energy'+string(energy[j])+' keV'
			printf,1,'# sample structure: (',c_mat,')+ ',materials
			printf,1,'# thicknesses : (',c_thick,')+ ',z
			printf,1,'#----------------------------------'
			printf,1,'angle (deg)     Reflex(bare)    Reflex(coated)'
				for k = 0,n_elements (th)-1 do begin
					printf,1,(90-th[k]),R_bare[k,j],R_coated[k,j]
				endfor
			close,1
			;Pt={sample,material:'Pt',density:21.4,filename:'PtC',octhickness:80.}
			printf,2,'#'+samples[i].material
			printf,2,"set title '",samples[i].material," sample - ",energy[j]," keV'"
			printf,2,"plot '",fn+"dat' u 1:2 title '",samples[i].material,"' w l,\"
			printf,2,"'",fn+"dat' u 1:3 title '",samples[i].material,$
				" + ",c_mat,"(",samples[i].octhickness," A)' w l lt 3"

			printf,2,'pause -1'

			printf,2,'set terminal postscript color linewidth 2'
			printf,2,"set out '",fn,"ps'"
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

;launch angular scan simulator
energy=[0.93,1.49,2.98,4.51,5.41,6.40]
thrange=[0,2.]
ang_simulator, samples, energy,thrange

end
