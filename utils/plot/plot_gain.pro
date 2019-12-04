;+
; NAME:
; PLOT_GAIN
;
; PURPOSE:
; Plots a set of plots illustrating the comparison of two coatings over a range of angles and energies. 
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
  ;  telescopes is a list of telescope, each one in format
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
  IF ARG_present(perc_gain) then perc_gain=pgain
  area_gain=R_coated^2-R_bare^2
  pgain=100*(R_coated^2-R_bare^2)/R_bare^2

  ;-------------------------------------------
  ;plot color map of percentual gain on window ww (or file filenameww)
  if n_elements (ww) eq 0 then ww=4
  if !D.Name eq 'WIN' || !D.Name eq 'X' then window,ww,xsize=600,ysize=400 else $
    device,filename=filename+string(ww)+'.'+!D.name
  pal=colors_band_palette(min(pgain), max(pgain), colors, pmin=32, pmax=254,bandvalsize=0.01,extracolors=ec,/TEK,/LOAD)
  cont_image,pgain,(90-th),en,/colorbar,min_value=min_value,max_value=max_value,$
    title='R^2 percentual gain for '+filename,bar_title='% gain [(R_coat^2-R_bare^2)/(R_bare^2)]',$
    xtitle='Incidence angle (deg)', ytitle='Energy (keV)'
  contour, r_bare^2,90-th,en,/overplot,levels=[0.1,0.5],color=251,c_thick=1.1,c_linestyle=0,$
    c_annotation=["R^2=0.1","R^2=0.5"],c_charthick=2
  plot_rect,telescopes, thick=1, color=25
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
  pal1=colors_band_palette(100*min(area_gain), 100*max(area_gain),colors1, pmin=32, pmax=254,bandvalsize=20,$
    extracolors=ec,/TEK,/LOAD)
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
    col=plotcolors(ntracks+1)
    loadct,12
    ;IF ARG_present(ntracks) then ntracks=ntracks else ntracks=10
    pind=indgen(th_points)
    pind=pind[0:*:fix(th_points/ntracks)];vettore degli indici selezionati per il plot
    if !D.Name eq 'WIN' || !D.Name eq 'X' then window,ww+2,xsize=600,ysize=400 else $
      device,filename=filename+string(ww+2)+'.'+!D.name
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

    maketif,filename+'_2D'
    
    multiplot,/reset
    multiplot,/default
  endif

end




function Reflex_monolayer,angle,index
 ; wrapper for IRT code, use with load_index

  if n_elements(angle) ne n_elements(index) then message, "ANGLE and INDEX must be same length"
  
  ANG=!PI/2.-Angle  ;convert to angle to normal in rad

  RETURN, IRT_REFLEX(ANG,NC)
END

function load_index,material,energy
  readcol,material,l,r,i,comment=';'
   LAM=12.398425d/energy
   
   return,load_nk(LAM,MATERIAL)
   
;  r_nk=interpol( l, r, lam)
;  i_nk=interpol( l, i, lam)
;  return, dcomplex(r_nk,i_nk)  
;  
;  ;return, n
end

function xtest_reflex,energy,angle,material
  ;+
  ;return a 2D array with reflectivity as a function of energy (in keV) and angle (in radians).
  ;this is an incomplete attempt to build a list of photons, removing common blocks from original IRT.
  ;a working version with original common blocks and workaround is in material analysis.
  ;-

  ;create a list of `photons` each one with an angle and an energy
  
  nph=n_elements(energy)*n_elements(angle)

  a=reform(transpose(Rebin(angle, n_elements(angle), n_elements(energy))),nph)
  ener=reform(Rebin(energy, n_elements(energy), n_elements(angle)),nph)
  
  index=load_index(material,ener)  ;read and interpolate refraction index at the energy of each photon  
  rind=reform(Rebin(index, n_elements(energy), n_elements(angle)),nph)
  ;index=load_nk(ener,material)  ;read and interpolate refraction index at the energy of each photon  
  ;rind_r=reform(Rebin(real_part(index), n_elements(energy), n_elements(angle)),nph)
  ;rind_i=reform(Rebin(imaginary(index), n_elements(energy), n_elements(angle)),nph)

  R=Reflex_monolayer(angle,ener,rind)
  ;R=Reflex_monolayer(a,complex(rind_r,rind_i))
  return, reform(r,n_elements(energy), n_elements(angle))


end

;This part defines telescopes from old code

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


;this part create a reflectivity matrix, using new code obtained by adapting IRT reflectivity function.
WHILE !D.Window GT -1 DO WDelete, !D.Window ;close all currently open windows
nkpath='C:\Users\kovor\Documents\IDL\user_contrib\imd\nk'

npe=100
npa=10
en_range=[0.1 ,5.]
deg_range=[0.7d, 0.85d]
mat = nkpath+path_sep()+'Ir.nk'

energy = dindgen(npe)/(npe-1)*(en_range[1]-en_range[0])+en_range[0]
alpha_deg =dindgen(npa)/(npa-1)*(deg_range[1]-deg_range[0])+deg_range[0]


;test calling with two vectors
setstandarddisplay,/tk
r2D=test_reflex(energy, !PI/2- alpha_deg*!PI/180d,mat)
print,r2d

;window,/free
;fig2d=image(r2D,alpha_deg,energy)

;extract a row from reflex2d
;extract a column from reflex2d
;calculate for a row only
;calculate for a column only
;calculate for a point

plot_gain,90.-alpha_deg,energy,transpose(R2d),transpose(R2d*0)+1d,filename='test_gain'

end

