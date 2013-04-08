pro multi_plot,x_matrix,y_matrix,_extra=e,psfile=psfile,colors=colors,oplot=oplot,$
    nolegend=nolegend,legend=legstr,legpos=legpos,linestyles=linestyles,window=window,$
    nocloseps=nocloseps,psym=psym,thick=thick,BOXFUDGEX=BOXFUDGEX,background=background
;the previous version included one argument color for the plot and linecolors for the lines.
;in this version, there is only a vector argument COLORS, the first color is used for the
;plot, the others are used sequentially for the lines

;N.B.: the y range is selected on the whole set of data, even if xrange is set for plotting
;only a part.

;2012/10/01 added initial copy of input value to avoid modification.

;2011/08/09 added keyword NOCLOSEPS. It allows to leave the ps open, so it is possible to add labels to the plot
;(for calling from other routines, e.g. histostats).

x_m=x_matrix
if n_elements(y_matrix) eq 0 then begin
  y_m=x_m
  d=size(y_m,/dimension)
  x_m=indgen(d[0])
endif else y_m=y_matrix

nvectors=nvectors(y_m)
nvecx=nvectors(x_m)
npx=n_elements(x_m)/nvecx

if nvecx eq 1 then begin
  if n_elements(x_m) ne n_elements(y_m)/nvectors then message,'Vector provided as x has '+npx+' points.'+newline()+$
    'Array provided as y has '+string(n_elements(y_m)/nvectors)+' points and '+string(nvectors)+' vectors.'+newline()+$
    "They don't match!"
  x_m=rebin(x_m,npx,nvectors)
endif else begin
  if nvecx ne nvectors then message,string(nvectors)+' vectors are provided as y and '+string(nvecx)+' are provided as x.'+newline()+$
    'x vectors must be either 1 or the same number as y vectors.'
endelse


default_color=cgcolor('black')
if n_elements(colors) eq 0 then begin
  color=default_color
  linecolors=plotcolors(nvectors)
endif else if n_elements(colors) eq nvectors then begin
  warning,'MULTIPLOT WARNING: a color for the axis is not provided, color index 0 will be used.'
  color=default_color
  linecolors=colors
endif else if n_elements(colors) eq nvectors+1 then begin
  color=colors[0]
  linecolors=colors[1:n_elements(colors)-1]
endif else begin
  warning,'MULTIPLOT WARNING: the number of colors do not correspond to the number of vectors'+$
    ' (or nvectors +1 if you want include the color for axis). Colors will be replicated.' 
  color=default_color
  linecolors=reform(rebin(colors,n_elements(colors),fix(nvectors/n_elements(colors)),nvectors))
endelse
!P.color=color

bg=n_elements(background) eq 0?cgcolor('white'):background

if n_elements(linestyles) eq 0 then linestyles=intarr(nvectors) else $ 
if n_elements(linestyles) ne nvectors then begin
  warning,'MULTIPLOT WARNING: the number of linestyles do not correspond to the number of vectors.'+$
    ' Linestyles will be replicated.'
  linestyles=reform(rebin(linestyles,n_elements(linestyles),fix(nvectors/n_elements(linestyles)),nvectors))
endif

if n_elements(psym) ne 0 then begin
  if n_elements(psym) ne nvectors then begin
    warning,'MULTIPLOT WARNING: the number of psym do not correspond to the number of vectors.'+$
      ' psym will be replicated.'
    psym=reform(rebin([psym],n_elements(psym),fix(nvectors/n_elements(psym)),nvectors))
  endif
endif else begin
  psym=replicate(0,nvectors)
  if array_equal(linestyles,intarr(nvectors)) then linestyles=indgen(nvectors)  
endelse

if n_elements(thick) eq 0 then thick = !P.thick
if n_elements(thick) eq 1 then thick=replicate(thick,nvectors) else begin
  if n_elements(thick) ne nvectors then begin
    warning,'MULTIPLOT WARNING: the number of THICK do not correspond to the number of vectors.'+$
      ' THICK will be replicated.'
    thick=reform(rebin([thick],n_elements(thick),fix(nvectors/n_elements(thick)),nvectors))
  endif
endelse

if n_elements(e) ne 0 then begin
  if in('XRANGE',tag_names(e)) then begin ;this trick is needed because we want the eventual xrange passed
    ;as _extra argument to override the value in the plot call, that does not happen if we set xrange as 
    ;named argument. Note however that the usual abbreviation mechanism (e.g. xran=... will not work for the
    ;selection of yrange. 
    xr=e.xrange
    if nvecx ne 1 then message, 'more than 1 vector provided as x, cannot determine yrange.',/information
    ;put here a test for accepting multiple x vectors with same values (or set nvecx=1 at beginning).
    if n_elements(yrange) eq 0 then begin
      for i=0,nvectors-1 do begin
         dummy=extractxrange(x_m[*,i],y_m[*,i],xstart=xr[0],xend=xr[1])
         r=range(dummy)
         if i eq 0 then yrange=r else begin
            yrange[0]=r[0]<yrange[0]
            yrange[1]=r[1]>yrange[1]
         endelse 
      endfor
    endif 
  endif else begin
    yrange=range(y_m)
  endelse
endif else begin
  yrange=range(y_m)
endelse

if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
   else if keyword_set (noplot) eq 0 then begin
      if keyword_set(oplot) eq 0 then $
        if (n_elements(window) eq 0) then window,/free else window,window
endif

if n_elements(legpos) eq 0 then legpos=12
if keyword_set(oplot) eq 0 then plot,[0],[0],xrange=range(x_m),yrange=yrange,psym=psym[0],thick=thick[0],$
    _extra=e,color=color,/nodata,background=bg
oplot,x_m[*,0],y_m[*,0],color=linecolors[0],linestyle=linestyles[0],psym=psym[0],thick=thick[0],_extra=e
for i=1,nvectors-1 do begin
  oplot,x_m[*,i],y_m[*,i],color=linecolors[i],linestyle=linestyles[i],psym=psym[i],thick=thick[i],_extra=e
endfor
if keyword_set(nolegend) eq 0 then begin
  if n_elements(legstr) eq 0 then begin
      legstr=sindgen(nvectors+1)
      legstr=legstr[1:nvectors]
  endif
  legend,legstr,color=linecolors,position=legpos,linestyle=linestyles,psym=psym,thick=thick,BOXFUDGEX=BOXFUDGEX
endif
if keyword_set(nocloseps) eq 0 then begin
  if n_elements(psfile) ne 0 then begin
    if psfile ne '' then begin
      ;DEVICE, /CLOSE 
      ;SET_PLOT_default
      ps_end,_extra=e
      message,"PS closed",/informational
;      !P.thick=thstore[0]
;      !X.thick=thstore[1]
;      !y.thick=thstore[2]
;      !P.charthick=thstore[3]
    endif
  endif
endif

end

pro test_multi_plot,_extra=extra
    multi_plot,[4,5,9],window=1
    multi_plot,[[2,3,5],[4,5,9]]
    multi_plot,[10,11,12],[[2,3,5],[4,5,9]],window=3
    multi_plot,[[10,11,12],[1,4,5]],[[2,3,5],[4,5,9]],window=4
end

test_multi_plot

end