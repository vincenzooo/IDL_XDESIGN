pro analyze_single_measure,meas_file1,outfolder=outfolder,$
  outname=outname,report=report,ps=ps,npx=npx,npy=npy,$
  xgrid=xgrid,ygrid=ygrid,zraw=z_meas1,zflat=zflatten,sectionlevel=sectionlevel
;npx and npy number of points in the grid (equal to npointsperside in measure - 2,
;to exclude the borders).

if n_elements (sectionlevel) eq 0 then  sectionlevel=1

img_dir=outfolder+path_sep()+outname+'_img'
if file_test(img_dir,/directory) eq 0 then file_mkdir,img_dir ;automatically create also outfolder

createReport=(obj_valid(report) eq 0)
if createReport then report=obj_new('lr',outfolder+path_sep()+outname+'_report.tex',title=title,$
                author=author,level=sectionlevel)

;General description
if (sectionlevel eq report->get_lowestLevel()) then begin
  report->section,sectionlevel,'Datafile '+outname,nonum=nonum
endif else report->section,sectionlevel,outname,nonum=nonum,newpage=newpage
report->append,'\emph{Results folder: '+fn(outfolder,/u)+'}\\'
report->append,'\emph{Outname: '+outname+'}',/nl
report->append,'data file: '+fn(meas_file1,/u),/nl

;read data and resampling
z_meas1=read_measure(meas_file1,$
  npx=npx,npy=npy,xgrid=xgrid1,ygrid=ygrid1,rawdata=raw1)
  xgrid=xgrid1
  ygrid=ygrid1
xraw_1=raw1[*,0]
yraw_1=raw1[*,1]
zraw_1=raw1[*,2]
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'resampling.eps', /COLOR,/encapsulated  
endif else window,0,title='0: measured positions '+meas_file1
rr=squarerange([xraw_1,xgrid],[yraw_1,ygrid],expansion=1.05)
plot,[0],[0],/nodata,xrange=rr[0:1],yrange=rr[2:3],/isotropic
oplot,xraw_1,yraw_1,psym=1,color=0,symsize=0.5
gridMat=grid(xgrid,ygrid)
oplot,gridMat[*,0],gridMat[*,1],psym=4,color=100,symsize=0.5
legend,['raw data','resampled'],position=13,color=[0,100],psym=[1,4]
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif
report->section,sectionlevel+1,'Resampling of data',nonum=nonum
report->figure,fn(img_dir+path_sep()+'resampling',/u),$
  caption=outname+': position in X and Y of the raw and resampled data.',$
  parameters='width=0.75\textwidth'
report->append,'n points: '+string(n_elements(xraw_1)),/nl
report->append,'X range: '+strjoin(range(xraw_1),'--'),/nl
report->append,'Y range: '+strjoin(range(yraw_1),'--'),/nl

;plot of raw data
loadct,13
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'raw_data.eps', /COLOR,/encapsulated  
endif else window,1,title='2: raw data 1'+meas_file1
TVimage, z_meas1, Margin=0.2, /Save, /White, /scale,$
  /Axes,/keep_aspect_ratio,xrange=range(xgrid),yrange=range(ygrid),$
  AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'raw data'}
FSC_colorbar,/vertical,range=range(z_meas1)*1000.,title='Z (um)'
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif
report->figure,fn(img_dir+path_sep()+'raw_data',/u),$
  caption=outname+': raw data.',$
  parameters='width=0.75\textwidth'
  
stats_raw=[total(zraw_1)/n_elements(zraw_1),$                ;0:avg
     max(zraw_1)-min(zraw_1),$      ;1:PV
     min(zraw_1),$                ;2:min
     max(zraw_1),$                ;3:max
     stddev(reform(zraw_1,n_elements(zraw_1)))]                 ;4:standard deviation (rms)
report->append,['Raw data stats:',['avg=','PV=','min=','max=','rms=']+string(stats_raw)],/nl
stats_res=[total(z_meas1)/n_elements(z_meas1),$                ;0:avg
     max(z_meas1)-min(z_meas1),$      ;1:PV
     min(z_meas1),$                ;2:min
     max(z_meas1),$                ;3:max
     stddev(reform(z_meas1,npx*npy)) ]                 ;4:standard deviation (rms)
report->append,['Raw data resampled stats:',['avg=','PV=','min=','max=','rms=']+string(stats_res)],/nl

