

function fittoscale,ab
common tofit,rmatrix,vmatrix

  a=ab[0]
  b=ab[1]
  fun=total((rmatrix+b-a*vmatrix)^2)
  ;print,fun
  return,fun

end

function rescaleFit,a
common tofit,rmatrix,vmatrix

  aa=a[0]
  fun=total((rmatrix-aa*vmatrix)^2)
  ;print,fun
  return,fun

end

common tofit,rmatrix,vmatrix

if n_elements(ps) eq 0 then ps=1
baselevel=0
set_plot_default
setStandardDisplay
folder='/home/cotroneo/Desktop/work_ratf'
meas_folder=folder+path_sep()+'measures'
fea_folder=fn(folder+path_sep()+'FEA')
meas_filelist=fn(meas_folder+path_sep()+['Moore-Scan01.dat',$
    'Moore-Scan-gg-01.dat','Moore-Scan-VG-01.dat',$
    'Moore-Scan-VG-02.dat','Moore-Scan-VG-03.dat',$
    'Moore-Scan-VG-04b.dat','Moore-Scan-VG-50v-01b.dat'])
toavg=[2,3,4]
nodefile=fn(fea_folder+path_sep()+'Fem3_nodes_mm.txt')
datafile=fn(fea_folder+path_sep()+'Fem3_Actuator_13.dat')
outname='test_1'
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
                title='Radial Adjuster Test Fixure on CMM #1',$
                author='Vincenzo Cotroneo',level=sectionlevel,/toc,/maketitle,/nochapter)        
nfiles=n_elements(meas_filelist)

report->section,baselevel,'Data from single measures'
report->append,"\label{sec:details}"
for i=0,nfiles-1 do begin
  meas_file=fn(meas_filelist[i])
  analyze_single_measure,meas_file,outname=file_basename(meas_file),$
  outfolder=outfolder,report=report,sectionlevel=baselevel+1,$
  xgrid=x1,ygrid=y1,ps=ps,npx=50,npy=50
  if i eq 0 then begin
    x_m=[x1]
    y_m=[y1]
    xrange=range(x1)
    yrange=range(y1)
    ;z_raw_m=z_1
  endif else begin
    x_m=[[x_m],[x1]]
    y_m=[[y_m],[y1]]
    xrange=[[xrange],[range(x1)]]
    yrange=[[yrange],[range(y1)]]
;    xrange=[xrange[0]>min(x1),xrange[1]<max(x1)]
;    yrange=[yrange[0]>min(y1),yrange[1]<max(y1)]
    ;z_raw_m=[[[z_raw_m]],[[z_1]]]
  endelse
endfor

;;Data comparison and averaging
;resample to the same coordinates
npx=50
npy=50
statsmask=[0,1,2,3,4,5]
statsheader=histostats(/header)
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

report->section,baselevel,'Data analysis and differences for reference (0 V) scans'
report->append,"\label{sec:reference}"
report->append,'Here the three repeated scans with all'+$
  ' the actuators grounded are compared with the average.'+$
  ' considering the two cases of raw data resample on a grid and '+$
  ' data independently leveled.'
report->append,'List of files:'
report->list,file_basename(meas_filelist[toavg]),/nonum
report->figure,fn(img_dir+path_sep()+'avg_data',/u),$
  caption=outname+': average data.',$
  parameters='width=0.75\textwidth'

report->section,baselevel+1,'Averaging'
;pAvg=plane_fit(xygrid[*,0],xygrid[*,1],reform(zavg,n_elements(zavg)))
pAvg=plane_fit(xvec,yvec,zavg)
report->append,['average plane parameters:',['a=','b=','c=']+string(pavg)],/nl
report->append,['tilt (arcsec):',['X=','Y=']+string(atan(pavg[0:1])*206265.)],/nl
report->append,['Z offset (mm):'+string(pavg[2])],/nl
pTable=makelatextable(transpose([[p0_m],[pavg]]),$
colheader=latextableline(['File','A','B','C']),$
  rowheader=[file_basename(meas_filelist[toavg]),'fit average'])
report->table,pTable,'p{5cm}'+strjoin(replicate('p{3cm}',3)),$
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
endif else maketif,img_dir+path_sep()+'avg_flat'
report->figure,fn(img_dir+path_sep()+'avg_flat',/u),$
  caption=outname+': average flattened data.',$
  parameters='width=0.75\textwidth'
 
