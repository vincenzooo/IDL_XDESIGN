pro convertToSeconds,filename,timesec,tAmbient,sens1,sens2,outdir=outdir
  ;convert the time in seconds and generate a new file 
  datadir=file_dirname(filename)
  dummy=file_extension(filename,basename)
  outfile=file_basename(basename)+'.dat'
  readcol,filename,time,tAmbient,sens1,sens2,F='A,F,F,F,X,X,X,X',skip=2
  npoints=n_elements(time)
  timesec=lonarr(npoints)
  for i =0,npoints-1 do begin
    hms=fix(strsplit(time[i],':',/extract),type=3)
    timesec[i]=hms[0]*3600.+hms[1]*60.+hms[2]
  endfor
  if ~keyword_set(outdir) then outdir=datadir
  writecol,outdir+path_sep()+outfile,timesec,tAmbient,sens1,sens2,$
  header='Time(sec) T_ambient('+greek('degrees')+'C) T_sens1('+greek('degrees')+'C) T_sens2('+greek('degrees')+'C)'
end

function thermocouplesPrecision,filedata,timeIntervalH,$
    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,force=force,$
    tempProfile=tp,timebin=timebin,setPointROI=setPointROI,plateauROI=plateauROI
;+
; :Description:
;   Perform an analysis of 3-columns data (2 thermocouples for the chamber + 1 for the ambient) over a time interval.
;
; :Params:
;  FILEDATA: is the file with the data (reading from thermocouples). 
;      4 columns: with 1st line header:
;      Time(sec) T_ambient(°C) T_sens1(°C) T_sens2(°C)
;  TIMEINTERVALH: Optional. It is a 2-elements vector with start and end (in hours) of the region to analyze.
;
; :Keywords:    
;
;TEMPPROFILE is the file with the profiler settings (time and temperature of setpoints). 
;DIRRESULT is the directory that will store all the results, if not set, create a new
;  directory with the name of the data file.
;FORCE: if set, execute without asking overwrite confirmation.
;GRAPHTITLE: used to build title and axis titles in plot.
;TRES: Temperature resolution, used for histograms bins, for margins in scatterplot and for smoothing in timeprofiles. 
;
; :Author: cotroneo
;-

winnum=-1 ;begin to plot on window 0

;set the data file and the basename that will be used in the routine  
tempprofileFile=file_dirname(filedata)+path_sep()+tp
dummy=file_extension(filedata,basename)

if n_elements(dirResult) ne 0 then outdir=file_dirname(filedata)+path_sep()+dirResult $
  else outdir=file_dirname(filedata)+path_sep()+basename
psdir=outdir+path_sep()+'PS'
tifdir=outdir+path_sep()+'TIF'

;check for overwrite (if FORCE is not set)
if file_test(outdir,/directory) ne 0 and keyword_Set(force) eq 0 then begin
  ;folder existing
  answer=dialog_message('Folder '+outdir+$
  'already existing.'+newline()+'Overwrite eventual previous results?',/cancel)
  if answer ne 'OK' then stop
endif else file_mkdir,outdir

file_mkdir,psdir
file_mkdir,tifdir

;start the logfile
get_lun, uf
openw,uf,outdir+path_sep()+basename+'_log.txt'
printf,uf,"pro thermocouplesPrecision executed on ",systime()  
printf,uf
printf,uf,"analysis on file:",filedata
cd,current=current
printf,uf,"current directory: ",current
printf,uf,"Temperature resolution= ",Tres  

;convert the time in numeric format (seconds) and load sensors and profiler data
convertToSeconds,filedata,timesec,tAmbient,sens1,sens2,outdir=outdir
readcol,tempProfileFile,timeProf,tempProf

if n_elements(timeintervalH) ne 0 then begin
    timeStartH=timeIntervalH[0]
    timeEndH=timeIntervalH[1]
    printf,uf,"Time interval: ",strjoin(strtrim(string([timestartH,timeendH]),2),'--')," h = ",$
    strjoin(strtrim(string([timestartH,timeendH]*3600l),2),'--')," s"
