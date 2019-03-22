pro plot_gain,th,en,R_coated,R_bare,density,filename=filename,$
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

	gray8=[[[0,0,0],[31,31,31]],$
			[[32,32,32],[63,63,63]],$
			[[64,64,64],[95,95,95]],$
			[[96,96,96],[127,127,127]],$
			[[128,128,128],[159,159,159]],$
			[[160,160,160],[191,191,191]],$
			[[192,192,192],[223,223,223]],$
			[[224,224,224],[255,255,255]]]

	th_points=n_elements(th)
	IF ARG_present(perc_gain) then perc_gain=pgain
	area_gain=R_coated^2-R_bare^2
	pgain=100*(R_coated^2-R_bare^2)/R_bare^2

;-------------------------------------------
;plot color map of percentual gain on window ww (or file filenameww)
	if n_elements (ww) eq 0 then ww=4
	if !D.Name eq 'WIN' then window,ww,xsize=600,ysize=400 else $
		device,filename=filename+string(ww)+'.'+!D.name
	colors_band3d, min(pgain), max(pgain), 32, 254,bandvalsize=100, colors,extracolors=ec,/TEK
	cont_image,pgain,(90-th),en,/colorbar,$
		title='R^2 percentual gain for '+filename,bar_title='% gain [(R_coat^2-R_bare^2)/(R_bare^2)]',$
		xtitle='Incidence angle (deg)', ytitle='Energy (keV)'
	contour, r_bare^2,90-th,en,/overplot,levels=[0.1,0.5],color=0,c_thick=1.1,c_linestyle=0,$
		c_annotation=["R^2=0.1","R^2=0.5"],c_charthick=2
	plot_rect,telescopes, thick=1, color=251
	if n_elements(density) ne 0 then $
		oplot,(90-th),19.83*sqrt(density)/((90-th)*!PI/180),thick=2,linestyle=2,color=25
	maketif,filename+'_3D'

;-------------------------------------------
;plot color map of area gain on window ww+1 (or file filenameww)
	if !D.Name eq 'WIN' then window,ww+1,xsize=600,ysize=400 else $
		device,filename=filename+string(ww+1)+'_a.'+!D.name
;		colors1=[[[50,0,0],[255,0,0]],$
;		[[0,50,0],[0,255,0]],$
;		[[0,0,50],[0,0,255]],$
;		[[156,156,0],[255,255,0]],$
;		[[50,50,0],[155,155,0]],$
;		[[50,0,50],[255,0,255]],$
;		[[0,50,50],[0,255,255]]]
 colors_band3d, 100*min(area_gain), 100*max(area_gain), 32, 254,bandvalsize=20,colors1,$
 	extracolors=ec,/TEK
	cont_image,100*area_gain,(90-th),en,/colorbar,$
		title='Aeff gain (Acoll %) for '+filename,bar_title='Aeff/Acoll gain = (R_coat^2-R_bare^2)',$
		xtitle='Incidence angle (deg)', ytitle='Energy (keV)'
	contour, r_bare^2,90-th,en,/overplot,levels=[0.1,0.5],color=0,c_thick=1.1,c_linestyle=0,$
		c_annotation=["R^2=0.1","R^2=0.5"],c_charthick=2
	plot_rect,telescopes, thick=1, color=251
	if n_elements(density) ne 0 then $
		oplot,(90-th),19.83*sqrt(density)/((90-th)*!PI/180),thick=2,linestyle=2,color=25
	maketif,filename+'_area_3D'

;-------------------------------------------

	if n_elements (ntracks) ne 0 then begin
		;plot reflectivity vs energy for ntracks equally spaced different
		;angles in the angular range
		loadct,12
		IF ARG_present(ntracks) then ntracks=ntracks else ntracks=10
		pind=indgen(th_points)
		pind=pind[0:*:fix(th_points/ntracks)];vettore degli indici selezionati per il plot
		if !D.Name eq 'WIN' then window,ww+2,xsize=600,ysize=400 else $
		device,filename=filename+string(ww+2)+'.'+!D.name
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
		xl=xtel.labeloffset[0]
		yl=xtel.labeloffset[1]
		;xl=x0+xtel.labeloffset[0]
		;yl=y0+xtel.labeloffset[1]

		;if y0+ylength gt !Y.RANGE[1] then yl=y0
		xyouts,xl,yl,xtel.name,color=col,charthick=2,orientation=90
	endfor
	if !D.NAME eq 'WIN' then wset, curwin
