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
  if n_elements(outdir) eq 0 then outdir=datadir
  writecol,outdir+path_sep()+outfile,timesec,tAmbient,sens1,sens2,$
  header='Time(sec) T_ambient('+greek('degrees')+'C) T_sens1('+greek('degrees')+'C) T_sens2('+greek('degrees')+'C)'
end


;aggiungere profiler (dove? su asse 2 di ambient?)

xextensionfactor=1.05
setStandardDisplay
set_plot_default
if n_elements(ps) eq 0 then ps=0
datadir=fn('/home/cotroneo/Desktop/work_slumping/run3_13/data')
runTitle='Run016'
tp=runtitle+'_profile.dat' ;file with thermal profile
filedata=datadir+path_sep()+runtitle+'_TClog.dat'  ;file with logged thermocouples data

timeIntervalH=[12.0,24.0]  ;in hours
roi_time=[16.0,20.5]  ;in hoursTres=0.1 ;temperature resolution of the sensors in Celsius
timebin=240 ;time bin for smoothing in s
Tres=0.1 ;temperature resolution of the sensors in Celsius

tempprofileFile=file_dirname(filedata)+path_sep()+tp
dummy=file_extension(filedata,basename)

;convert the time in numeric format (seconds) and load sensors and profiler data
;convertToSeconds,filedata,timesec,tAmbient,sens1,sens2,outdir=datadir
readcol,filedata,timesec,tAmbient,sens1,sens2
readcol,tempProfileFile,timeProf,tempProf
timebinnp=fix(timebin/(timesec[1]-timesec[0]))
sens1sm=smooth(sens1,timebinnp,/edge_truncate)
sens2sm=smooth(sens2,timebinnp,/edge_truncate)


sens1sel=extractxrange(timesec,sens1,timesel,xindex=xindex,$
                        xstart=roi_time[0]*3600l,xend=roi_time[1]*3600l)
sens2sel=sens2[xindex]
npoints=n_elements(xindex)
histostart=min(sens1sel)-Tres    ;(fix(min(sens1sel)/Tres)-1)*Tres
histoend=max(sens1sel)+Tres
stats1=histostats(sens1sel,/noplot,$
     binsize=tres,min=histostart,max=histoend,$
     /normalize,outvars=[0,4],statString=statString1,$
     hist=histTC1,locations=locationsTC1)
histostart=min(sens2sel)-Tres    ;(fix(min(sens1sel)/Tres)-1)*Tres
histoend=max(sens2sel)+Tres
stats2=histostats(sens2sel,/noplot,$
     binsize=tres,min=histostart,max=histoend,$
     /normalize,outvars=[0,4],statString=statString2,$
     hist=histTC2,locations=locationsTC2)
;temperature trend
timebinnp=fix(timebin/(timesec[1]-timesec[0]))

dummy=extractxrange(timesec,sens1,xindex=longTimeIndex,$
                        xstart=timeIntervalH[0]*3600l,xend=timeIntervalH[1]*3600l)
Profilersel=extractxrange(timeprof*3600.,tempprof,seltimeProf,$
                        xstart=timeIntervalH[0]*3600l,xend=timeIntervalH[1]*3600l)

if ps ne 0 then ps_start,filename=datadir+path_sep()+runtitle+'_TClog.eps'
  ;fix common scale for y axis
  expandfactor=1.05
  yspan=max([range(sens1[longTimeIndex],median=m1,/size),range(sens2[longTimeIndex],median=m2,/size),$
      range(tAmbient[longTimeIndex],median=m3,/size),range(profilersel,median=m4,/size)])*expandfactor/2
  !p.multi=0
  !P.MULTI = [0, 1, 3] 
  ;TC1
  plot,timesec/3600.,sens1,title='Temperature ('+Greek('degrees')+'C)',xrange=timeIntervalH,$
  background=fsc_color('white'),color=fsc_color('black'),charsize=2,ytitle='TC1',$
  ymargin=[0,!y.margin[1]],xtickformat='(A1)',yrange=[m1-yspan,m1+yspan],xmargin=[8,8]
  oplot,timesec/3600.,sens1sm,color=fsc_color('blue'),thick=2
  oplot,!X.crange,[stats1[0],stats1[0]],color=fsc_color('black'),thick=3,linestyle=3
  oplot,!X.crange,[stats1[0],stats1[0]]+stats1[1],color=fsc_color('black'),thick=1,linestyle=1
  oplot,!X.crange,[stats1[0],stats1[0]]-stats1[1],color=fsc_color('black'),thick=1,linestyle=1
  oplot,[roi_time[0],roi_time[0]],!y.crange,color=fsc_color('red')
  oplot,[roi_time[1],roi_time[1]],!y.crange,color=fsc_color('red')
  ;TC2
  plot,timesec/3600.,sens2,ytitle='TC2',yrange=[m2-yspan,m2+yspan],xmargin=[8,8],$
    xrange=timeIntervalH,color=fsc_color('black'),charsize=2,ymargin=[0,0],xtickformat='(A1)'
  oplot,timesec/3600.,sens2sm,color=fsc_color('blue'),thick=2
  oplot,!X.crange,[stats2[0],stats2[0]],color=fsc_color('black'),thick=3,linestyle=3
  oplot,!X.crange,[stats2[0],stats2[0]]+stats2[1],color=fsc_color('black'),thick=3,linestyle=1
  oplot,!X.crange,[stats2[0],stats2[0]]-stats2[1],color=fsc_color('black'),thick=3,linestyle=1
  oplot,[roi_time[0],roi_time[0]],!y.crange,color=fsc_color('red')
  oplot,[roi_time[1],roi_time[1]],!y.crange,color=fsc_color('red')
  ;Ambient

;  plot,timesec/3600.,tAmbient,xtit='Time (h)',yrange=[m3-yspan,m3+yspan],ystyle=8,xmargin=[8,8],$
;    xrange=timeIntervalH,color=fsc_color('black'),charsize=2,ytitle='Ambient',ymargin=[!y.margin[0],0]
  plot,timesec/3600.,tAmbient,color=fsc_color('black'),ystyle=8,xmargin=[8,8],/nodata,yrange=[m3-yspan,m3+yspan],$
    xrange=timeIntervalH,charsize=2,ymargin=[!y.margin[0],0],xtit='Time (h)',ytitle='Ambient'
  oplot,timesec/3600.,tAmbient,color=fsc_color('black')
  oplot,[roi_time[0],roi_time[0]],!y.crange,color=fsc_color('red')
  oplot,[roi_time[1],roi_time[1]],!y.crange,color=fsc_color('red')
;  axis,yaxis=1,/save,yrange=,color=0,$
;    ytitle='Profiler',charsize=2
  axis,yaxis=1,/save,yrange=[m4-yspan,m4+yspan],color=fsc_color('blue'),ytitle='Profiler',charsize=2 ;,color=fsc_color('blue')
  ;plot, timeprof,tempprof,xtit='Time (h)',ystyle=8,xmargin=[8,8],/nodata,yrange=[m4-yspan,m4+yspan],$
  ;  xrange=timeIntervalH,color=fsc_color('black'),charsize=2,ytitle='Profiler',ymargin=[!y.margin[0],0]
  oplot, timeprof,tempprof,color=fsc_color('blue')
  ;oplot, timeprof,tempprof,color=fsc_color('blue') 
  ;oplot,timeprof,tempprof, color=fsc_color('red')

  !p.multi=0
if ps ne 0 then ps_end


end

