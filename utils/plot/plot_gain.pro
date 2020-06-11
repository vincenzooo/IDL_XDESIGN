;+
; NAME:
; PLOT_GAIN
;
; PURPOSE:
; Plots a set of plots illustrating the comparison of two coatings over a range of angles and energies, starting from their reflectivity matrices. 
;
; CATEGORY:
; Plot
;
; CALLING SEQUENCE:
; PLOT_GAIN,Th,En,R_coated,R_bare,density
;
; INPUTS:
; Th: vector of angles (size nA). Definition and units are irrelevant, as they are not used for 
;   computation, unless Density parameter is defined (), however default labels indicate
;   degrees.
;   
; En: Energy vector (size nE). Same as Th for units
; R_coated: "Enhanced" reflectivity matrix (nA x nE) whose gain (or loss) is calculated.
; R_bare:  Baseline reflectivity matrix (nA x nE) with respect to which gain are evaluated.
;
; OPTIONAL INPUTS:
; Density: If provided, use approximate formula (of unknown origin) to overplot critical angle.
;
; KEYWORD PARAMETERS:
; FILENAME: Used to generate outputs for the three plot, respectively with subfixes 
;   _3D (perc_gain) _area_3D (area_gain) and _2D (curves).   
;
; NTRACKS: Ntracks equally spaced angles in ranges are used to plot reflectivities
;   as a function of energy on window number Window+2 as three panel window with
;   R_bare, R_coated, Perc_gain 
; 
; TELESCOPES: A structure with telescope characteristic to create overlapping
;   markers on plots.
;   
; WINDOW: number to use for create plot windows (default is 4). Three windows are created with sequential
;     number starting from Window, they are:
;     
; EXTRACOLORS
; MIN_VALUE, MAX_VALUE: ranges used for color plots.
;     
; OPTIONAL OUTPUTS:
; PERC_GAIN
; AREA_GAIN
; 
; RESTRICTIONS:
; Use several external routines.
;
; PROCEDURE:
; Use CONT_IMAGE to plot AREA_GAIN and PERC_GAIN, and MULTIPLOT to plot slices (Reflex and Gain vs energy).
; Procedure RECTANGLE by D. Windt is used to plot a rectangle if telescopes is provided. 
; COLORS_BAND_PALETTE create a palette made of shaded color bands divided by zero (to separate gains from losses).
;
; EXAMPLE:
; See at the end of this file, can probably be cleaned and pieces moved to external functions.
;
; MODIFICATION HISTORY:
;   Vincenzo Cotroneo 2019/03/23
;   Revision from old code (probably 2010?).
;-

pro plot_rect,telescopes ,window_num, _extra=e
  ;+
  ;  telescopes is a list of telescope (can be empty or null), each one in format
  ;  simbolx={name:"Simbol X", angles:[0.1,0.23], energy:[0.5,80.],color:0,labeloffset:[0.15,5.],$
  ;       linestyle:1}.
  ;  They are plotted as rectangles on a window with x and y axis respectively ener and angle.
  ;-


  if !D.NAME eq 'WIN' || !D.Name eq 'X' then begin
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
  if !D.NAME eq 'WIN' || !D.Name eq 'X' then wset, curwin
end

pro plot_gain,th,en,R_coated,R_bare,density,filename=filename,$
  ntracks=ntracks,perc_gain=pgain,area_gain=area_gain,telescopes=telescopes,$
  window=ww,extracolors=ec,min_value=min_value,max_value=max_value

  ;generate a 3d plot of gain statistics
  ;R[n,*] e' la riflettivita' in funzione dell'energia

   colors=[[[50,0,0],[249,0,0]],$
       [[0,50,0],[0,249,0]],$
       [[0,0,150],[0,0,249]],$
       [[0,0,50],[0,0,149]],$
       [[200,200,0],[249,249,0]],$
       [[150,150,0],[199,199,0]],$
       [[100,100,0],[149,149,0]],$
       [[50,50,0],[99,99,0]],$
       [[200,0,200],[249,0,249]],$
       [[150,0,150],[199,0,199]],$
       [[100,0,100],[149,0,149]],$
       [[50,0,50],[99,0,99]],$
       [[0,200,200],[0,249,249]],$
       [[0,150,150],[0,199,199]],$
       [[0,100,100],[0,149,149]],$
       [[0,50,50],[0,99,99]],$
       [[0,0,0],[0,49,49]]]