end


pro oc_analisys ,mat_struct,th_range,En_range,c_mat,c_thick,perc_gain=perc_gain,$
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

pro cont
;fake procedure, copy and past the following commands in the cmd line
;to produce the b/w plots for the spie 2008 paper.
;you have to launch the main program (with the right material set in mat) before this.
;replace the filename and the material name in the title in the following lines
;(change the lines marked with ";mat").

set_plot,'ps'
device , FILEname='Pt.ps'  ;mat

;--------------------------------------
;use only this part for output on screen
	gray8=[[[224,224,224],[255,255,255]],$
			[[192,192,192],[223,223,223]],$
			[[160,160,160],[191,191,191]],$
			[[128,128,128],[159,159,159]],$
			[[96,96,96],[127,127,127]],$
			[[64,64,64],[95,95,95]],$
			[[32,32,32],[63,63,63]],$
			[[0,0,0],[31,31,31]]]

	gray_neat=[[[255,255,255],[255,255,255]],$
			[[225,225,225],[225,225,225]],$
			[[192,192,192],[192,192,192]],$
			[[160,160,160],[160,160,160]],$
			[[128,128,128],[128,128,128]],$
			[[64,64,64],[64,64,64]],$
			[[48,48,48],[48,48,48]],$
			[[32,32,32],[32,32,32]],$
			[[16,16,16],[16,16,16]]]

colors_band3d, 100*min(area_gain), 100*max(area_gain), 32, 254,bandvalsize=10, gray_neat

cont_image,100*area_gain,(90-theta),ener,/colorbar,$
		title='Aeff gain (Acoll %) for Pt+C',bar_title='Aeff/Acoll gain = (R_coat^2-R_bare^2)',$
		xtitle='Incidence angle (deg)', ytitle='Energy (keV)',/NOContour  ;mat

;	contour, r_bare^2,90-theta,ener,/overplot,levels=[0.1,0.5],color=0,c_thick=1.1,c_linestyle=0,$
;		c_annotation=["R^2=0.1","R^2=0.5"],c_charthick=2
   	contour, 100*area_gain,90-theta,ener,/overplot,$
	levels=[-10,-5, 0,5, 10 ,30 ,40],c_annotation=[-10,-5, 0,5, 10 ,30 ,40],$
		color=0,c_thick=1.1,c_linestyle=0,c_charthick=2

	plot_rect,telescopes, thick=1, color=251
;-------------------------------------------------------------

	maketif,'Ptgray_area_3D'		;mat
	device, /close
	set_plot,"win"
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
eRosita={name:"eRosita", angles:[0.34,1.6], energy:[0.5,10.], color:0,labeloffset:[1.57,6.5],$
	linestyle:2}  ;labeloffset:[0.07,0.3]
hxmt={name:"PolariX/HXMT", angles:[0.61,0.88], energy:[2.,8.],color:4,labeloffset:[0.95,6.2],$
	linestyle:0}  ;labeloffset:[0.07,2.80]
simbolx={name:"Simbol X", angles:[0.1,0.23], energy:[0.5,80.],color:0,labeloffset:[0.15,5.],$
	linestyle:1}  ;labeloffset:[0.07,2.5]
edge={name:"EDGE/XENIA", angles:[0.8,1.8], energy:[0.5,6.],color:0,labeloffset:[1.75,3],$
	linestyle:0}  ;labeloffset:[0.95,3]
xeus={name:"XEUS", angles:[0.24,0.85], energy:[0.1,40.], color:10,labeloffset:[0.30,0.5],$
	linestyle:0}  ;labeloffset:[0.07,0.5]
conx={name:"Constellation-X", angles:[0.11,0.46], energy:[0.1,70.], color:11,labeloffset:[0.17,7.0],$
	linestyle:0}  ;labeloffset:[0.07,6.0]

telescopes=[hxmt,simbolx,xeus,edge,eRosita,conx]