endif else begin
  timeStartH=timesec[0]/3600.
  timeEndH=timesec[n_elements(timesec)-1]/3600.
  printf,uf,"Time interval not provided. Use full time range: ",strjoin(strtrim(string([timestartH,timeendH]),2),'--')," h = ",$
    strjoin(strtrim(string([timestartH,timeendH]*3600l),2),'--')," s"
endelse  

;plot the temperature profiles over the whole range
winnum=winnum+1
window,winnum
plot,timeprof,tempProf,ytitle='Oven Temperature'+$
    ' ('+greek('degrees')+'C)',xtitle='Time (h)',xmargin=[8,8],$
    background=255,color=0,ystyle=8
oplot,timesec/3600.,sens1,color=2
oplot,timesec/3600.,sens2,color=4
axis,yaxis=1,/save,yrange=[-10,25],color=0,$
    ytitle='Temperature Difference TC2-TC1 ('+greek('degrees')+'C)'
oplot,timesec/3600.,sens2-sens1,color=9
oplot,timesec/3600.,tAmbient,color=8
legend,['Oven Profiler','TC1','TC2','Temperature difference (TC2-TC1) on Y2',' Ambient Temperature on Y2'],$
    color=[0,2,4,9,8],position=9
maketif,tifdir+path_sep()+basename+'Temp_profile'    
SET_PLOT, 'PS'
DEVICE, filename=psdir+path_sep()+basename+'Temp_profile.eps', /COLOR,/encapsulated
plot,timeprof,tempProf,ytitle='Oven Temperature'+$
    ' ('+greek('degrees')+'C)',xtitle='Time (h)',xmargin=[8,8],$
    background=255,color=0,ystyle=8
oplot,timesec/3600.,sens1,color=2
oplot,timesec/3600.,sens2,color=4
axis,yaxis=1,/save,yrange=[-10,25],color=0,$
    ytitle='Temperature Difference TC2-TC1 ('+greek('degrees')+'C)'
oplot,timesec/3600.,sens2-sens1,color=9
oplot,timesec/3600.,tAmbient,color=8
legend,['Oven Profiler','TC1','TC2','Temperature difference (TC2-TC1) on Y2',' Ambient Temperature on Y2'],$
    color=[0,2,4,9,8],position=9
DEVICE, /CLOSE 
SET_PLOT_default

;extract and plot relation between the two sensors
sens1sel=extractxrange(timesec,sens1,timesel,xindex=xindex,$
                        xstart=timeStartH*3600l,xend=timeEndH*3600l)
sens2sel=sens2[xindex]
tAmbientSel=tAmbient[xindex]
npoints=n_elements(xindex)

;output of selected data (in the range of interest) and scatterplot of data from 2 thermocouples.
winnum=winnum+1
window,winnum
writecol,outdir+path_sep()+basename+'_seldata.dat',timesel,tAmbientsel,sens1sel,sens2sel,$
header='Time(sec) T_ambient('+greek('degrees')+'C) T_sens1('+greek('degrees')+'C) T_sens2('+greek('degrees')+'C)'
titleSuffix=', t='+strtrim(string(timeStartH),2)+'-'+$
      strtrim(string(timeEndH),2)+"(h), "+strtrim(string(npoints),2)+$
      " pts" 
scatterPlot,sens1sel,sens2sel,$
        xtitle='Temp TC1 ('+greek('degrees')+'C)',$
        ytitle='Temp TC2 ('+greek('degrees')+'C)',$
        title=graphTitle+titleSuffix,$
        margin=Tres,expansion=1.0,plotrange=plotrange,$
        /square,psym=-4,background=255,color=0,$
        /first,/last,$
        tif=tifdir+path_sep()+basename,$
        ps=psdir+path_sep()+basename,$
        window=1,wxsize=640,wysize=640

