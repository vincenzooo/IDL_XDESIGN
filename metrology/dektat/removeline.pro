pro multiplot,x_m,y_m,_extra=e,psfile,linecolors=colors,oplot=oplot,nolegend=nolegend,color=color,legend=legstr

if n_elements(psfile) ne 0 then begin
  if psfile ne '' then begin ;to allow conditional passing of empty string to prevent plot
    thstore=[!P.thick,!X.thick,!y.thick,!P.charthick]
    !P.thick=2
    !X.thick=2
    !y.thick=2
    !P.charthick=2
    SET_PLOT, 'PS'
    DEVICE, filename=psfile, /COLOR,/encapsulated  
  endif
endif

s=size(x_m)
ndim=s[0]
if ndim eq 1 then begin
  nvectors=1 
;  x_m=reform(x_m,s[1],1)
;  y_m=reform(y_m,s[1],1)
endif else nvectors=s[2]

if n_elements(colors) eq 0 then colors=plotcolors(nvectors)

if keyword_set(oplot) eq 0 then plot,[0],[0],xrange=range(x_m),yrange=range(y_m),_extra=e,color=color
oplot,x_m[*,0],y_m[*,0],color=colors[0],_extra=e
for i=1,nvectors-1 do begin
  oplot,x_m[*,i],y_m[*,i],color=colors[i],_extra=e
endfor
if keyword_set(nolegend) eq 0 then begin
  if n_elements(legstr) eq 0 then begin
      legstr=sindgen(nvectors+1)
      legstr=legstr[1:nvectors]
  endif
  legend,legstr,color=colors,position=12
  if n_elements(psfile) ne 0 then begin
    if psfile ne '' then begin
      DEVICE, /CLOSE 
      SET_PLOT_default
      !P.thick=thstore[0]
      !X.thick=thstore[1]
      !y.thick=thstore[2]
      !P.charthick=thstore[3]
    endif
  endif
endif

end