;-------------------------------------
;generate the 3d plot of angle-energy gain
mat=Pt     ;mat

extracol=[[0,0,0,0],$
			[255,255,255,255]]
;oc_analisys ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
;	ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated,optimize=1,besttvec=besttvec
;plot_gain,theta,ener,R_coated,R_bare,density,filename=mat.filename,$
;		perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,window=5
;print,bestTVec
;window,2
;plot,bestTVec
;maketif,mat.filename+'_thick'


oc_analisys ,mat,[0,2.0],[0.1,10.],'a-C',80.,perc_gain=perc_gain,area_gain=area_gain,$
	ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated
;oc_analisys ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
	;ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated

plot_gain,theta,ener,R_coated,R_bare,mat.density,filename=mat.filename,$
		perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,$
		window=3,extracolors=extracol

;-------------------------------plot ps
set_plot,'ps'
Device, COLOR=1, BITS_PER_PIXEL=8
;device , FILEname=mat.filename+'.ps'
plot_gain,theta,ener,R_coated,R_bare,mat.density,filename=mat.filename,$
		perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,$
		window=3,extracolors=extracol

device, /close
;-------------------------------
set_plot, 'PS'
;window,8
device , FILE='reflex2_0.7deg.ps'
i_th07=max(where(90.-theta lt 0.7))
pgain=100*(R_coated^2-R_bare^2)/R_bare^2
plot, ener,R_coated[i_th07,*]^2,xtitle='Energy (keV)',ytitle='Square reflectivity',$
;	title='Square reflectivity vs energy at 0.7 deg'
oplot, ener,R_bare[i_th07,*]^2,color=100,linestyle=2

legend,["Pt + C(80 A)","Pt"],position=12,color=[!P.color,100],linestyle=[0,2]
;oplot,  ener,pgain[i_th07,*],color=160
;window,9,ysize=200
device,/close

device , FILE='gain2_0.7deg.ps'
ysize_st=!D.Y_SIZE
device,ysize=5
plot,  ener,pgain[i_th07,*],ytitle='% Gain',xtitle='Energy (keV)'
oplot, ener,0*indgen(n_elements(ener)),linestyle=2
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

;-------------------------------
set_plot, 'PS'
device , FILE='reflex2_4.5keV.ps'
i_en4500=max(where(ener lt 4.5))

plot, ener,R_coated[*,i_en4500]^2,xtitle='Incidence angle (deg)',ytitle='Square reflectivity'
oplot, ener,R_bare[*,i_en4500]^2,color=100,linestyle=2
legend,["Pt","Pt + C(80 A)"],position=12,color=[!P.color,100]
device,/close
device , FILE='gain2_4.5keV.ps'
ysize_st=!D.Y_SIZE
device,ysize=5
plot,  90-theta,pgain[*,i_en4500],ytitle='% Gain',xtitle='Incidence angle (deg)'
oplot, 90-theta,0*indgen(n_elements(theta)),linestyle=1
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------


set_plot, 'win'

;-------------------------------
set_plot, 'PS'
;window,8

device , FILE='gain2acoll_0.7deg.ps'
ysize_st=!D.Y_SIZE
device,ysize=5
plot,  ener,area_gain[i_th07,*]*100.,ytitle='Gain (% Acoll)',xtitle='Energy (keV)'
oplot, ener,0*indgen(n_elements(ener)),linestyle=1
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

;-------------------------------
set_plot, 'PS'
device , FILE='gain2acoll_4.5keV.ps'
ysize_st=!D.Y_SIZE
device,ysize=5
plot,  90-theta,area_gain[*,i_en4500]*100,ytitle='Gain (% Acoll)',xtitle='Incidence angle (deg)'
oplot, 90-theta,0*indgen(n_elements(theta)),linestyle=1
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

;-------------------------------
set_plot, 'PS'
device , FILE='gain2acoll_3.0keV.ps'
ysize_st=!D.Y_SIZE
i_en3000=max(where(ener lt 3.0))
device,ysize=5
plot,  90-theta,area_gain[*,i_en3000]*100,ytitle='Gain (% Acoll)',xtitle='Incidence angle (deg)'
oplot, 90-theta,0*indgen(n_elements(theta)),linestyle=1
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

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

