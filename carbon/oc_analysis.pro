;VC 2019/03/22 this was plotgain, that was merged with routine in plot, leaving here the part with analysis.

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
;samples=[Pt,W,Ir,Au]
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
	title='Square reflectivity vs energy at 0.7 deg'
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

setstandarddisplay
;set_plot, 'win'

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

setstandarddisplay
;set_plot, 'win'

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

