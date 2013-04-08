
pro extractpsd_obj,filename,roi_um=roi_um,binsize=binsize,wplot=wplot,img_dir=img_path,$
    x_roi_A=x_roi,y_roi_A=y_roi,freq=f,psd=psd,zlocations=zlocations,zhist=zhist,$
    absoluteImgPath=absoluteImgPath,xraw=x,yraw=y
; wplot vector of integers indicating which quantity to plot:
; 1: plot profile
; 2: plot psf
; 3: plot histogram of heights
; if negative plots only on window, without generating corresponding image (ps) file
set_plot_default
setStandardDisplay

ext=file_extension(filename,basename)
folder=file_dirname(filename)

;initialize img_dir and create the directory if needed
if n_elements(wplot) ne 0 then begin 
  tmp=where(wplot gt 0,count)
  if count ne 0 then begin
    if n_elements(img_path) eq 0 then img_dir=folder+path_sep()+basename+'_img' $
    else begin
       if ~keyword_set(absoluteImgPath) then img_dir=folder+path_sep()+img_path $
       else img_dir=img_path
    endelse
    if file_test(img_dir,/directory) eq 0 then file_mkdir,img_dir
  endif
endif else wplot=0



;leveling
y_roi=level(y,2)
print,'min, max, PV',min(y_roi),max(y_roi),max(y_roi)-min(y_roi)
psd=prof2psd(x_roi,y_roi,f=f,/positive_only,/kaiser)

;profile
wnum=1
if in (wnum,abs(wplot)) then begin
  window,wnum
  plot,x_roi/10000000.,y_roi,xtitle='x (mm)',ytitle='y (A)',background=255,color=0
  print,"Frequency in the range: ",min(f),'-',max(f)
  if in(wnum,wplot) then begin
    SET_PLOT, 'PS'
    DEVICE, filename=img_dir+path_sep()+basename+'_profile.eps', /COLOR,/encapsulated
      plot,x_roi/10000000.,y_roi,xtitle='x (mm)',ytitle='y (A)',background=255,color=0
    DEVICE, /CLOSE 
    SET_PLOT_default
  endif
endif 

;psf
wnum=2
if in (wnum,abs(wplot)) then begin
  window,wnum
  plot,f*10000.,psd,/xlog,/ylog,xtitle='Frequency (um^-1)',ytitle='Amplitude',background=255,color=0
  print,"Frequency in the range: ",min(f),'-',max(f)
  if in(wnum,wplot) then begin
    SET_PLOT, 'PS'
    DEVICE, filename=img_dir+path_sep()+basename+'_psd.eps', /COLOR,/encapsulated
      plot,f*10000.,psd,/xlog,/ylog,xtitle='Frequency (um^-1)',ytitle='Amplitude',background=255,color=0
    DEVICE, /CLOSE 
    SET_PLOT_default
  endif
endif 

;histogram of heights
wnum=3
if in(wnum,abs(wplot)) then window,wnum
zstats=histostats(y_roi,title='Distribution of heights (A)',$
    binsize=binsize,noplot=~in(wnum,abs(wplot)),$
    background=255,color=0,position=12,locations=zlocations,$
    hist=zhist,xtitle='z (A)',ytitle='Fraction',/normalize,$
    min=min,max=max)
if in(wnum,wplot) then begin
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+basename+'_hist.eps', /COLOR,/encapsulated
    zhist=histostats(y_roi,title='Distribution of heights (A)',$
        binsize=binsize,background=255,color=0,position=12,$
        locations=zlocations,xtitle='z (A)',ytitle='Fraction',/normalize,$
        min=min,max=max)
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

print,"Frequency in the range: ",min(f),'-',max(f)

end


roi_um= [1000,59000]
binsize=10.
;filelist=['H:\psf\vincenzo_glass1\A01_00F_L.csv',$
;          'H:\psf\vincenzo_glass1\A01_00F_C.csv',$
;          'H:\psf\vincenzo_glass1\A01_00F_R.csv']
filelist=['/home/cotroneo/Desktop/psf/vincenzo_glass1/A01_00F_L.csv',$
          '/home/cotroneo/Desktop/psf/vincenzo_glass1/A01_00F_C.csv',$
          '/home/cotroneo/Desktop/psf/vincenzo_glass1/A01_00F_R.csv']
img_base='A01_00F'
folder=file_dirname(filelist[0])
ps=1

author='Vincenzo Cotroneo'
img_dir=file_dirname(filelist[0])+path_sep()+img_base
colors=legendcolors(n_elements(filelist))

for i=0,n_elements(filelist)-1 do begin
  extractpsf,filelist[i],roi_um=roi,binsize=binsize,img_dir='test',wplot=[1,2,3],$
    x_roi_A=x_roi,y_roi_A=y_roi,freq=f,psd=psd,zlocations=zlocations,zhist=zhist,$
    xraw=x,yraw=y
  if i eq 0 then begin 
    x_roi_m=x_roi
    y_roi_m=y_roi
    x_m=x
    y_m=y
    f_m=f
    psd_m=psd
  endif else begin
    x_roi_m=[[x_roi_m],[x_roi]]
    y_roi_m=[[y_roi_m],[y_roi]]
    x_m=[[x_m],[x]]
    y_m=[[y_m],[y]]
    f_m=[[f_m],[f]]
    psd_m=[[psd_m],[psd]]
  endelse