report->section,baselevel+1,'Deviations from average'
report->section,baselevel+2,'Deviations for unleveled profiles'
report->figure,fn(img_dir+path_sep()+'avg_diff',/u),$
  caption=outname+': Differences between raw data (resampled on a grid, but'+$
  ' not leveled) and the average (shown in top left) from the 3 scans.',$
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
 TVImage, z_diff_m[*,*,2], Position=p,/scale, /White,/Axes,$
 /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
    YTITLE:'Y (mm)',TITLE:'diff 3'},margin=0
 FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
    range=range(z_diff_m[*,*,2])*1000,format='(g0.2)',/vertical
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
  outvars=statsmask)
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

report->figure,fn(img_dir+path_sep()+'diffhist_raw',/u),$
  caption=outname+': Distribution of deviations from average for'+$
  ' three scans unleveled.',$
  parameters='width=\textwidth'  
formatstring='(a,'+strjoin(replicate('f8.4',n_elements(toavg)),',')+')'
vals=diffstats_m[statsmask,1:n_elements(toavg)]
statstable=makelatextable(string(vals),rowheader=statsheader[statsmask],$
   colheader=latextableline(['','\emph{'+file_basename(meas_filelist[toAvg])+'}']),$
   format=formatstring)
report->table,statstable,'p{3cm}'+strjoin(replicate('p{2cm}',nfiles)),$
    caption='Statistics for unleveled data, values in !$\mu$!m.'

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
 TVImage, z_diffflat_m[*,*,2], Position=p,/scale, /White,/Axes,$
 /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
    YTITLE:'Y (mm)',TITLE:'diff 3'},margin=0
 FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
    range=range(z_diffflat_m[*,*,2])*1000,format='(g0.2)',/vertical
 !P.Multi =0
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif else maketif,img_dir+path_sep()+'avg_diffflat'

;stats
 ;;stats calculation
diffflatstats_m=histostats(reform(z_diffflat_m*1000,n_elements(z_diffflat_m)),$
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
  outvars=statsmask,color=fsc_color('black'))
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif else maketif,img_dir+path_sep()+'avg_diffflat_hist'

report->section,baselevel+2,'Deviations for independently leveled profiles'
report->figure,fn(img_dir+path_sep()+'avg_diff_flat',/u),$
  caption=outname+': Differences between the average (shown in top left)'+$
  ' and the three scans independently leveled.',$
  parameters='width=\textwidth'
report->figure,fn(img_dir+path_sep()+'diffflathist_raw',/u),$
  caption=outname+': Distribution of deviations from average for'+$
  ' three scans independently leveled.',$
  parameters='width=\textwidth'  
formatstring='(a,'+strjoin(replicate('f8.4',n_elements(toavg)+1),',')+')'
vals=diffflatstats_m[statsmask,*]
statstable=makelatextable(string(vals),rowheader=statsheader[statsmask],$
   colheader=latextableline(['','\emph{'+['Total',file_basename(meas_filelist[toAvg])]+'}']),$
   format=formatstring)
report->table,statstable,'p{3cm}'+strjoin(replicate('p{2cm}',n_elements(toavg)+1)),$
    caption='Statistics after individual leveling, values in !$\mu$!m.'

;influence function
tmp=readfea(nodefile,datafile)
xoffset=(min(xvec)+max(xvec))/2-(min(tmp[*,0])+max(tmp[*,0]))/2
yoffset=(min(yvec)+max(yvec))/2-(min(tmp[*,1])+max(tmp[*,1]))/2
feasurf=double(resample_surface(tmp[*,0]+xoffset,$
  tmp[*,1]+yoffset,tmp[*,2],xgrid=xvec,ygrid=yvec))
loadct,13
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'FEAif.eps', /COLOR,/encapsulated  
endif else window,2,title='Influence function'+nodefile
TVimage, feasurf, Margin=0.2, /Save, /White, /scale,$
    /Axes,/keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
    AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Influence function'}
FSC_colorbar,/vertical,range=range(feasurf)*1000.,title='Z (um)'
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif
report->figure,fn(img_dir+path_sep()+'FEAif',/u),$
  caption=outname+': Influence function from FEA for 10 !$\mu$!m'+$
    ' displacement on central actuator.'
  parameters='width=0.75\textwidth'