;plane subtraction
if n_elements(plane) ne 0 then p0=plane else p0=plane_fit(xraw_1,yraw_1,zraw_1)
report->append,['plane 1 parameters:',['a=','b=','c=']+string(p0)],/nl
report->append,['tilt (arcsec):',['X=','Y=']+string(atan(p0[0:1])*206265.)],/nl
report->append,['Z offset (mm):'+string(p0[2])],/nl
residuals1=zraw_1-(p0[0]*xraw_1+p0[1]*yraw_1+p0[2])
z_flatten=resample_surface(xraw_1,yraw_1,residuals1,xgrid=xgrid,ygrid=ygrid)
loadct,13
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'flatten_data.eps', /COLOR,/encapsulated  
endif else window,2,title='1: flattened data'+meas_file1
TVimage, z_flatten, Margin=0.2, /Save, /White, /scale,$
    /Axes,/keep_aspect_ratio,xrange=range(xgrid),yrange=range(ygrid),$
    AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'flattened data'}
FSC_colorbar,/vertical,range=range(residuals1)*1000.,title='Z (um)'
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif
report->figure,fn(img_dir+path_sep()+'flatten_data',/u),$
  caption=outname+': Flattened data.',$
  parameters='width=0.75\textwidth'
stats_flat=[total(z_flatten)/n_elements(z_flatten),$                ;0:avg
     max(z_flatten)-min(z_flatten),$      ;1:PV
     min(z_flatten),$                ;2:min
     max(z_flatten),$                ;3:max
     stddev(reform(z_flatten,n_elements(z_flatten))) ]                 ;4:standard deviation (rms)
report->append,['Flattened data stats:',['avg=','PV=','min=','max=','rms=']+string(stats_flat)],/nl

  if createReport then begin
    report->compile,0,/pdf,/clean
    obj_destroy,report
  endif
end

ps=1
set_plot_default
setStandardDisplay
;fea_folder='/home/cotroneo/Desktop/mirrorDeformations/FEA'
;meas_folder='/home/cotroneo/Desktop/mirrorDeformations/measures'
folder='E:\work\work_ratf'
;folder='/home/cotroneo/Desktop/mirrorDeformations'
fea_folder=folder+path_sep()+'FEA'
;meas_file1=folder+path_sep()+'measures\Moore-Scan01.dat'
;meas_file2=folder+path_sep()+'measures\Moore-Scan-gg-01.dat'
meas_filelist=folder+path_sep()+['measures\Moore-Scan01.dat',$
    'measures\Moore-Scan-gg-01.dat','measures\Moore-Scan-VG-01.dat',$
    'measures\Moore-Scan-VG-02.dat','measures\Moore-Scan-VG-03.dat',$
    'measures\Moore-Scan-VG-04b.dat']
;meas_filelist=folder+path_sep()+['measures/Moore-Scan01.dat',$
;    'measures/Moore-Scan-gg-01.dat','measures/Moore-Scan-VG-01.dat',$
;    'measures/Moore-Scan-VG-02.dat','measures/Moore-Scan-VG-03.dat',$
;    'measures/Moore-Scan-VG-04b.dat']
toavg=[3,4]
npx=50 ;60
npy=50 ;60
    ;meas_filelist=folder+path_sep()+['measures\Moore-Scan-VG-04.dat']
nodefile=fea_folder+path_sep()+'Fem3_nodes.txt'
datafile=fea_folder+path_sep()+'Fem3_Actuator_13.dat'
outname='test_2'
;outfolder='/home/cotroneo/Desktop/mirrorDeformations'+path_sep()+outname
outfolder=folder+path_sep()+outname
img_dir=outfolder+path_sep()+outname+'_img'

if ps ne 0 then begin
  !P.thick=2
  !X.thick=2
  !y.thick=2
  !P.charthick=2
endif else begin
  !P.thick=1
  !X.thick=1
  !y.thick=1
  !P.charthick=1
endelse

report=obj_new('lr',outfolder+path_sep()+outname+'_report.tex',$
                title='CMM scans of the Radial Adjuster Test Fixure #1',$
                author='Vincenzo Cotroneo',level=sectionlevel,/toc,/maketitle)        
nfiles=n_elements(meas_filelist)

report->section,1,'Data from single measures'
for i=0,nfiles-1 do begin
  meas_file=fn(meas_filelist[i])
  analyze_single_measure,meas_file,outname=file_basename(meas_file),$
  outfolder=outfolder,report=report,sectionlevel=2,$
  xgrid=x1,ygrid=y1,ps=ps,npx=npx,npy=npy
  if i eq 0 then begin
    x_m=[x1]
    y_m=[y1]
    xrange=range(x1)
    yrange=range(y1)
  endif else begin
    x_m=[[x_m],[x1]]
    y_m=[[y_m],[y1]]
    xrange=[[xrange],[range(x1)]]
    yrange=[[yrange],[range(y1)]]
  endelse
