
rootfolder='/home/cotroneo/Desktop/slumpingData/run003'
folderList=['run003_T60_210m','run003_T330_510m','run003_T600_840m','run003_T930_1140m']
fileList=folderList+path_sep()+'run003_data_summary.txt'
legendstring=['400 ','450 ','500 ','580 ']+greek('degrees')+'C'
outfile='calibration_run003.eps'

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
    title='Temperatures averaged over time intervals',/isotropic,$
    xtitle='TC1 temperature ('+greek('degrees')+'C)',ytitle='TC2 temperature ('+greek('degrees')+'C)'
USERSYM, [-2, 0, 2, 0, -2] , [0, 2, 0, -2, 0],/fill
for i=0,npoints-1 do begin
  oploterror, x[i:i], y[i:i], xerr[i:i], yerr[i:i],psym=8,color=colors[i],errcolor=0
endfor
legend,legendString,color=colors,position=10

SET_PLOT, 'PS'
DEVICE, filename=rootfolder+path_sep()+outfile, /COLOR,/encapsulated
plot,x,y,xrange=range[0:1],yrange=range[2:3],linestyle=1,thick=2,background=255,color=0,$
    title='Temperatures averaged over time intervals',/isotropic,$
    xtitle='TC1 temperature ('+greek('degrees')+'C)',ytitle='TC2 temperature ('+greek('degrees')+'C)'
USERSYM, [-2, 0, 2, 0, -2] , [0, 2, 0, -2, 0],/fill
for i=0,npoints-1 do begin
  oploterror, x[i:i], y[i:i], xerr[i:i], yerr[i:i],psym=8,color=colors[i],errcolor=0
endfor
legend,legendString,color=colors,position=13
SET_PLOT_default

for i = 0,n_elements(folderList)-1 do begin
  ;Statistics
  winnum=winnum+1
  window,winnum,xsize=640
  histostart=min(sens1sel)-Tres    ;(fix(min(sens1sel)/Tres)-1)*Tres
  histoend=max(sens1sel)+Tres
  stats1=histostats(sens1sel,xrange=plotrange[0:1],yscale=1.1,position=10,$
       xtitle=graphTitle+' TC1 '+'Temperature ('+greek('degrees')+'C)',$
       binsize=tres,min=histostart,max=histoend,$
       ytitle='Fraction of data points',title= 'Temperature distribution'+titleSuffix,$
       psym=10,/normalize,outvars=intarr(8)+1,statString=statString1,$
       background=255,color=0,hist=histTC1,locations=locationsTC1)
  maketif,tifdir+path_sep()+basename+'TC1_stats'
  SET_PLOT, 'PS'
  DEVICE, filename=psdir+path_sep()+basename+'TC1_stats.eps', /COLOR,/encapsulated
  stats1=histostats(sens1sel,xrange=plotrange[0:1],yscale=1.1,position=10,$
       xtitle=graphTitle+' TC1 '+'Temperature ('+greek('degrees')+'C)',$
       binsize=tres,min=histostart,max=histoend,$
       ytitle='Fraction of data points',title= 'Temperature distribution'+titleSuffix,$
       psym=10,/normalize,outvars=intarr(8)+1,statString=statString1,$
       background=255,color=0)
  DEVICE, /CLOSE 
  SET_PLOT_default
  writecol,outdir+path_sep()+basename+'TC1_hist.dat',locationsTC1,histTC1,$
            header='T  fraction_of_points'
 endfor

end