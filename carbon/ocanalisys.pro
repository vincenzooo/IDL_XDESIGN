
pro plotGain,th,en,R_coated,R_bare,density,filename=filename,$
	ntracks=ntracks,perc_gain=pgain,area_gain=area_gain,telescopes=telescopes,$
	window=ww,extracolors=ec

	;generate a 3d plot of gain statistics
	;R[n,*] e' la riflettivita' in funzione dell'energia

;	colors=[[[50,0,0],[249,0,0]],$
;			[[0,50,0],[0,249,0]],$
;			[[0,0,150],[0,0,249]],$
;			[[0,0,50],[0,0,149]],$
;			[[200,200,0],[249,249,0]],$
;			[[150,150,0],[199,199,0]],$
;			[[100,100,0],[149,149,0]],$
;			[[50,50,0],[99,99,0]],$
;			[[200,0,200],[249,0,249]],$
;			[[150,0,150],[199,0,199]],$
;			[[100,0,100],[149,0,149]],$
;			[[50,0,50],[99,0,99]],$
;			[[0,200,200],[0,249,249]],$
;			[[0,150,150],[0,199,199]],$
;			[[0,100,100],[0,149,149]],$
;			[[0,50,50],[0,99,99]],$
;			[[0,0,0],[0,49,49]]]

	th_points=n_elements(th)
	IF ARG_present(perc_gain) then perc_gain=pgain
	IF ARG_present(area_gain) then area_gain=R_coated^2-R_bare^2
	pgain=100*(R_coated^2-R_bare^2)/R_bare^2
	if n_elements (ww) eq 0 then ww=4
	;dgtz_plot,pgain,[th[0],th[th_points-1]],[en[0],en[n_elements(en)-1]]
	if !D.Name eq 'WIN' then window,ww,xsize=600,ysize=400 else $
		device,filename=filename+string(ww)+'.'+!D.name
	colors_band3d, min(pgain), max(pgain), 32, 254,bandvalsize=100, colors,extracolors=ec,/TEK
	cont_image,pgain,(90-th),en,/colorbar,$
		title='R^2 gain for '+filename,bar_title='% gain [(R_coat^2-R_bare^2)/(R_bare^2)]',$
		xtitle='Incidence angle (deg)', ytitle='Energy (keV)'
	plot_rect,telescopes, thick=1, color=251
	if n_elements(density) ne 0 then $
		oplot,(90-th),19.83*sqrt(density)/((90-th)*!PI/180),thick=2,linestyle=2,color=25
	maketif,filename+'_3D'

	if n_elements (ntracks) ne 0 then begin
		;plot reflectivity vs energy for ntracks equally spaced different
		;angles in the angular range
		loadct,12
		IF ARG_present(ntracks) then ntracks=ntracks else ntracks=10
		pind=indgen(th_points)
		pind=pind[0:*:fix(th_points/ntracks)];vettore degli indici selezionati per il plot
		if !D.Name eq 'WIN' then window,ww+1,xsize=600,ysize=400 else $
		device,filename=filename+string(ww+1)+'.'+!D.name
		plot,en,pgain[pind[0],*],yrange=[-10,100],color=254, $
			xtitle='Energy (eV)',yTitle='Reflectivity'
		for i=0,n_elements(pind)-1 do begin
			oplot,en,pgain[pind[i],*],color=pind[i]
		end
		legend,string(0.5+(90.-th[pind]),format="(F8.3)")+' deg',color=pind,position=12
		maketif,filename+'_2D'
	endif

end


pro plot_rect,telescopes ,window_num, _extra=e

	if !D.NAME eq 'WIN' then begin
	curwin=	!D.WINDOW
	if n_elements(window_num) ne 0 then wset, window_num
	endif
	for i=0, n_elements(telescopes)-1 do begin
		xtel=telescopes[i]
		x0=xtel.angles[0]
		y0=xtel.energy[0]
		xlength=xtel.angles[1]-x0
		ylength=xtel.energy[1]-y0
		col=xtel.color
		if n_elements (xtel.linestyle) ne 0 then ls=xtel.linestyle
		RECTANGLE,X0,Y0,XLENGTH,YLENGTH,color=col,thick=3,linestyle=ls
		;plot labels
		xl=x0+xtel.labeloffset[0]
		yl=y0+xtel.labeloffset[1]

		;if y0+ylength gt !Y.RANGE[1] then yl=y0
		xyouts,xl,yl,xtel.name,color=col,charthick=2,orientation=90
	endfor
	if !D.NAME eq 'WIN' then wset, curwin
end