;  gray8=[[[0,0,0],[31,31,31]],$
;    [[32,32,32],[63,63,63]],$
;    [[64,64,64],[95,95,95]],$
;    [[96,96,96],[127,127,127]],$
;    [[128,128,128],[159,159,159]],$
;    [[160,160,160],[191,191,191]],$
;    [[192,192,192],[223,223,223]],$
;    [[224,224,224],[255,255,255]]]

  th_points=n_elements(th)

  area_gain=R_coated^2-R_bare^2
  pgain=100*(R_coated^2-R_bare^2)/R_bare^2

  ;-------------------------------------------
  ;plot color map of percentual gain on window ww (or file filenameww)
  ;  This is some kind of mechanism that I cannot remember now,
  ;  can probably be made easier by passing to object graphics,
  ;  however I have the impression there is something wrong with filename
  ;  option, as the only supported device that makes sense seems to be ps.
  ; also I may want to plot only on screen (no output generation)
  if n_elements (ww) eq 0 then ww=4 ;getwfree()
  if !D.Name eq 'WIN' || !D.Name eq 'X' then window,ww,xsize=600,ysize=400 else $
    if n_elements(filename) ne 0 then device,filename=filename+string(ww)+'.'+!D.name
  titpostfix = n_elements(filename) eq 0? '' : ' for ' + file_basename(filename)
    
  pal=colors_band_palette(min(pgain), max(pgain), colors, pmin=32, pmax=254,bandvalsize=0.01,extracolors=ec,/TEK,/LOAD)
  cont_image,pgain,(90-th),en,/colorbar,min_value=min_value,max_value=max_value,$
    title='R^2 percentual gain'+titpostfix,bar_title='% gain [(R_coat^2-R_bare^2)/(R_bare^2)]',$
    xtitle='Incidence angle (deg)', ytitle='Energy (keV)'
  contour, r_bare^2,90-th,en,/overplot,levels=[0.1,0.5],color=251,c_thick=1.1,c_linestyle=0,$
    c_annotation=["R^2=0.1","R^2=0.5"],c_charthick=2
  if n_elements(telescope) ne 0 then plot_rect,telescopes, thick=1, color=25
  if n_elements(density) ne 0 then $
    oplot,(90-th),19.83*sqrt(density)/((90-th)*!PI/180),thick=2,linestyle=2,color=25
  if n_elements(filename) ne 0 then maketif,filename+'_3D'

  ;-------------------------------------------
  ;plot color map of area gain on window ww+1 (or file filenameww)
  if !D.Name eq 'WIN' || !D.Name eq 'X' then window,ww+1,xsize=600,ysize=400 else $
    if n_elements(filename) ne 0 then device,filename=filename+string(ww+1)+'_a.'+!D.name
  ;   colors1=[[[50,0,0],[255,0,0]],$
  ;   [[0,50,0],[0,255,0]],$
  ;   [[0,0,50],[0,0,255]],$
  ;   [[156,156,0],[255,255,0]],$
  ;   [[50,50,0],[155,155,0]],$
  ;   [[50,0,50],[255,0,255]],$
  ;   [[0,50,50],[0,255,255]]]
  pal1=colors_band_palette(100*min(area_gain), 100*max(area_gain),colors1, pmin=32, pmax=254,bandvalsize=20,$
    extracolors=ec,/TEK,/LOAD)
  cont_image,100*area_gain,(90-th),en,/colorbar,$
    title='Aeff gain (Acoll %)'+titpostfix,bar_title='Aeff/Acoll gain = (R_coat^2-R_bare^2)',$
    xtitle='Incidence angle (deg)', ytitle='Energy (keV)'
  contour, r_bare^2,90-th,en,/overplot,levels=[0.1,0.5],color=0,c_thick=1.1,c_linestyle=0,$
    c_annotation=["R^2=0.1","R^2=0.5"],c_charthick=2
  plot_rect,telescopes, thick=1, color=251
  if n_elements(density) ne 0 then $
    oplot,(90-th),19.83*sqrt(density)/((90-th)*!PI/180),thick=2,linestyle=2,color=25
  if n_elements(filename) ne 0 then maketif,filename+'_area_3D'

  ;-------------------------------------------

  if n_elements (ntracks) ne 0 then begin
    ;plot reflectivity vs energy for ntracks equally spaced different
    ;angles in the angular range
    col=plotcolors(ntracks+1)
    loadct,12
    ;IF ARG_present(ntracks) then ntracks=ntracks else ntracks=10
    pind=indgen(th_points)
    pind=pind[0:*:fix(th_points/ntracks)];vettore degli indici selezionati per il plot
    if !D.Name eq 'WIN' || !D.Name eq 'X' then window,ww+2,xsize=600,ysize=400 else $
      if n_elements(filename) ne 0 then device,filename=filename+string(ww+2)+'.'+!D.name
    ;multiplot,[1,3],mtitle=file_basename(filename),mxtitle='Energy ;(eV)',ygap=0.01  
    
    multi_plot,en,transpose(r_bare[pind,*]),yTitle='Reflectivity',back=cgcolor('white')
    plot,en,r_bare[pind[0],*],color=254, $  ;,yrange=[-10,100]
      yTitle='Reflectivity'
    for i=0,n_elements(pind)-1 do begin
      oplot,en,r_bare[pind[i],*],color=col[i]
    end
    multiplot
    
    plot,en,r_coated[pind[0],*],color=254, $  ;,yrange=[-10,100]
      yTitle='Reflectivity'
    for i=0,n_elements(pind)-1 do begin
      oplot,en,r_coated[pind[i],*],color=col[i]
    end
    multiplot
    
    plot,en,pgain[pind[0],*],color=254, $  ;,yrange=[-10,100]
      yTitle='Gain'
    for i=0,n_elements(pind)-1 do begin
      oplot,en,pgain[pind[i],*],color=col[i]
    end
    legend,string(0.5+(90.-th[pind]),format="(F8.3)")+' deg',color=col,position=12

    if n_elements(filename) ne 0 then maketif,filename+'_2D'
    
    multiplot,/reset
    multiplot,/default
  endif

end

setstandarddisplay

a = dindgen(200)
a = reform(a,[20,10])
a = a/max(a)
b = a*3 + 5
b = b/max(b)

an = findgen(20)+2
en = findgen(10)*3

plot_gain,an,en,a,b

end