newdatafile=meas_folder+path_sep()+'Moore-Scan-VG-50v-01b.dat'
if n_elements(newdatafile) ne 0 then begin
    report->section,baselevel,'Comparison with FEA simulation'
    report->section,baselevel+1,'Data'
    znew=read_measure(newdatafile,$
        npx=npx,npy=npy,rawdata=raw1)
    xraw_1=raw1[*,0]
    yraw_1=raw1[*,1] 
    xrange=range(xraw_1)
    yrange=range(yraw_1)
    xvec=vector(xrange[0],xrange[1],npx+2)
    xvec=xvec[1:n_elements(xvec)-2]
    yvec=vector(yrange[0],yrange[1],npy+2)
    yvec=yvec[1:n_elements(yvec)-2]
    xygrid=grid(xvec,yvec)
    pnew=plane_fit(xvec,yvec,znew)
    tmp=reform(znew,n_elements(znew))-$
        (pnew[0]*xygrid[*,0]+pnew[1]*xygrid[*,1]+pnew[2])
    znew_flat=reform(tmp,npx,npy)

    loadct,13
    if ps ne 0 then begin
      file_mkdir,img_dir
      SET_PLOT, 'PS'
      DEVICE, filename=img_dir+path_sep()+'meas50.eps', /COLOR,/encapsulated  
    endif else window,2,title='measure 50 V: '+newdatafile
    TVimage, znew*1000, Margin=0.2, /Save, /White, /scale,$
        /Axes,/keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
        AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Raw data for 50 V'}
    FSC_colorbar,/vertical,range=range(znew)*1000.,title='Z (um)'
    if ps ne 0 then begin
      DEVICE, /CLOSE 
      SET_PLOT_default 
    endif else maketif,img_dir+path_sep()+'meas50'
    report->figure,fn(img_dir+path_sep()+'meas50',/u),$
      caption=outname+'(measurement at 50 V): raw data.',$
      parameters='width=0.75\textwidth'

    loadct,13
    if ps ne 0 then begin
      file_mkdir,img_dir
      SET_PLOT, 'PS'
      DEVICE, filename=img_dir+path_sep()+'meas50level.eps', /COLOR,/encapsulated  
    endif else window,2,title='measure 50 V level: '+newdatafile
    TVimage, znew_flat*1000, Margin=0.2, /Save, /White, /scale,$
        /Axes,/keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
        AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Leveled data for 50 V'}
    FSC_colorbar,/vertical,range=range(znew_flat)*1000.,title='Z (um)'
    if ps ne 0 then begin
      DEVICE, /CLOSE 
      SET_PLOT_default 
    endif else maketif,img_dir+path_sep()+'meas50level'
    report->figure,fn(img_dir+path_sep()+'meas50level',/u),$
      caption=outname+'(measurement at 50 V): leveled data.',$
      parameters='width=0.75\textwidth'

    ;differences with reference (absolute)
    newdiff=znew-zavg
    loadct,13
    if ps ne 0 then begin
      file_mkdir,img_dir
      SET_PLOT, 'PS'
      DEVICE, filename=img_dir+path_sep()+'newdiff.eps', /COLOR,/encapsulated  
    endif else window,2,title='displacement: '+newdatafile
    TVimage, newdiff*1000, Margin=0.2, /Save, /White, /scale,$
        /Axes,/keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
        AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Displacement for 50 V'}
    FSC_colorbar,/vertical,range=range(newdiff)*1000.,title='Z (um)'
    if ps ne 0 then begin
      DEVICE, /CLOSE 
      SET_PLOT_default 
    endif else maketif,img_dir+path_sep()+'newdiff'
    report->figure,fn(img_dir+path_sep()+'newdiff',/u),$
      caption=outname+': displacement wrt raw data.',$
      parameters='width=0.75\textwidth'

    ;differences with reference (average)
    newdiff_flat=znew_flat-zavg_flat
    loadct,13
    if ps ne 0 then begin
      file_mkdir,img_dir
      SET_PLOT, 'PS'
      DEVICE, filename=img_dir+path_sep()+'newdiff_level.eps', /COLOR,/encapsulated  
    endif else window,2,title='displacement: '+newdatafile
    TVimage, newdiff_flat*1000, Margin=0.2, /Save, /White, /scale,$
        /Axes,/keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
        AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Displacement for 50 V'}
    FSC_colorbar,/vertical,range=range(newdiff_flat)*1000.,title='Z (um)'
    if ps ne 0 then begin
      DEVICE, /CLOSE 
      SET_PLOT_default
    endif else maketif,img_dir+path_sep()+'newdiff_level'
    report->figure,fn(img_dir+path_sep()+'newdiff_level',/u),$
      caption=outname+': displacement after individual leveling.',$
      parameters='width=0.75\textwidth'
    
    report->section,baselevel+1,'Comparison with theoretical IF and fit'
    ;residuals for influence function for unfitted leveled data
    resMatrix=(newdiff_flat)-(feasurf)
    rmatrix=newdiff_flat
    vmatrix=feasurf