endfor

if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+img_base+'_rawdata.eps', /COLOR,/encapsulated  
endif else window,0
plot,[0],[0],xtitle='x (mm)',ytitle='y (A)',background=255,$
  color=0,xrange=range(x_m/10000000.),yrange=range(y_m),$
  title='Raw profile',/nodata
oplot,x_m[*,0]/10000000.,y_m[*,0],color=colors[0]
dummy=file_extension(filelist[0],legStr)
for i=1,n_elements(filelist)-1 do begin
  oplot,x_m[*,0]/10000000.,y_m[*,i],color=colors[i]
  dummy=file_extension(filelist[i],tmp)
  legStr=[legStr,tmp]
endfor
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif


if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+img_base+'_profile.eps', /COLOR,/encapsulated  
endif else window,1
plot,[0],[0],xtitle='x (mm)',ytitle='y (A)',background=255,$
  color=0,xrange=range(x_roi_m/10000000.),yrange=range(y_roi_m),$
  title='Leveled profile',/nodata
oplot,x_roi_m[*,0]/10000000.,y_roi_m[*,0],color=colors[0]
dummy=file_extension(filelist[0],legStr)
for i=1,n_elements(filelist)-1 do begin
  oplot,x_roi_m[*,0]/10000000.,y_roi_m[*,i],color=colors[i]
  dummy=file_extension(filelist[i],tmp)
  legStr=[legStr,tmp]
endfor
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+img_base+'_psd.eps', /COLOR,/encapsulated  
endif else window,2
plot,[0],[0],/xlog,/ylog,$
  xtitle='Frequency (um^-1)',ytitle='Amplitude',background=255,color=0,$
  title='PSD from leveled profile',/nodata,$
  xrange=range(f*10000.),yrange=range(psd)
oplot,f_m[*,0]*10000.,psd_m[*,0],color=colors[0]
dummy=file_extension(filelist[0],legStr)
for i=1,n_elements(filelist)-1 do begin
  oplot,f_m[*,i]*10000.,psd_m[*,i],color=colors[i]
  dummy=file_extension(filelist[i],tmp)
  legStr=[legStr,tmp]
endfor
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

zstats_m=histostats(y_roi_m[*,0],title='Distribution of heights (A)',$
    binsize=binsize,/noplot,background=255,color=0,position=12,$
    locations=zlocations,hist=zhist,xtitle='z (A)',ytitle='Fraction',$
    /normalize,min=min(y_roi_m),max=max(y_roi_m))
zlocations_m=zlocations
hist_m=zhist
for i=1,n_elements(filelist)-1 do begin
zstats_m=[[zstats_m],[histostats(y_roi_m[*,i],title='Distribution of heights (A)',$
    binsize=binsize,/noplot,background=255,color=0,position=12,$
    locations=zlocations,hist=zhist,xtitle='z (A)',ytitle='Fraction',$
    /normalize,min=min(y_roi_m),max=max(y_roi_m))]]
zlocations_m=[[zlocations_m],[zlocations]]
hist_m=[[hist_m],[zhist]]
endfor

if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+img_base+'_hist.eps', /COLOR,/encapsulated  
endif else window,3
expansionFactor=1.1
plot,[0],[0],title='Distribution of heights (A)',$
    background=255,color=0,xtitle='z (A)',ytitle='Fraction',$
    xrange=range(y_roi_m),yrange=[0,max(hist_m)*expansionFactor]
oplot,zlocations_m[*,0],hist_m[*,0],color=colors[0],psym=10
for i=1,n_elements(filelist)-1 do begin
  oplot,zlocations_m[*,i],hist_m[*,i],color=colors[i],psym=10
endfor    
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;create report
;;create stats table
filebases=stripext(map('file_basename',filelist))

statsheader=['Mean','PV','Min','Max','Rms',$
              'Ra','Stndrd dev of mean','Variance','Skewness','Kurtosis'] ;complete list of names for the fields
statsmask=[0,2,3,1,4,5,8,9] ;used to select and sort names and values
statstable=makelatextable(string(zstats_m[statsmask,*]),rowheader=statsheader[statsmask],$
   colheader=latextableline(["",filebases]))

;now all data are loaded and figure generated (if ps=1)
;create the report
report=obj_new('lr',img_base+'_report.tex',title='PSD analysis of '+img_base+' files',$
                author=author,/toc)
report->section,1,'Samples '+img_base,/nonum
report->append,'folder: '+folder
report->list,filebases
report->section,2,'Parameters',/nonum

report->section,2,'Results',/nonum
report->section,2,'Plots',/nonum
report->figure,img_dir+path_sep()+img_base+'_rawdata',caption='Raw data profile.',parameters='width=0.75\textwidth'
report->figure,img_dir+path_sep()+img_base+'_profile',caption='Profile after leveling.',parameters='width=0.75\textwidth'
report->table,statstable,'cccc'
report->figure,img_dir+path_sep()+img_base+'_psd',caption='Profile after leveling.',parameters='width=0.75\textwidth'
report->figure,img_dir+path_sep()+img_base+'_hist',caption='Distribution of heights.',parameters='width=0.75\textwidth'
report->compile,1,/pdf,/clean
obj_destroy,report

end