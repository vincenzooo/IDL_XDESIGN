
  ;produce the b/w plots for the spie 2008 paper.
  ;you have to launch the main program (with the right material set in mat) before this.
  ;replace the filename and the material name in the title in the following lines
  ;(change the lines marked with ";mat").

  ;;uncomment to generate plots:
  ;set_plot,'ps'
  ;device , FILEname='Pt.ps'  ;mat

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

  ;  adjustment to newer routine (2019/08/21)
  ;  old:
  ;  colors_band3d, 100*min(area_gain), 100*max(area_gain), 32, 254,bandvalsize=10, gray_neat
  ;  new :
  a = colors_band_palette(100*min(area_gain), 100*max(area_gain), gray_neat,$  
  pmin=32, pmax=254,bandvalsize=10,/load)
  
  ;  interface promemoria:
;    pro colors_band3d, vmin, vmax, pmin, pmax, colors, zero=zero, bandsize=bandsize, $
;    bandvalsize=bandvalsize,extracolors=ec,tek=tek,noreverse=noreverse,force=force
;  
;    if n_elements(force) ne 0 then begin
;      errmsg="The Colors_band3d routine is obsolete. Use function"+$
;        "color_band_palette with /load option. e.g.: "+$
;        "result=colors_band_palette(vmin,vmax,Colors,pmin=pmin,pmax=pmax,/load"+$
;        "Otherwise, set the /force flag to use colors_band3d (at your risk!)."
;      message,errmsg
;    endif
;
;  function colors_band_palette, Vmin, Vmax, Colors, pmin=pmin, pmax=pmax,$
;    zero=zero, izeroCT=izeroCT,bandsize=bandsize, bandvalsize=bandvalsize,$
;    extracolors=ec,tek=tek,noreverse=noreverse,load=load,currentCT=currentCT,$
;    nozeropoint=nozeropoint

  cont_image,100*area_gain,(90-theta),ener,/colorbar,$
    title='Aeff gain (Acoll %) for Pt+C',bar_title='Aeff/Acoll gain = (R_coat^2-R_bare^2)',$
    xtitle='Incidence angle (deg)', ytitle='Energy (keV)',/NOContour  ;mat

  ; contour, r_bare^2,90-theta,ener,/overplot,levels=[0.1,0.5],color=0,c_thick=1.1,c_linestyle=0,$
  ;   c_annotation=["R^2=0.1","R^2=0.5"],c_charthick=2
  contour, 100*area_gain,90-theta,ener,/overplot,$
    levels=[-10,-5, 0,5, 10 ,30 ,40],c_annotation=string([-10,-5, 0,5, 10 ,30 ,40]),$
    color=0,c_thick=1.1,c_linestyle=0,c_charthick=2

  plot_rect,telescopes, thick=1, color=251
  ;-------------------------------------------------------------

  maketif,'Ptgray_area_3D'    ;mat
  ;device, /close
  set_plot,"win"
end