endfor

;;Data comparison and averaging
;;resample to the same coordinates
;npx=50
;npy=50
xrange=[max(xrange[0,toavg]),min(xrange[1,toavg])]
yrange=[max(yrange[0,toavg]),min(yrange[1,toavg])]
xvec=vector(xrange[0],xrange[1],npx+2)
xvec=xvec[1:n_elements(xvec)-2]
yvec=vector(yrange[0],yrange[1],npy+2)
yvec=yvec[1:n_elements(yvec)-2]
xygrid=grid(xvec,yvec)
for i=0,n_elements(toavg)-1 do begin
  meas_file1=fn(meas_filelist[toavg[i]])
  print,meas_file1
  z_meas1=read_measure(meas_file1,$
    xgrid=xvec,ygrid=yvec,rawdata=raw1)
  p0=plane_fit(xvec,yvec,z_meas1)
  tmp=reform(z_meas1,n_elements(z_meas1))-$
      (p0[0]*xygrid[*,0]+p0[1]*xygrid[*,1]+p0[2])
  z_flat=reform(tmp,npx,npy)
  if i eq 0 then begin
    p0_m=[p0]
    x_m=[x1]
    y_m=[y1]
    z_raw_m=z_meas1
    z_flat_m=z_flat
  endif else begin
    p0_m=[[p0_m],[p0]]
    x_m=[[x_m],[x1]]
    y_m=[[y_m],[y1]]
    z_raw_m=[[[z_raw_m]],[[z_meas1]]]
    z_flat_m=[[[z_flat_m]],[[z_flat]]]
  endelse
endfor

zavg=total(z_raw_m,3)/n_elements(toavg)

if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'avg_data.eps', /COLOR,/encapsulated  
endif else window,2,title='average data'+meas_file1
TVimage, zavg, Margin=0.2, /Save, /White, /scale,$
    /Axes,/keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'average data'}
FSC_colorbar,/vertical,range=range(zavg)*1000.,title='Z (um)'
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

report->section,1,'Data analysis and differences for reference (0 V) scans'
report->append,'Here the three repeated scans with all'+$
  ' the actuators grounded are compared with the average.'+$
  ' considering the two cases of raw data resample on a grid and '+$
  ' data independently leveled.'
report->append,'List of files:'
report->list,file_basename(meas_filelist[toavg]),/nonum
report->figure,fn(img_dir+path_sep()+'avg_data',/u),$
  caption=outname+': average data.',$
  parameters='width=0.75\textwidth'

report->section,2,'Averaging'
;pAvg=plane_fit(xygrid[*,0],xygrid[*,1],reform(zavg,n_elements(zavg)))
pAvg=plane_fit(xvec,yvec,zavg)
report->append,['average plane parameters:',['a=','b=','c=']+string(pavg)],/nl
report->append,['tilt (arcsec):',['X=','Y=']+string(atan(pavg[0:1])*206265.)],/nl
report->append,['Z offset (mm):'+string(pavg[2])],/nl
pTable=makelatextable(transpose([[p0_m],[pavg]]),$
colheader=latextableline(['File','A','B','C']),$
  rowheader=[file_basename(meas_filelist[toavg]),'fit average'])
report->table,pTable,'p{3cm}'+strjoin(replicate('p{3cm}',3)),$
  caption='Best fit plane for results and avg'
zavg_flat=reform(zavg,n_elements(zavg),1)-(pavg[0]*xygrid[*,0]+pavg[1]*xygrid[*,1]+pavg[2])
z_flatten=reform(zavg_flat,npx,npy)

loadct,13
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'avg_flat.eps', /COLOR,/encapsulated  
endif else window,2,title='average data'+meas_file1
TVimage, z_flatten, Margin=0.2, /Save, /White, /scale,$
    /Axes,/keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'average data'}
FSC_colorbar,/vertical,range=range(z_flatten)*1000.,title='Z (um)'
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif
report->figure,fn(img_dir+path_sep()+'avg_flat',/u),$
  caption=outname+': average flattened data.',$
  parameters='width=0.75\textwidth'
 
