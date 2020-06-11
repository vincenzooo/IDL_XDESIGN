;2020/06/11 purpose not clear, no reference found
; TODO: remove


pro plot_zcolors,x,y,z,zrange=zrange,_ref_extra=extra,overplot=overplot,$
    colorTable=colorTable,colorbar=colorbar,bartitle=bartitle,barformat=barformat,$
    barposition=barposition

if n_elements(zrange) eq 0 then begin
  zrange=[min(z),max(z)]
endif else begin
if n_elements(zrange) ne 2 then message,'2 Elements array needed for zrange, zrange = '+$
    string(zrange)+"help:",help,zrange
endelse

if n_elements(colorTable) ne 0 then begin
   TVLCT, oldPalette,/GET
   TVLCT, colorTable
endif

if n_elements (pmin) eq 0 then pmin=1
if pmin eq 0 then print,"WARNING: the zero color palette is used in plot (it is usually black)!"
if n_elements (pmax) eq 0 then pmax= !D.TABLE_SIZE-2
if pmax eq !D.TABLE_SIZE-1 then print,"WARNING: the last color palette is used in plot (it is usually white)!"

h=histogram(z,nbins=pmax-pmin+1,reverse_indices=ri)  ;esclude il colore 0 e last

if ~keyword_set(overplot) then plot,x,y,_extra=extra,/nodata
for i =0,pmax-pmin do begin
  if ri[i] ne ri[i+1] then begin
    sel=ri[ri[i]:ri[i+1]-1]
    oplot,x[sel],y[sel],psym=3, color=i+pmin,_extra=extra
  endif
endfor

if keyword_set(colorbar) then colorbar,/vertical,range=zrange,$
    title=bartitle,format=barformat,position=barPosition  ;,_extra=extra

if n_elements(colorTable) ne 0 then tvlct, oldPalette

end


