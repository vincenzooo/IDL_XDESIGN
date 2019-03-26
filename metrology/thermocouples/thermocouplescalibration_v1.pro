
rootfolder='/home/cotroneo/Desktop/slumpingData/run001'
folderList=['run001_calib_T13_14h','run001_calib_T15_16h','run001_calib_T16_17h','run001_calib_T17_18h']
fileList=folderList+path_sep()+'run001_data_summary.txt'
legendstring=['13-14h','14-15h','15-16h','17-18h']
outfile='calibration.eps'

npoints=n_elements(folderlist)

x=fltarr(npoints)
xerr=fltarr(npoints)
y=fltarr(npoints)
yerr=fltarr(npoints)

for i=0,npoints-1 do begin
  stats=READ_DATAMATRIX(rootFolder+path_sep()+fileList[i],skipline=1)
  x[i]=float(stats[1,0])
  xerr[i]=float(stats[7,0])
  y[i]=float(stats[1,2])
  yerr[i]=float(stats[7,2])
endfor
;plot,x,y,psym=4,xstyle=(!x.style and 30),ystyle=(!y.style and 30)

;scatterplot,x,y,/first,/last,expansion=1.1,/square,background=255,color=0
;oplot,x,y,psym=4,color=0

colors=2+indgen(npoints)
range=squarerange([x-xerr,x+xerr],[y-yerr,y+yerr],expansion=1.1)
plot,x,y,xrange=range[0:1],yrange=range[2:3],linestyle=1,thick=2,background=255,color=0,$
    title='Temperatures averaged over 1 hour intervals',/isotropic,$
    xtitle='TC1 temperature ('+greek('degrees')+'C)',ytitle='TC2 temperature ('+greek('degrees')+'C)'
USERSYM, [-2, 0, 2, 0, -2] , [0, 2, 0, -2, 0],/fill
for i=0,npoints-1 do begin
  oploterror, x[i:i], y[i:i], xerr[i:i], yerr[i:i],psym=8,color=colors[i],errcolor=0
endfor
legend,legendString,color=colors,position=13

SET_PLOT, 'PS'
DEVICE, filename=rootfolder+path_sep()+outfile, /COLOR,/encapsulated
plot,x,y,xrange=range[0:1],yrange=range[2:3],linestyle=1,thick=2,background=255,color=0,$
    title='Temperatures averaged over 1 hour intervals',/isotropic,$
    xtitle='TC1 temperature ('+greek('degrees')+'C)',ytitle='TC2 temperature ('+greek('degrees')+'C)'
USERSYM, [-2, 0, 2, 0, -2] , [0, 2, 0, -2, 0],/fill
for i=0,npoints-1 do begin
  oploterror, x[i:i], y[i:i], xerr[i:i], yerr[i:i],psym=8,color=colors[i],errcolor=0
endfor
legend,legendString,color=colors,position=13
SET_PLOT_default

end