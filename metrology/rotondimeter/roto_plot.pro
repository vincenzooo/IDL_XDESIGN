pro roto_plot, radius,angle=ang,range=range,offset=offset,oplot=oplot,color=graphcol
;fa casino se lanciato con oplot e offset diverso

if n_elements(offset) eq 0 then offset=0
if n_elements (graphcol) eq 0 then graphcol=50
gridcol=0
bckgrndcol=255
gridlinestyle=2 ;dashed
ntics=5
op=n_elements(oplot) ne 0

device, decomposed =0
tek_color
loadct, 39
if n_elements(degree) ne 0 then angrad=ang/180*!PI $
else if n_elements(ang) eq 0 then angrad=2*!pi*findgen(n_elements(radius))/(n_elements(radius)-1)

Rmed=total(radius)/n_elements(radius)
deltaR=min(radius)-Rmed
Rplot=radius-Rmed+offset-deltaR

if n_elements (range) eq 0 then begin
  if op then begin
    rangemax=!X.crange[1] 
  endif else begin
    xmax=max(abs(Rplot*cos(angrad)))
    ymax=max(abs(Rplot*sin(angrad)))
    rangemax=max([xmax,ymax])
  endelse
endif

if not op then plot,Rplot,angrad,/polar,/isotropic,xstyle=5,ystyle=5,background=bckgrndcol, $
    xrange=[-rangemax,rangemax],yrange=[-rangemax,rangemax]

print,rangemax
print,!x.range,!x.crange
;plotta  gli assi e la griglia
rGrid=findgen(ntics)/(ntics-1)*rangemax
for i=0,ntics-1 do oplot,0*angrad+rgrid[i],angrad,/polar,color=gridcol,linestyle=gridlinestyle
rtics=rGrid-rangemax
;plot,[0.,1.,1.,0.],[0.,0.,1.,1.],color=gridcol,linestyle=gridlinestyle,/noerase,/normal
AXIS, 0, 0, /XAXis,xminor=-1,color=gridcol,xtickinterval=1./(ntics-1)*rangemax,$
        xstyle=1,xtickname=REPLICATE(' ', 2*ntics+1)
AXIS, 0, 0, /yAXis,yminor=-1,color=gridcol,ytickinterval=1./(ntics-1)*rangemax,$
        ystyle=1,ytickv=rtics,ytickname=REPLICATE(' ', ntics)
;AXIS, 0, 0, /YAXIS,yminor=-1,color=gridcol

oplot,Rplot,angrad,/polar,color=graphcol

end

pro roto_data, datafile
offset=50
graphcol=50
gridcol=0
bckgrndcol=255
gridlinestyle=2 ;dashed
ntics=5

device, decomposed =0
tek_color
loadct, 39

readcol,datafile,ang,radius


angrad=ang/180*!PI
roto_plot,radius

end