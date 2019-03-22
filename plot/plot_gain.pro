pro plot_gain,th,en,R_coated,R_bare,density,filename=filename,$
  ntracks=ntracks,perc_gain=pgain,area_gain=area_gain,telescopes=telescopes,$
  window=ww,extracolors=ec

  ;generate a 3d plot of gain statistics
  ;R[n,*] e' la riflettivita' in funzione dell'energia

; colors=[[[50,0,0],[249,0,0]],$
;     [[0,50,0],[0,249,0]],$
;     [[0,0,150],[0,0,249]],$
;     [[0,0,50],[0,0,149]],$
;     [[200,200,0],[249,249,0]],$
;     [[150,150,0],[199,199,0]],$
;     [[100,100,0],[149,149,0]],$
;     [[50,50,0],[99,99,0]],$
;     [[200,0,200],[249,0,249]],$
;     [[150,0,150],[199,0,199]],$
;     [[100,0,100],[149,0,149]],$
;     [[50,0,50],[99,0,99]],$
;     [[0,200,200],[0,249,249]],$
;     [[0,150,150],[0,199,199]],$
;     [[0,100,100],[0,149,149]],$
;     [[0,50,50],[0,99,99]],$
;     [[0,0,0],[0,49,49]]]

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
  if !D.Name eq 'WIN' || !D.Name eq 'X' then window,ww,xsize=600,ysize=400 else $
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
  if !D.Name eq 'WIN' || !D.Name eq 'X' then window,ww+1,xsize=600,ysize=400 else $
    device,filename=filename+string(ww+1)+'_a.'+!D.name
;   colors1=[[[50,0,0],[255,0,0]],$
;   [[0,50,0],[0,255,0]],$
;   [[0,0,50],[0,0,255]],$
;   [[156,156,0],[255,255,0]],$
;   [[50,50,0],[155,155,0]],$
;   [[50,0,50],[255,0,255]],$
;   [[0,50,50],[0,255,255]]]
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
    curwin= !D.WINDOW
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

end