;
    bestfit=amoeba(10.^(-8),function_name='fittoscale',$
      p0=[0.,1.],scale=1.,$
        function_value=lastsimplex,nmax=20000)
    ;residuals for influence function after fit
    resMatrixFit=(newdiff_flat+bestfit[1])-(feasurf*bestfit[0])

    oneParFit=amoeba(10.^(-8),function_name='rescaleFit',$
      p0=[1.],scale=1.,$
        function_value=lastsimplex1,nmax=20000)
    ;residuals for influence function after fit
    resMatrixFit1=(newdiff_flat)-(feasurf*oneParFit[0])
    
    ;common range for colobar   
    barrange=range([newdiff_flat,feasurf,resMatrix,resMatrixFit,$
    resMatrixFit1])
    
    ;statistics
    outvars=[0,1,2,3,4,5]
    diffStats=histostats(newdiff_flat*1000.,nbins=nbins,$
      /noplot,/normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
      outvars=outvars,locations=newdiffLoc,hist=newdiffhist)
    resStats=histostats(resMatrix*1000.,nbins=nbins,$
      /noplot,/normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
      outvars=outvars,locations=resLoc,hist=reshist)
    resStatsFit=histostats(resMatrixFit*1000.,nbins=nbins,$
      /noplot,/normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
      outvars=outvars,hist=reshistFit)
    resStatsFit1=histostats(resMatrixFit1*1000.,nbins=nbins,$
      /noplot,/normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
      outvars=outvars,hist=reshistFit1)
    statsheader=histostats(/header,outvars=outvars)
    
  loadct,13
  if ps ne 0 then begin
    file_mkdir,img_dir
    SET_PLOT, 'PS'
    DEVICE, filename=img_dir+path_sep()+'ratioIF.eps', /COLOR,/encapsulated  
  endif else window,2,title='fit of Influence function: '+newdatafile
  !P.Multi=[0,2,3]
   pp = [0.12, 0.15, 0.9, 0.9]
   p=pp
   LoadCT, 13
   TVImage, newdiff_flat, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'1) diff between leveled data'},margin=0
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=range(newdiff_flat)*1000,format='(g0.2)',/vertical
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, feasurf, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'2) theoretical IF'},margin=0
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=range(feasurf)*1000,format='(g0.2)',/vertical
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrix, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'3) Residuals for unfitted data'},margin=0
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=range(resMatrix)*1000,format='(g0.2)',/vertical
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrixFit, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'4) Residuals for 2 pars fit'},margin=0
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=range(resMatrixFit)*1000,format='(g0.2)',/vertical
    p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrixFit1, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'5) Residuals for 1 par fit'},margin=0
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=range(resMatrixFit1)*1000,format='(g0.2)',/vertical
   FSC_plot,resLoc,reshist,color=fsc_color('red'),xtitle='z (um)',$
      ytitle='Distribution',yrange=range([resHistFit1,resHistFit,resHist]),$
      psym=10
   FSC_plot,resLoc,reshistFit,color=fsc_color('blue'),/overplot,psym=10
   FSC_plot,resLoc,reshistFit1,color=fsc_color('green'),/overplot,psym=10
   legend,['leveled data', '2 pars fit', '1 par fit'],$
    color=[fsc_color('red'),fsc_color('blue'),fsc_color('green')]
   !P.Multi =0
  if ps ne 0 then begin
    DEVICE, /CLOSE 
    SET_PLOT_default
  endif else maketif,img_dir+path_sep()+'ratioIF'
  report->figure,fn(img_dir+path_sep()+'ratioIF',/u),$
    caption=outname+': Comparison between the measured and simulated '+$
      'influence function for different kinds of fit. Linear fit according to '+$
      '!$z_{\mathrm{meas}}='+string(bestfit[0], format='(g0.5)')+'z_{\mathrm{FEA}}'+$
      string(-bestfit[1]*1000,format='(g+0.4)')+'\mu m$!.'+$
      ' and single parameter fit (rescaling) according to !$z_{\mathrm{meas}}='+$
    string(oneparfit,format='(f+0.4)')+'z_{\mathrm{FEA}}$!.',$
      parameters='width=0.9\textwidth'
      
   ;with same scale    
  if ps ne 0 then begin
    file_mkdir,img_dir
    SET_PLOT, 'PS'
    DEVICE, filename=img_dir+path_sep()+'ratioIF_scaled.eps', /COLOR,/encapsulated  
  endif else window,2,title='fit of Influence function: '+newdatafile
  !P.Multi=[0,2,3]    
   pp = [0.12, 0.15, 0.9, 0.9]
   p=pp
   pcolors=[[[50,0,0],[255,0,0]],[[0,50,0],[0,255,0]],$
      [[0,0,50],[0,0,255]],[[50,50,0],[255,255,0]],$
      [[50,0,50],[255,0,255]],[[0,50,50],[0,255,255]],$
      [[50,50,50],[250,250,250]],[[20,20,50],[100,100,250]]]
  ;barrange=[-10./1000,10./1000]
  dummy=colors_band_palette(barrange[0],barrange[1],pcolors,$
        /load,bandvalsize=5./1000)
   TVImage, newdiff_flat, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'1) diff between leveled data'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, feasurf, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'2) theoretical IF'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrix, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'3) Residuals for unfitted data'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrixFit, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'4) Residuals for 2 pars fit'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
    p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrixFit1, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'5) Residuals for 1 par fit'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
   FSC_plot,resLoc,reshist,color=fsc_color('red'),xtitle='z (um)',$
      ytitle='Distribution',yrange=range([resHistFit1,resHistFit,resHist]),$
      psym=10
   FSC_plot,resLoc,reshistFit,color=fsc_color('blue'),/overplot,psym=10
   FSC_plot,resLoc,reshistFit1,color=fsc_color('green'),/overplot,psym=10
   legend,['leveled data', '2 pars fit', '1 par fit'],$
    color=[fsc_color('red'),fsc_color('blue'),fsc_color('green')]
   !P.Multi =0
  if ps ne 0 then begin
    DEVICE, /CLOSE 
    SET_PLOT_default
  endif else maketif,img_dir+path_sep()+'ratioIF_scaled'
  report->figure,fn(img_dir+path_sep()+'ratioIF_scaled',/u),$
    caption=outname+': left - residuals from data (after independent leveling);'+$
    ' right: difference with linear fit, according to '+$
      '!$z_{\mathrm{meas}}='+string(bestfit[0])+'z_{\mathrm{FEA}}'+$
      string(-bestfit[1]*1000,format='(f+0.4)')+'\mu m$!.'+$
      ' and single parameter rescaling according to !$z_{\mathrm{meas}}='+$
    string(oneparfit,format='(f+0.4)')+'z_{\mathrm{FEA}}$!.',$
      parameters='width=0.9\textwidth'

