;+
; NAME:
; PLOT_CIRCLE
;
; PURPOSE:
; Plot a circle of radius Radius around a given Center.
;
; CATEGORY:
; PLOT
;
; CALLING SEQUENCE:
; Write the calling sequence here. Include only positional parameters
; (i.e., NO KEYWORDS). For procedures, use the form:
;
; PLOT_CIRCLE, Radius
;
;
; INPUTS:
; Radius:  The radius of the circle to plot
;
; OPTIONAL INPUTS:
; Center: The center of the circle to plot
;
; KEYWORD PARAMETERS:
; RSUPPRESSED: If provided, this value is subtracted from the radius before plotting,
;   useful for polar plots of residuals from a given circle. radius can be suppressed
;   only if center is in origin (empty or set to [0,0]), otherwise it would not make sense. 

;   
; NP: number of points to be used for the plot, default to 100.
; 
; /OPLOT: If set, overplots
; 
; _EXTRA: extra keywords to be passed to the plot routines 
;
;
; PROCEDURE:
; It is a wrapper around SUPPRESSEDRADIUSPLOT, where arguments are
;   derived from the only radius and center values.
;
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo vincenzo.cotroneo.mi@gmail.com
;-

pro plot_circle,radius,rsuppressed=rsuppressed,center=center,np=np,oplot=oplot,$
  color=color,_extra=e

  if n_elements(np) eq 0 then np=100
  if n_elements(rsuppressed) eq 0 then rsuppressed=0
  if n_elements(center) eq 0 then c=[0,0] else c=center
  if rsuppressed ne 0 then $
    if not array_equal(c,[0,0]) then message,"you can suppress radius only if center is on origin"
  th=findgen(np)/(np-1)*!PI*2
  
  ;if n_elements(radius) gt 1 then begin
    if n_elements(color) eq 1 then color=replicate(color,n_elements(radius)) $
    else if n_elements(color) ne n_elements(radius) then color=plotcolors(n_elements(radius))
    
    for i =0,n_elements(radius)-1 do begin
      r=replicate(radius[i],np)
      x=r*cos(th)+c[0]
      y=r*sin(th)+c[1]
      ;suppressedRadiusPlot,x,y,rsuppressed,/polar,center=center,$
      ;  _extra=e,oplot=oplot,color=color[i]
      if keyword_set(oplot) then $
        oplot, x-rsuppressed,y,color=color[i],_extra=e $
      else $
        plot, x-rsuppressed,y,color=color[i],_extra=e
      oplot=1      
    endfor
  ;endif


end

function plot_circle,radius,rsuppressed=rsuppressed,center=center,np=np,oplot=oplot,$
  color=color,_extra=e

  if n_elements(np) eq 0 then np=100
  if n_elements(rsuppressed) eq 0 then rsuppressed=0
  if n_elements(center) eq 0 then c=[0,0] else c=center
  if rsuppressed ne 0 then $
    if not array_equal(c,[0,0]) then message,"you can suppress radius only if center is on origin"
  th=findgen(np)/(np-1)*!PI*2

  ;if n_elements(radius) gt 1 then begin
  if n_elements(color) eq 1 then color=replicate(color,n_elements(radius)) $
  else if n_elements(color) ne n_elements(radius) then color=plotcolors(n_elements(radius))

  for i =0,n_elements(radius)-1 do begin
    r=replicate(radius[i],np)
    x=r*cos(th)+c[0]
    y=r*sin(th)+c[1]
    ;suppressedRadiusPlot,x,y,rsuppressed,/polar,center=center,$
    ;  _extra=e,oplot=oplot,color=color[i]
    if keyword_set(oplot) then $
      p=plot (x-rsuppressed,y,color=color[i],/overplot,_extra=e) $
    else $
      p=plot (x-rsuppressed,y,color=color[i],_extra=e)
    oplot=1
  endfor
  ;endif
  return, p 

end

f=plot_circle(10,aspect_ratio=1)
f=plot_circle(5,/oplot)
f=plot_circle([0.5,2,3],/oplot,color='blue')
f=plot_circle([1.5,2.5,3.5],/oplot,color=['green','orange','yellow'])

window,/free
plot_circle,10
plot_circle,5,/oplot
plot_circle,[0.5,2,3],/oplot,color='blue'
plot_circle,[1.5,2.5,3.5],/oplot,color=['green','orange','yellow']
end