pro ocAnalisys ,mat_struct,th_range,En_range,c_mat,c_thick,perc_gain=perc_gain,$
	area_gain=area_gain,optimize=optimize,theta=th,ener=en,r_bare=r_bare,$
	r_coated=r_coated,besttvec=besttvec
	; plotta statistiche riguardanti il vantaggio dell'uso del carbonio
	; se optimize = 1 lo spessore viene ottimizzato per ogni angolo fissato
	; per ottenere guadagno sul range energetico Erange.
	;-----------------------------------
	; -init-

	;common ind_vars, th, lam
	mat=mat_struct.material
	density=mat_struct.density
	filename=mat_struct.filename
	if n_elements(optimize) eq 0 then optimize=0
	if n_elements(filename) eq 0 then psplot=0
	if n_elements(c_mat) eq 0 then c_mat='a-C'
	;indipendent variables

	th_points=200
	th_step=(th_range[1]-th_range[0])/(th_points-1)
	th_deg=th_range[0]+th_step*indgen(th_points)
	th=90.-th_deg

	en_points=200
	en_step=(en_range[1]-en_range[0])/(en_points-1)
	en=en_range[0]+en_step*indgen(en_points)
	lam=12.398425/en  ;entrano le energie in keV, le devo converire in A

	;sample structure without carbon
	z=[300.]
	materials=[mat,'Ni']
	sigma=0.
	plotTif=1

	nc_bare=load_nc(lam,materials)
	nc_coated=load_nc(lam,materials,c_mat)
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

	endelse


end


;densita'  --
;C:1.9/2.3(graph)
;Ni:8.9
;Au:19.3
;Ir:22.4
;W:19.3
;Pt:21.4
;Si:2.33
print,"main"

Pt={sample,material:'Pt',density:21.4,filename:'PtC',octhickness:80.}
W={sample,material:'W',density:19.3,filename:'WC',octhickness:80.}
Ir={sample,material:'Ir',density:22.4,filename:'IrC',octhickness:105.}
Au={sample,material:'Au',density:19.3,filename:'AuC',octhickness:80.}
samples=[Pt,W,Ir,Au]
eRosita={name:"eRosita", angles:[0.34,1.6], energy:[0.5,10.], color:12,labeloffset:[0.07,0.5],$
	linestyle:2}
hxmt={name:"PolariX/HXMT", angles:[0.61,0.88], energy:[2.,8.],color:4,labeloffset:[0.07,2.80],$
	linestyle:0}
simbolx={name:"Simbol X", angles:[0.1,0.23], energy:[0.5,80.],color:0,labeloffset:[0.07,2.5],$
	linestyle:0}
;edge={name:"WFI/EDGE", angles:[0.8,1.8], energy:[0.5,6.],color:1,labeloffset:[0.95,0.25],$
;	linestyle:0}
xeus={name:"XEUS", angles:[0.24,0.85], energy:[0.1,40.], color:10,labeloffset:[0.07,0.5],$
	linestyle:0}

telescopes=[hxmt,simbolx,xeus,eRosita]

;-------------------------------------
;generate the 3d plot of angle-energy gain
mat=Pt

extracol=[[0,0,0,0],$
			[255,255,255,255]]
;ocAnalisys ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
;	ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated,optimize=1,besttvec=besttvec
;plotGain,theta,ener,R_coated,R_bare,density,filename=mat.filename,$
;		perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,window=5
;print,bestTVec
;window,2
;plot,bestTVec
;maketif,mat.filename+'_thick'


ocAnalisys ,mat,[0,2.0],[0.1,10.],'a-C',80.,perc_gain=perc_gain,area_gain=area_gain,$
	ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated
;ocAnalisys ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
	;ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated

plotGain,theta,ener,R_coated,R_bare,mat.density,filename=mat.filename,$
		perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,$
		window=3,extracolors=extracol

contour, r_bare^2,90-theta,ener,/overplot,levels=[0.1],color=217,c_thick=1.1,c_linestyle=0,$
	c_annotation="R^2=0.1",c_charthick=2

set_plot,'ps'
;device , FILEname=mat.filename+'.ps'
plotGain,theta,ener,R_coated,R_bare,mat.density,filename=mat.filename,$
		perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,$
		window=3,extracolors=extracol

contour, r_bare^2,90-theta,ener,/overplot,levels=[0.1],color=217,c_thick=1.1,c_linestyle=0,$
	c_annotation="R^2=0.1",c_charthick=2

device, /close

set_plot, 'win'


;--------------------------------------

;------------------------------------
;launch angular scan simulator
;energy=[0.93,1.49,2.98,4.51,5.41,6.40]
;thrange=[0,2.]
;ang_simulator, samples, energy,thrange

;-------------------------------------
; launch energy scan simulator
;en_range =[0.1,10.]
;angles=[0.1,0.15, 0.2, 0.3,0.4, 0.5,0.6, 0.7,0.8,0.9, 1.0,1.1, 1.2]
;en_simulator,samples, angles, en_range
;-------------------------------------
end