fitStats=makelatextable([[string(diffStats,format='(g0.3)')],$
                         [string(resStats,format='(g0.3)')],$
                         [string(resStatsFit,format='(g0.3)')],$
                         [string(resStatsFit1,format='(g0.3)')]],$
          colheader=latextableline(['','1) Original shape','3) leveled data','4) 2 pars Fit','5) 1 par fit']),$
          rowheader=statsheader)
report -> table,fitStats,strjoin(replicate('p{2cm}',5)),$
          caption='Statistics for residuals for the '+$
          'different types of fit.'
   
   ;create images for presentation
   SET_PLOT, 'PS'
   DEVICE, filename=img_dir+path_sep()+'Data50V.eps', /COLOR,/encapsulated     
   LoadCT, 13
   TVImage, newdiff_flat,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'Data after reference subtraction'},margin=0.2,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar,range=barrange*1000,format='(i)',/vertical,divisions=7
   DEVICE, /CLOSE
   ;maketif,img_dir+path_sep()+'Data50V'
   DEVICE, filename=img_dir+path_sep()+'TeoIF.eps', /COLOR,/encapsulated  
   TVImage, feasurf,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'Theoretical IF'},margin=0.2,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar,range=barrange*1000,format='(i)',/vertical,divisions=7
   ;maketif,img_dir+path_sep()+'TeoIF'
   DEVICE, /CLOSE
   DEVICE, filename=img_dir+path_sep()+'Residuals.eps', /COLOR,/encapsulated 
   TVImage, resMatrix, /scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'Residuals'},margin=0.2,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, range=barrange*1000,format='(i)',/vertical,divisions=7
    ;maketif,img_dir+path_sep()+'Residuals'  
    DEVICE, /CLOSE 
    DEVICE, filename=img_dir+path_sep()+'Stats.eps', /COLOR,/encapsulated 
    outvars=[0,1,2,3,4,5]
    resStats=histostats(resMatrix*1000.,nbins=nbins,$
      /normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
      outvars=outvars,xtitle='z (um)',$
      ytitle='Distribution of residuals')
      ;maketif,img_dir+path_sep()+'Stats'
    DEVICE, /CLOSE 
    SET_PLOT_default

setstandarddisplay
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'xprofile.eps', /COLOR,/encapsulated  
endif else window,2,title='X profile: '+newdatafile
colors=plotcolors(4)
yrange=range([newdiff_flat[24:25,*]*1000,feasurf[24:25,*]*1000,$
    (feasurf[24:25,*]*oneParFit[0])*1000,$
    (feasurf[24:25,*]*bestFit[0]-bestfit[1])*1000])
plot,[0],[0],color=fsc_color('black'),background=fsc_color('white'),$
  /nodata,title='Comparisono of central profiles along X',$
  xtitle='X (mm)',ytitle='Z (um)',yrange=yrange,xrange=range(xvec)