report->section,2,'Deviations from average'
report->section,3,'Deviations for unleveled profiles'
report->figure,fn(img_dir+path_sep()+'avg_diff',/u),$
  caption=outname+': Differences between raw data (resampled on a grid, but'+$
  ' not leveled) and the average (shown in top left) from the 3 scans.',$
  parameters='width=\textwidth'
report->figure,fn(img_dir+path_sep()+'diffhist_raw',/u),$
  caption=outname+': Distribution of deviations from average for'+$
  'three scans unleveled.',$
  parameters='width=\textwidth'
report->section,3,'Deviations for independently leveled profiles'
report->figure,fn(img_dir+path_sep()+'avg_diff_flat',/u),$
  caption=outname+': Differences between the average (shown in top left)'+$
  ' and the three scans independently leveled.',$
  parameters='width=\textwidth'
report->figure,fn(img_dir+path_sep()+'diffflathist_raw',/u),$
  caption=outname+': Distribution of deviations from average for'+$
  'three scans independently leveled.',$
  parameters='width=\textwidth'  
  
z_diff_m=fltarr(npx,npy,n_elements(toavg))
for i=0,n_elements(toavg)-1 do begin
  z_diff_m[*,*,i]=z_raw_m[*,*,i]-zavg
endfor

if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'avg_diff.eps', /COLOR,/encapsulated  
endif else window,0,xsize=850,ysize=650
!P.Multi=[0,2,2]
 pp = [0.12, 0.15, 0.9, 0.9]
 p=pp
 LoadCT, 13
 TVImage, zavg, Position=p,/scale, /White,/Axes,$
 /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
    YTITLE:'Y (mm)',TITLE:'average data'},margin=0
 FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
    range=range(zavg)*1000,format='(g0.2)',/vertical
 p = pp ;[0.07, 0.1, 0.82, 0.85]
 TVImage, z_diff_m[*,*,0], Position=p,/scale, /White,/Axes,$
 /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
    YTITLE:'Y (mm)',TITLE:'diff 1'},margin=0
 FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
    range=range(z_diff_m[*,*,0])*1000,format='(g0.2)',/vertical
 p = pp ;[0.07, 0.1, 0.82, 0.85]
 TVImage, z_diff_m[*,*,1], Position=p,/scale, /White,/Axes,$
 /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
    YTITLE:'Y (mm)',TITLE:'diff 2'},margin=0
 FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
    range=range(z_diff_m[*,*,1])*1000,format='(g0.2)',/vertical
 p = pp ;[0.07, 0.1, 0.82, 0.85]
; TVImage, z_diff_m[*,*,2], Position=p,/scale, /White,/Axes,$
; /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
;    AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
;    YTITLE:'Y (mm)',TITLE:'diff 3'},margin=0
; FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
;    range=range(z_diff_m[*,*,2])*1000,format='(g0.2)',/vertical
 !P.Multi =0
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;stats on unleveled files
nbins=100
 ;;stats calculation
diffstats_m=histostats(z_diff_m*1000,$
    nbins=nbins,/noplot,locations=difflocations,hist=diffhist,$
    /normalize,min=min(z_diff_m*1000,/nan),max=max(z_diff_m*1000,/nan))
difflocations_m=difflocations
diffhist_m=diffhist
for i=0,n_elements(toavg)-1 do begin
  diffstats_m=[[diffstats_m],[histostats(z_diff_m[*,*,i]*1000,$
      nbins=nbins,/noplot,locations=difflocations,hist=diffhist,$
      /normalize,min=min(z_diff_m*1000,/nan),max=max(z_diff_m*1000,/nan))]]
  difflocations_m=concatenate(difflocations_m,difflocations,2)
  diffhist_m=concatenate(diffhist_m,diffhist,2)
endfor
 ;;histogram plot. The plot needs to be done in a different step to account for the vertical range.
setstandardDisplay
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'diffhist_raw.eps', /COLOR,/encapsulated  
endif else window,4
diffcolors=[fsc_color('black'),plotcolors(n_elements(toavg))]
expansionFactor=1.1
plot,[0],[0],title=outname+': distribution of differences in raw profile',$
    background=255,color=0,xtitle='Deviation from avg (um)',ytitle='Fraction of total number',$
    xrange=range(z_diff_m)*1000,yrange=[0,max(diffhist_m)*expansionFactor]
oplot,difflocations_m[*,0],diffhist_m[*,0],color=diffcolors[0],psym=10
for i=1,n_elements(toavg) do begin
  oplot,difflocations_m[*,i],diffhist_m[*,i],color=diffcolors[i],psym=10