;--------------------------
;Statistics
winnum=winnum+1
window,winnum,xsize=640
histostart=min(sens1sel)-Tres    ;(fix(min(sens1sel)/Tres)-1)*Tres
histoend=max(sens1sel)+Tres
stats1=histostats(sens1sel,xrange=plotrange[0:1],yscale=1.1,position=10,$
     xtitle=graphTitle+' TC1 '+'Temperature ('+greek('degrees')+'C)',$
     binsize=tres,min=histostart,max=histoend,$
     ytitle='Fraction of data points',title= 'Temperature distribution'+titleSuffix,$
     psym=10,/normalize,outvars=indgen(8),statString=statString1,$
     background=255,color=0,hist=histTC1,locations=locationsTC1)
maketif,tifdir+path_sep()+basename+'TC1_stats'
SET_PLOT, 'PS'
DEVICE, filename=psdir+path_sep()+basename+'TC1_stats.eps', /COLOR,/encapsulated
stats1=histostats(sens1sel,xrange=plotrange[0:1],yscale=1.1,position=10,$
     xtitle=graphTitle+' TC1 '+'Temperature ('+greek('degrees')+'C)',$
     binsize=tres,min=histostart,max=histoend,$
     ytitle='Fraction of data points',title= 'Temperature distribution'+titleSuffix,$
     psym=10,/normalize,outvars=indgen(8),statString=statString1,$
     background=255,color=0)
DEVICE, /CLOSE 
SET_PLOT_default
writecol,outdir+path_sep()+basename+'TC1_hist.dat',locationsTC1,histTC1,$
          header='T  fraction_of_points'

winnum=winnum+1
window,winnum,xsize=640
histostart=min(sens2sel)-Tres    ;(fix(min(sens1sel)/Tres)-1)*Tres
histoend=max(sens2sel)+Tres
stats2=histostats(sens2sel,xrange=plotrange[2:3],yscale=1.1,position=12,$
     xtitle=graphTitle+' TC2 '+'Temperature ('+greek('degrees')+'C)',$
     binsize=tres,min=histostart,max=histoend,$
     ytitle='Fraction of data points',title= 'Temperature distribution'+titleSuffix,$
     psym=10,/normalize,outvars=indgen(8),statString=statString2,$
     background=255,color=0)
maketif,tifdir+path_sep()+basename+'TC2_stats'
SET_PLOT, 'PS'
DEVICE, filename=psdir+path_sep()+basename+'TC2_stats.eps', /COLOR,/encapsulated
stats2=histostats(sens2sel,xrange=plotrange[2:3],yscale=1.1,position=12,$
     xtitle=graphTitle+' TC2 '+'Temperature ('+greek('degrees')+'C)',$
     binsize=tres,min=histostart,max=histoend,$
     ytitle='Fraction of data points',title= 'Temperature distribution'+titleSuffix,$
     psym=10,/normalize,outvars=indgen(8),statString=statString2,$
     background=255,color=0,hist=histTC2,locations=locationsTC2)
DEVICE, /CLOSE 
SET_PLOT_default
writecol,outdir+path_sep()+basename+'TC2_hist.dat',locationsTC2,histTC2,$
          header='T  fraction_of_points'

winnum=winnum+1
window,winnum,xsize=640
histostart=min(tAmbientSel)-Tres    ;(fix(min(sens1sel)/Tres)-1)*Tres
histoend=max(tAmbientSel)+Tres
stats3=histostats(tAmbientSel,yscale=1.1,position=12,$
     xtitle=graphTitle+' Ambient Temperature ('+greek('degrees')+'C)',$
     binsize=tres,$
     ytitle='Fraction of data points',title= 'Temperature distribution'+titleSuffix,$
     psym=10,/normalize,outvars=indgen(8)+1,statString=statString3,$
     background=255,color=0)
maketif,tifdir+path_sep()+basename+'Ambient_stats'
SET_PLOT, 'PS'
DEVICE, filename=psdir+path_sep()+basename+'Ambient_stats.eps', /COLOR,/encapsulated
stats3=histostats(tAmbientSel,yscale=1.1,position=12,$
     xtitle=graphTitle+' Ambient Temperature ('+greek('degrees')+'C)',$
     binsize=tres,$
     ytitle='Fraction of data points',title= 'Temperature distribution'+titleSuffix,$
     psym=10,/normalize,outvars=indgen(8),statString=statString3,$
     background=255,color=0,hist=histAmbient,locations=locationsAmbient)