oplot,xvec,total(newdiff_flat[24:25,*],1)*1000/2.,color=colors[0]
oplot,xvec,total(feasurf[24:25,*],1)*1000/2.,color=colors[1]
oplot,xvec,total(feasurf[24:25,*]*oneParFit[0],1)*1000/2.,color=colors[2]
oplot,xvec,total(feasurf[24:25,*]*bestFit[0]-bestfit[1],1)*1000/2.,color=colors[3]
legend,['Measured', 'FEA','Rescaled (1 par)', '2 pars fit'],color=colors[0:3]
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif else maketif,img_dir+path_sep()+'xprofile'
report->figure,fn(img_dir+path_sep()+'xprofile',/u),$
  caption=outname+': profile over the central line along X direction,'+$
  ' compared to measured data, 2 parameters fit, according to '+$
    '!$z_{\mathrm{meas}}='+string(bestfit[0])+'z_{\mathrm{FEA}}'+$
    string(-bestfit[1]*1000,format='(f+0.4)')+'\mu m$!.'+$
    ' and single parameter rescaling according to !$z_{\mathrm{meas}}='+$
    string(oneparfit,format='(f+0.4)')+'z_{\mathrm{FEA}}$!.',$
    parameters='width=0.9\textwidth'


if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'yprofile.eps', /COLOR,/encapsulated  
endif else window,2,title='Y profile: '+newdatafile      
yrange=range([newdiff_flat[*,24:25]*1000,feasurf[*,24:25]*1000,$
    (feasurf[*,24:25]*oneParFit[0])*1000,$
    (feasurf[*,24:25]*bestFit[0]-bestfit[1])*1000])
plot,[0],[0],color=fsc_color('black'),background=fsc_color('white'),$
  /nodata,title='Comparison of central profiles along Y',$
  xtitle='Y (mm)',ytitle='Z (um)',yrange=yrange,xrange=range(yvec)
oplot,yvec,total(newdiff_flat[*,24:25],2)*1000/2.,color=colors[0]
oplot,yvec,total(feasurf[*,24:25],2)*1000/2.,color=colors[1]
oplot,yvec,total(feasurf[*,24:25]*oneParFit[0],2)*1000/2.,color=colors[2]
oplot,yvec,total(feasurf[*,24:25]*bestFit[0]-bestfit[1],2)*1000/2.,color=colors[3]
legend,['Measured', 'FEA','Rescaled (1 par)', '2 pars fit'],color=colors[0:3]
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif else maketif,img_dir+path_sep()+'yprofile'
report->figure,fn(img_dir+path_sep()+'yprofile',/u),$
  caption=outname+': profile over the central line along Y direction,'+$
  ' compared to measured data, 2 parameters fit, according to '+$
    '!$z_{\mathrm{meas}}='+string(bestfit[0])+'z_{\mathrm{FEA}}'+$
    string(-bestfit[1]*1000,format='(f+0.4)')+'\mu m$!.'+$
    ' and single parameter rescaling according to !$z_{\mathrm{meas}}='+$
    string(oneparfit,format='(f+0.4)')+'z_{\mathrm{FEA}}$!.',$
    parameters='width=0.9\textwidth'

endif

;repeat the fit, but after leveling the theoretical IF

if n_elements(newdatafile) ne 0 then begin
    report->section,baselevel,'Comparison with leveled FEA simulation'
    report->section,baselevel+1,'Data'
   
   pIF=plane_fit(xvec,yvec,feasurf)
    tmp=reform(feasurf,n_elements(feasurf))-$
        (pIF[0]*xygrid[*,0]+pIF[1]*xygrid[*,1]+pIF[2])
    feasurf_flat=reform(tmp,npx,npy) 
  
  loadct,13
  if ps ne 0 then begin
    file_mkdir,img_dir
    SET_PLOT, 'PS'
    DEVICE, filename=img_dir+path_sep()+'FEAif_flat.eps', /COLOR,/encapsulated  
  endif else window,2,title='Leveled influence function'+nodefile
  TVimage, feasurf_flat, Margin=0.2, /Save, /White, /scale,$
      /Axes,/keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Leveled influence function'}
  FSC_colorbar,/vertical,range=range(feasurf_flat)*1000.,title='Z (um)'
  if ps ne 0 then begin
    DEVICE, /CLOSE 
    SET_PLOT_default
  endif
  report->figure,fn(img_dir+path_sep()+'FEAif_flat',/u),$
    caption=outname+': Leveled influence function from FEA for 10 !$\mu$!m'+$
      ' displacement on central actuator, plane parameters: A= '+string(pIF[0],format='(g0.3)')+$
      ' B= '+string(pIF[1],format='(g0.3)')+' C= '+string(pIF[2],format='(g0.3)')+'.',$      
    parameters='width=0.75\textwidth'
    
    report->section,baselevel+1,'Comparison with theoretical IF and fit'
    ;residuals for influence function for unfitted leveled data
    resMatrix=(newdiff_flat)-(feasurf_flat)
    rmatrix=newdiff_flat
    vmatrix=feasurf_flat
