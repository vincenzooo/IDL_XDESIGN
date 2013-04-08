;test objarr
nscans=3
npoints=5

cols=fltarr(npoints*nscans,3)
file='E:\work\work_ratf\run2b\2011_03_07\latact_test\Moore-Scan-Vert-surface-0V.dat' ;windows
;file='/home/cotroneo/Desktop/work_ratf/run2b/2011_03_07/latact_test/Moore-Scan-Vert-surface-0V.dat' ;unix
readcol,file,z,x,y,format='X,F,F,F'
data=[[x],[y],[z]]

k=objarr(1)
k=objarr(nscans+1)
for i=1,nscans do begin
  k[i]=obj_new('CMMsurface',data,file,'prova#'+string(i,format='(i2.2)'))
endfor
help,/heap

;for i=1,nscans do begin
;  obj_destroy,k[i]
;endfor
obj_destroy,k
undefine,k
help,/heap
end