DEVICE, /CLOSE 
SET_PLOT_default
writecol,outdir+path_sep()+basename+'Ambient_hist.dat',locationsAmbient,histAmbient,$
          header='T  fraction_of_points'

;-------------
;temperature trend
timebinnp=fix(timebin/(timesec[1]-timesec[0]))
printf,uf,"Time resolution for smoothed plots= ",timebin, "s = ",timebinnp," pts"   ;update logfile

;determines yrange
residualRange=[min([sens1sel-stats1[0],sens2sel-stats2[0],tAmbientsel-stats3[0]]),$
        max([sens1sel-stats1[0],sens2sel-stats2[0],tAmbientsel-stats3[0]])]

;plot
winnum=winnum+1
window,winnum
plot,timesel/3600.,sens1sel-stats1[0],$
    title='TC1 residuals, '+graphTitle+titleSuffix,xtitle='Time (h)',$
    ytitle='Deviation from mean ('+Greek('degrees')+'C)',$
    background=255,color=0,yrange=residualRange
dev1sm=smooth(sens1sel-stats1[0],timebinnp,/edge_truncate)
oplot,timesel/3600.,dev1sm,color=50,thick=3
legend,['Measured','Smoothed on '+strtrim(string(timebin),2)+' s'],$
       color=[0,50],position=6
stats1sm=histostats(dev1sm,/legend,position=5,statString=stat1smSt,$
         outvars=indgen(8),btitle='- Smoothed data stats -')

maketif,tifdir+path_sep()+basename+'TC1_trend'
SET_PLOT, 'PS'
DEVICE, filename=psdir+path_sep()+basename+'TC1_trend.eps', /COLOR,/encapsulated
plot,timesel/3600.,sens1sel-stats1[0],$
    title='TC1 residuals, '+graphTitle+titleSuffix,xtitle='Time (h)',$
    ytitle='Deviation from mean ('+Greek('degrees')+'C)',$
    background=255,color=0,yrange=residualRange
dev1sm=smooth(sens1sel-stats1[0],timebinnp,/edge_truncate)
oplot,timesel/3600.,dev1sm,color=50,thick=3
legend,['Measured','Smoothed on '+strtrim(string(timebin),2)+' s'],$
       color=[0,50],position=6
stats1sm=histostats(dev1sm,/legend,position=5,statString=stat1sm,$
         outvars=indgen(8),btitle='- Smoothed data stats -')
DEVICE, /CLOSE 
SET_PLOT_default

winnum=winnum+1
window,winnum
plot,timesel/3600.,sens2sel-stats2[0],$
    title='TC2 residuals, '+graphTitle+titleSuffix,xtitle='Time (h)',$
    ytitle='Deviation from mean ('+Greek('degrees')+'C)',$
    background=255,color=0,yrange=residualRange
dev2sm=smooth(sens2sel-stats2[0],timebinnp,/edge_truncate)
oplot,timesel/3600.,dev2sm,color=50,thick=3
legend,['Measured','Smoothed on '+strtrim(string(timebin),2)+' s'],$
       color=[0,50],position=6
stats2sm=histostats(dev2sm,/legend,position=5,statString=stat2sm,$
         outvars=indgen(8),btitle='- Smoothed data stats -')
maketif,tifdir+path_sep()+basename+'TC2_trend'
SET_PLOT, 'PS'
DEVICE, filename=psdir+path_sep()+basename+'TC2_trend.eps', /COLOR,/encapsulated
plot,timesel/3600.,sens2sel-stats2[0],$
    title='TC2 residuals, '+graphTitle+titleSuffix,xtitle='Time (h)',$
    ytitle='Deviation from mean ('+Greek('degrees')+'C)',$
    background=255,color=0,yrange=residualRange
dev2sm=smooth(sens2sel-stats2[0],timebinnp,/edge_truncate)
oplot,timesel/3600.,dev2sm,color=50,thick=3
legend,['Measured','Smoothed on '+strtrim(string(timebin),2)+' s'],$
       color=[0,50],position=6