;
    bestfit=amoeba(10.^(-8),function_name='fittoscale',$
      p0=[0.,1.],scale=1.,$
        function_value=lastsimplex,nmax=20000)
    ;residuals for influence function after fit
    resMatrixFit=(newdiff_flat+bestfit[1])-(feasurf_flat*bestfit[0])

    oneParFit=amoeba(10.^(-8),function_name='rescaleFit',$
      p0=[1.],scale=1.,$
        function_value=lastsimplex1,nmax=20000)
    ;residuals for influence function after fit
    resMatrixFit1=(newdiff_flat)-(feasurf_flat*oneParFit[0])
    
    ;common range for colobar   
    barrange=range([newdiff_flat,feasurf_flat,resMatrix,resMatrixFit,$
    resMatrixFit1])
    
    ;statistics
    outvars=[0,1,2,3,4,5]
    resStats=histostats(resMatrix*1000.,nbins=nbins,$
      /noplot,/normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
      outvars=outvars,locations=resLoc,hist=reshist)
    resStatsFit=histostats(resMatrixFit*1000.,nbins=nbins,$
      /noplot,/normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
      outvars=outvars,hist=reshistFit)
    resStatsFit1=histostats(resMatrixFit1*1000.,nbins=nbins,$
      /noplot,/normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
      outvars=outvars,hist=reshistFit1)
    statsheader=histostats(/header,outvars=outvars)
    
      
   ;with same scale    
  loadct,13
  if ps ne 0 then begin
    file_mkdir,img_dir
    SET_PLOT, 'PS'
    DEVICE, filename=img_dir+path_sep()+'ratioIF_flat.eps', /COLOR,/encapsulated  
  endif else window,2,title='fit of leveled Influence function: '+newdatafile
  !P.Multi=[0,2,3]    
   pp = [0.12, 0.15, 0.9, 0.9]
   p=pp
   LoadCT, 13
   TVImage, newdiff_flat, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'1) diff between leveled data'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, feasurf_flat, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'2) theoretical IF'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrix, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'3) Residuals for unfitted data'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
   p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrixFit, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1, XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'4) Residuals for 2 pars fit'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
    p = pp ;[0.07, 0.1, 0.82, 0.85]
   TVImage, resMatrixFit1, Position=p,/scale, /White,/Axes,$
   /keep_aspect_ratio,xrange=range(xvec),yrange=range(yvec),$
      AXKEYWORDS={CHARSIZE:1., XTITLE:'X (mm)',$
      YTITLE:'Y (mm)',TITLE:'5) Residuals for 1 par fit'},margin=0,$
      minvalue=barrange[0],maxvalue=barrange[1]
   FSC_Colorbar, Position=[p[2]+0.07, p[1], p[2]+0.09, p[3]],$
      range=barrange*1000,format='(i)',/vertical,divisions=7
   FSC_plot,resLoc,reshist,color=fsc_color('red'),xtitle='z (um)',$
      ytitle='Distribution',yrange=range([resHistFit1,resHistFit,resHist]),$
      psym=10
   FSC_plot,resLoc,reshistFit,color=fsc_color('blue'),/overplot,psym=10
   FSC_plot,resLoc,reshistFit1,color=fsc_color('green'),/overplot,psym=10
   legend,['leveled data', '2 pars fit', '1 par fit'],$
    color=[fsc_color('red'),fsc_color('blue'),fsc_color('green')]
   !P.Multi =0
  if ps ne 0 then begin
    DEVICE, /CLOSE 
    SET_PLOT_default
  endif else maketif,img_dir+path_sep()+'ratioIF_flat'
  report->figure,fn(img_dir+path_sep()+'ratioIF_flat',/u),$
    caption=outname+': Comparison between the measured and simulated '+$
      'influence function for different kinds of fit. Linear fit according to '+$
      '!$z_{\mathrm{meas}}='+string(bestfit[0])+'z_{\mathrm{FEA}}'+$
       string(-bestfit[1]*1000,format='(f+0.4)')+'\mu m$!.'+$
      ' and single parameter rescaling according to !$z_{\mathrm{meas}}='+$
    string(oneparfit,format='(f+0.4)')+'z_{\mathrm{FEA}}$!.',$
      parameters='width=0.9\textwidth'