endfor
legend,['Total',file_basename(meas_filelist[toavg])],color=diffcolors,position=10
dummy=histostats(z_diff_m*1000,nbins=nbins,/normalize,/legend,position=7,$
  outvars=[0,1,2,3,4,5])
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;;flattened differences
z_diffflat_m=fltarr(npx,npy,n_elements(toavg))
for i=0,n_elements(toavg)-1 do begin
  z_diffflat_m[*,*,i]=z_flat_m[*,*,i]-z_flatten
endfor

if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'avg_diff_flat.eps', /COLOR,/encapsulated  
endif else window,0,xsize=850,ysize=650
!P.Multi=[0,2,2]
 pp = [0.12, 0.15, 0.9, 0.9]
 p=pp
 LoadCT, 13
 TVImage, z_flatten, Position=p,/scale, /White,/Axes,$
 /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
    YTITLE:'Y (mm)',TITLE:'average data'},margin=0
 FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
    range=range(z_flatten)*1000,format='(g0.2)',/vertical
 p = pp ;[0.07, 0.1, 0.82, 0.85]
 TVImage, z_diffflat_m[*,*,0], Position=p,/scale, /White,/Axes,$
 /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
    YTITLE:'Y (mm)',TITLE:'diff 1'},margin=0
 FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
    range=range(z_diffflat_m[*,*,0])*1000,format='(g0.2)',/vertical
 p = pp ;[0.07, 0.1, 0.82, 0.85]
 TVImage, z_diffflat_m[*,*,1], Position=p,/scale, /White,/Axes,$
 /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
    YTITLE:'Y (mm)',TITLE:'diff 2'},margin=0
 FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
    range=range(z_diffflat_m[*,*,1])*1000,format='(g0.2)',/vertical
 p = pp ;[0.07, 0.1, 0.82, 0.85]
; TVImage, z_diffflat_m[*,*,2], Position=p,/scale, /White,/Axes,$
; /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
;    AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
;    YTITLE:'Y (mm)',TITLE:'diff 3'},margin=0
; FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
;    range=range(z_diffflat_m[*,*,2])*1000,format='(g0.2)',/vertical
 !P.Multi =0
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;stats
nbins=100
 ;;stats calculation
diffflatstats_m=histostats(z_diffflat_m*1000,$
    nbins=nbins,/noplot,locations=diffflatlocations,hist=diffflathist,$
    /normalize,min=min(z_diffflat_m*1000,/nan),max=max(z_diffflat_m*1000,/nan))
diffflatlocations_m=diffflatlocations
diffflathist_m=diffflathist
for i=0,n_elements(toavg)-1 do begin
  diffflatstats_m=[[diffflatstats_m],[histostats(z_diffflat_m[*,*,i]*1000,$
      nbins=nbins,/noplot,locations=diffflatlocations,hist=diffflathist,$
      /normalize,min=min(z_diffflat_m*1000,/nan),max=max(z_diffflat_m*1000,/nan))]]
  diffflatlocations_m=concatenate(diffflatlocations_m,diffflatlocations,2)
  diffflathist_m=concatenate(diffflathist_m,diffflathist,2)
endfor
 ;;histogram plot. The plot needs to be done in a different step to account for the vertical range.
setstandardDisplay
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'diffflathist_raw.eps', /COLOR,/encapsulated  
endif else window,4
diffcolors=[fsc_color('black'),plotcolors(n_elements(toavg))]
expansionFactor=1.1
plot,[0],[0],title=outname+': distribution of differences in leveled profile',$
    background=255,color=0,xtitle='Deviation from avg (um)',ytitle='Fraction of total number',$
    xrange=range(z_diffflat_m)*1000,yrange=[0,max(diffflathist_m)*expansionFactor]
oplot,diffflatlocations_m[*,0],diffflathist_m[*,0],color=diffcolors[0],psym=10
for i=1,n_elements(toavg) do begin
  oplot,diffflatlocations_m[*,i],diffflathist_m[*,i],color=diffcolors[i],psym=10
endfor
legend,['Total',file_basename(meas_filelist[toavg])],color=diffcolors,position=10
dummy=histostats(z_diffflat_m*1000,nbins=nbins,/normalize,/legend,position=7,$
  outvars=[0,1,2,3,4,5])
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

  !P.thick=1
  !X.thick=1
  !y.thick=1
  !P.charthick=1
report->compile,0,/clean
obj_destroy,report
end         