stats2sm=histostats(dev2sm,/legend,position=5,statString=stat2smSt,$
         outvars=indgen(8),btitle='- Smoothed data stats -')
DEVICE, /CLOSE 
SET_PLOT_default

winnum=winnum+1
window,winnum
plot,timesel/3600.,tAmbientSel-stats3[0],$
    title='Ambient residuals, '+graphTitle+titleSuffix,xtitle='Time (h)',$
    ytitle='Deviation from mean ('+Greek('degrees')+'C)',$
    background=255,color=0,yrange=residualRange
dev3sm=smooth(tAmbientSel-stats3[0],timebinnp,/edge_truncate)
oplot,timesel/3600.,dev3sm,color=50,thick=3
legend,['Measured','Smoothed on '+strtrim(string(timebin),2)+' s'],$
       color=[0,50],position=6
stats3sm=histostats(dev3sm,/legend,position=5,statString=stat3sm,$
         outvars=indgen(8),btitle='- Smoothed data stats -')
maketif,tifdir+path_sep()+basename+'Tambient_trend'
SET_PLOT, 'PS'
DEVICE, filename=psdir+path_sep()+basename+'TAmbient_trend.eps', /COLOR,/encapsulated
plot,timesel/3600.,tAmbientSel-stats3[0],$
    title='Ambient residuals, '+graphTitle+titleSuffix,xtitle='Time (h)',$
    ytitle='Deviation from mean ('+Greek('degrees')+'C)',$
    background=255,color=0,yrange=residualRange
oplot,timesel/3600.,dev3sm,color=50,thick=3
legend,['Measured','Smoothed on '+strtrim(string(timebin),2)+' s'],$
       color=[0,50],position=6
stats3sm=histostats(dev3sm,/legend,position=5,statString=stat3sm,$
         outvars=indgen(8),btitle='- Smoothed data stats -')
DEVICE, /CLOSE 
SET_PLOT_default

printf,uf,"Npoints= ",npoints
printf,uf
printf,uf
printf,uf,"-- Statistics for TC1 --"
printf,uf,strjoin(statString1,newline())
printf,uf
printf,uf,"-- Statistics for TC1 residual (smoothed with boxcar averaging, box width: "+$
      strtrim(string(timebin),2)+" s = "+ strtrim(string(timebinnp),2)+ " pts) --"
printf,uf,strjoin(stat1smSt,newline())
printf,uf
printf,uf,"-- Statistics for TC2 --"
printf,uf,strjoin(statString2,newline())
printf,uf
printf,uf,"-- Statistics for TC2 residual (smoothed with boxcar averaging, box width: "+$
      strtrim(string(timebin),2)+" s = "+strtrim(string(timebinnp),2)+ " pts) --"
printf,uf,strjoin(stat2smSt,newline())
printf,uf

free_lun,uf

statsMatrix=[[stats1],[stats1sm],[stats2],[stats2sm],[stats3],[stats3sm]]

write_datamatrix,outdir+path_sep()+basename+'_summary.txt',statsMatrix,$
    header='Mean PV Min Max Std_dev(rms) Mean_abs_dev(Ra)  Mean_std_dev Variance',$
    y=['TC1','TC1_smoothed(dev)','TC2','TC2_smoothed(dev)','Ambient','Ambient_smoothed(dev)']


return,statsMatrix
end

setStandardDisplay
SET_PLOT_default

Tres=0.1 ;temperature resolution of the sensors in Celsius
timebin=240 ;time bin for smoothing in s 

;RUN001------------------------------------------------------------------
;filedata=fn('/home/cotroneo/Desktop/slumpingData/run001/run001_data.dat')
;graphtitle='Calibration Run'
;profilerFile='thermalCycleCalibration.txt'
;timeIntervalH=[13,18]
;dirResult='run001_calib_T13_18h'
;
;timeIntervalH=[13,18]
;dirResult='run001_calib_T13_18h'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;    
;timeIntervalH=[14,17]
;dirResult='run001_calib_T14_17h'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;
;timeIntervalH=[15,16]
;dirResult='run001_calib_T15_16h'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;
;timeIntervalH=[13,14]
;dirResult='run001_calib_T13_14h'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;
;timeIntervalH=[14,15]
;dirResult='run001_calib_T14_15h'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;
;timeIntervalH=[16,17]
;dirResult='run001_calib_T16_17h'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;
;timeIntervalH=[17,18]
;dirResult='run001_calib_T17_18h'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;    
;end RUN001------------------------------------------------------------------