fitStats=makelatextable([[string(resStats,format='(g0.3)')],$
                         [string(resStatsFit,format='(g0.3)')],$
                         [string(resStatsFit1,format='(g0.3)')]],$
          colheader=latextableline(['','leveled data','2 pars Fit','1 par fit']),$
          rowheader=statsheader)
report -> table,fitStats,strjoin(replicate('p{2cm}',4)),$
          caption='Statistics for residuals for the '+$
          'different types of fit.'

setstandarddisplay   
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'xprofile_flat.eps', /COLOR,/encapsulated  
endif else window,2,title='X profile: '+newdatafile
colors=plotcolors(4)
yrange=range([newdiff_flat[24:25,*]*1000,feasurf_flat[24:25,*]*1000,$
    (feasurf_flat[24:25,*]*oneParFit[0])*1000,$
    (feasurf_flat[24:25,*]*bestFit[0]-bestfit[1])*1000])
plot,[0],[0],color=fsc_color('black'),background=fsc_color('white'),$
  /nodata,title='Comparison of central profiles along X',$
  xtitle='X (mm)',ytitle='Z (um)',yrange=yrange,xrange=range(xvec)
oplot,xvec,total(newdiff_flat[24:25,*],1)*1000/2.,color=colors[0]
oplot,xvec,total(feasurf_flat[24:25,*],1)*1000/2.,color=colors[1]
oplot,xvec,total(feasurf_flat[24:25,*]*oneParFit[0],1)*1000/2.,color=colors[2]
oplot,xvec,total(feasurf_flat[24:25,*]*bestFit[0]-bestfit[1],1)*1000/2.,color=colors[3]
legend,['Measured', 'FEA','Rescaled (1 par)', '2 pars fit'],color=colors[0:3]
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif else maketif,img_dir+path_sep()+'xprofile_flat'
report->figure,fn(img_dir+path_sep()+'xprofile_flat',/u),$
  caption=outname+': profile over the central line along X direction,'+$
  ' compared to measured data, 2 parameters fit, for leveled IF, according to '+$
    '!$z_{\mathrm{meas}}='+string(bestfit[0])+'z_{\mathrm{FEA}}'+$
    string(-bestfit[1]*1000,format='(f+0.4)')+'\mu m$!.'+$
    ' and single parameter rescaling according to !$z_{\mathrm{meas}}='+$
    string(oneparfit,format='(f+0.4)')+'z_{\mathrm{FEA}}$!.',$
    parameters='width=0.9\textwidth'


if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'yprofile_flat.eps', /COLOR,/encapsulated  
endif else window,2,title='Y profile: '+newdatafile      
yrange=range([newdiff_flat[*,24:25]*1000,feasurf[*,24:25]*1000,$
    (feasurf_flat[*,24:25]*oneParFit[0])*1000,$
    (feasurf_flat[*,24:25]*bestFit[0]-bestfit[1])*1000])
plot,[0],[0],color=fsc_color('black'),background=fsc_color('white'),$
  /nodata,title='Comparison of central profiles along Y',$
  xtitle='Y (mm)',ytitle='Z (um)',yrange=yrange,xrange=range(yvec)
oplot,yvec,total(newdiff_flat[*,24:25],2)*1000/2.,color=colors[0]
oplot,yvec,total(feasurf_flat[*,24:25],2)*1000/2.,color=colors[1]
oplot,yvec,total(feasurf_flat[*,24:25]*oneParFit[0],2)*1000/2.,color=colors[2]
oplot,yvec,total(feasurf_flat[*,24:25]*bestFit[0]-bestfit[1],2)*1000/2.,color=colors[3]
legend,['Measured', 'FEA','Rescaled (1 par)', '2 pars fit'],color=colors[0:3]
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif else maketif,img_dir+path_sep()+'yprofile_flat'
report->figure,fn(img_dir+path_sep()+'yprofile_flat',/u),$
  caption=outname+': profile over the central line along Y direction,'+$
  ' compared to measured data, 2 parameters fit, for leveled IF, according to '+$
    '!$z_{\mathrm{meas}}='+string(bestfit[0])+'z_{\mathrm{FEA}}'+$
    string(-bestfit[1]*1000,format='(f+0.4)')+'\mu m$!.'+$
    ' and single parameter rescaling according to !$z_{\mathrm{meas}}='+$
    string(oneparfit,format='(f+0.4)')+'z_{\mathrm{FEA}}$!.',$
    parameters='width=0.9\textwidth'

endif


  !P.thick=1
  !X.thick=1
  !y.thick=1
  !P.charthick=1
report->compile,3,/clean,/pdf
obj_destroy,report
end         