;;RUN003------------------------------------------------------------------
;filedata=fn('/home/cotroneo/Desktop/slumpingData/run003/run003_data.dat')
;graphtitle='Calibration Run 003'
;profilerFile='thermalCycle.txt'
;
;timeIntervalH=[1,3.5]
;dirResult='run003_T60_210m'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;
;timeIntervalH=[5.5,8.5]
;dirResult='run003_T330_510m'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;    
;timeIntervalH=[10,14]
;dirResult='run003_T600_840m'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;    
;timeIntervalH=[15.5,19]
;dirResult='run003_T930_1140m'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;;end RUN003------------------------------------------------------------------


;RUN013------------------------------------------------------------------
;datadir=fn('E:\work\workSlumping\run3_13\run13_TClog.dat')  ;windows
datadir=fn('/home/cotroneo/Desktop/work_slumping/run3_13/data')   ;unix
;runTitle='Run005'
;graphtitle=runtitle
;timeIntervalH=[16.5,19.0]
;profilerFile=runtitle+'_profile.dat'
;dirResult=runtitle+'_580C'
;filedata=datadir+path_sep()+runtitle+'_TClog.dat'

runTitle='Run005'
graphtitle=runtitle
timeIntervalH=[15.5,19.1]
profilerFile=runtitle+'_profile.dat'
dirResult=runtitle+'_580C'
filedata=datadir+path_sep()+runtitle+'_TClog.dat'

stats=thermocouplesPrecision(filedata,timeIntervalH,$
    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
    tempProfile=profilerFile,timebin=timebin)

;timeIntervalH=[2.6,3.4]
;dirResult='run013_500C'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
;
;timeIntervalH=[4.1,4.9]
;dirResult='run013_550C'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)
; 
;timeIntervalH=[5.6,6.4]
;dirResult='run013_600C'
;stats=thermocouplesPrecision(filedata,timeIntervalH,$
;    graphTitle=graphTitle,Tres=Tres,dirResult=dirResult,$
;    tempProfile=profilerFile,timebin=timebin)   

end

;window,3,xsize=640
;;statistical analysis and histogram
;;replaced by function histostats
;histostart=min(sens1sel)-Tres    ;(fix(min(sens1sel)/Tres)-1)*Tres
;histoend=max(sens1sel)+Tres
;sens1hist=histogram(sens1sel,min=histostart,max=histoEnd,$
;      binsize=Tres,locations=xT1)
;sens1hist=sens1hist/total(sens1hist)
;plot,xT1,float(sens1hist),$ 
;     xtitle=graphTitle+' TC1 '+'Temperature ('+greek('degrees')+'C)',$
;     ytitle='Fraction of data points',$
;     title= 'Temperature distribution'+$
;     titleSuffix,psym=10,xrange=plotrange[0:1]+[-Tres,Tres],$
;     yrange=[0,max(sens1hist)*1.1],$
;     background=255,color=0
;result=moment(sens1sel,mdev=avgdev,sdev=stddev,/nan,maxmoment=2)
;avg = result[0]
;var = result[1]
;label=['min='+strtrim(string(min(sens1sel)),2),$
;       'max='+strtrim(string(max(sens1sel)),2),$
;       'PV='+strtrim(string(max(sens1sel)-min(sens1sel)),2),$
;       'mean='+strtrim(string(avg),2),$
;       'variance='+strtrim(string(var),2),$
;       'mean abs. dev.='+strtrim(string(avgdev),2),$
;       'std. dev.='+strtrim(string(stddev)),$
;       'mean. std. dev.='+strtrim(string(stddev/sqrt(npoints-1.)),2)]
;PLOT_TEXT,label,POSITION=10,color=intarr(n_elements(label))