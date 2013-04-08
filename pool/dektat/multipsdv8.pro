pro multipsdv8,filelist,roi_um=roi_um,nbins=nbins,sectionlevel=sectionlevel,outname=outname,$
  report=report,author=author,title=title,outfolder=outfolder,labels=labels,nonum=nonum,text=text,$
  type=type,baseIndex=baseIndex,xindex=xIndex

;calculate all the parameters and data needed for a report.
; outfolder is the folder that contain the imgdir (<outname>_img).
; if a report object is not passed in <report>, create it in outfolder with name <outname>_report, 
; otherwise append.
; outname is used in the plot titles and for the names and folder of the created images.
; TODO: accept a string or a object in report, if string, use it as the name of the latex file to be created,
;       if object, append (as now).  
; TODO: compile the pdf only if latex did not give errors

nfiles=n_elements(filelist)
if n_elements(roi_um) eq 0 then roi_um_m=fltarr(2,nfiles) else roi_um_m=rebin(roi_um,2,nfiles)
if n_elements(window) eq 0 then window_m=strarr(nfiles) else window_m=rebin(window,1,nfiles)

ps=0
if n_elements(outname) ne 0 then titlestring=outname+': ' else titlestring=''
img_dir=outfolder+path_sep()+outname+'_img'
if file_test(img_dir,/directory) eq 0 then file_mkdir,img_dir ;automatically create also outfolder

;graphics settings
set_plot_default
setStandardDisplay
if ps ne 0 then begin
  thstore=[!P.thick,!X.thick,!y.thick,!P.charthick]
  !P.thick=2
  !X.thick=2
  !y.thick=2
  !P.charthick=2
endif
colors=plotcolors(nfiles)

for i=0,nfiles-1 do begin
  extractpsd,filelist[i],roi_um=roi_um,nbins=nins,$ ;img_dir='test',wplot=[1,2,3],$
    x_roi_A=x_roi,y_roi_A=y_roi,freq=f,psd=psd,zlocations=zlocations,zhist=zhist,$
    xraw=x,yraw=y,level_coeff=level,scan_pars=scan_pars,fitpsd=fitpars,$
    normpars=normpars,window=window_m[i]
  
  if i eq 0 then begin 
    x_roi_m=list(x_roi)
    y_roi_m=list(y_roi)
    x_m=list(x)
    y_m=list(y)
    f_m=list(f)
    level_m=list(level)
    psd_m=list(psd)
    scan_pars_m=list(scan_pars)
    normpars_m=list(normpars)
    fitpars_m=list(fitpars)
  endif else begin
    x_roi_m=x_roi_m+list(x_roi)
    y_roi_m=y_roi_m+list(y_roi)
    x_m=x_m+list(x)
    y_m=y_m+list(y)
    f_m=f_m+list(f)
    level_m=level_m+list(level)
    psd_m=psd_m+list(psd)
    scan_pars_m=scan_pars_m+list(scan_pars)
    fitpars_m=fitpars_m+list(fitpars)
    normpars_m=normpars_m+list(normpars)
  endelse
endfor

if n_elements(labels) eq 0 then begin
  dummy=file_extension(filelist[0],legStr)
  for i=1,nfiles-1 do begin
    dummy=file_extension(filelist[i],tmp)
    legStr=[legStr,tmp]
  endfor
endif else legstr=labels

;create raw profile plot and data
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+outname+'_rawdata.eps', /COLOR,/encapsulated  
endif else window,0
plot,[0],[0],xtitle='x (mm)',ytitle='y (A)',background=255,$
  color=0,xrange=range8(x_m)/10000000.,yrange=range8(y_m),$
  title=titleString+'raw profile',/nodata,ytickformat='(i)'
oplot,x_m[0]/10000000.,y_m[0],color=colors[0]
for i=1,nfiles-1 do begin
  oplot,x_m[i]/10000000.,y_m[i],color=colors[i]
endfor
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;create leveled profile plot and data
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+outname+'_profile.eps', /COLOR,/encapsulated  
endif else window,1
plot,[0],[0],xtitle='x (mm)',ytitle='y (A)',background=255,$
  color=0,xrange=range8(x_roi_m)/10000000.,yrange=range8(y_roi_m),$
  title=titleString+'leveled profile',/nodata,ytickformat='(i)'
oplot,x_roi_m[0]/10000000.,y_roi_m[0],color=colors[0]
for i=1,nfiles-1 do begin
  oplot,x_roi_m[i]/10000000.,y_roi_m[i],color=colors[i]
endfor
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;create PSD plot and data
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+outname+'_psd.eps', /COLOR,/encapsulated  
endif else window,2
plot,[0],[0],/xlog,/ylog,ytickformat='exponent',$
  xtitle='Frequency (mm^-1)',ytitle='Amplitude (um^3)',background=255,color=0,$
  title=titleString+'PSD from leveled profile',/nodata,$
  xrange=range8(f_m)*10000000.,yrange=range8(psd_m)*10d-12
oplot,f_m[0]*10000000.,psd_m[0]*10d-12,color=colors[0]
oplot,f_m[0]*10000000.,(fitpars_m[0])[0]/(ABS(f_m[0])^(fitpars_m[0])[1])*10d-12,color=colors[0],linestyle=2
for i=1,nfiles-1 do begin
  oplot,f_m[i]*10000000.,psd_m[i]*10d-12,color=colors[i]
  ;oplot,f*10000000.,fitpars_m[0,i]*f*10000000.+fitpars_m[1,i]*10d-12,color=colors[i],linestyle=2
  oplot,f_m[i]*10000000.,(fitpars_m[i])[0]/(ABS(f_m[i])^(fitpars_m[i])[1])*10d-12,color=colors[i],linestyle=2
;  S=K_n/(ABS(F)^N)
;  S=fitpars_m[0,i]/(ABS(F)^fitpars_m[1,i])
endfor
highlightLam=[0.01,0.03] ;lambda in mm^-1    
for i =0,n_elements(highlightLam)-1 do begin
  oplot,[highlightLam[i],highlightLam[i]],10^!Y.Crange,color=6,linestyle=2
endfor
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;create stats plot and data
;; calculate data
zstats_m=list(histostats(y_roi_m[0],title='Distribution of heights (A)',$
    nbins=nbins,/noplot,background=255,color=0,position=12,$
    locations=zlocations,hist=zhist,xtitle='z (A)',ytitle='Fraction',$
    /normalize,min=lmin(y_roi_m),max=lmax(y_roi_m)))
zlocations_m=list(zlocations)
hist_m=list(zhist)
for i=1,nfiles-1 do begin
zstats_m=zstats_m+list(histostats(y_roi_m[i],title='Distribution of heights (A)',$
    nbins=nbins,/noplot,locations=zlocations,hist=zhist,$
    /normalize,min=lmin(y_roi_m),max=lmax(y_roi_m)))
zlocations_m=zlocations_m+list(zlocations)
hist_m=hist_m+list(zhist)
endfor
;; plot data. The plot needs to be done in a different step to account for the vertical range8.
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+outname+'_hist.eps', /COLOR,/encapsulated  
endif else window,3
expansionFactor=1.1
plot,[0],[0],title=titleString+'Distribution of heights (A)',$
    background=255,color=0,xtitle='z (A)',ytitle='Fraction',$
    xrange=range8(y_roi_m),yrange=[0,lmax(hist_m)*expansionFactor]
oplot,zlocations_m[0],hist_m[0],color=colors[0],psym=10
for i=1,nfiles-1 do begin
  oplot,zlocations_m[i],hist_m[i],color=colors[i],psym=10
endfor
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;create diff plot and data
;;differences in profiles
ydiff_m=difffunc(x_m,y_m,x_mbase=xdiff_m,/removeBase,baseIndex=baseIndex,xIndex=xIndex)
ndiffvectors=n_elements(ydiff_m)
diffmask=where(indgen(nfiles) ne baseIndex)
multiplot,listmatrixtoarray(xdiff_m)/10000000.,listmatrixtoarray(ydiff_m),$
  psfile=(ps ne 0)?img_dir+path_sep()+outname+'_differences.eps':'',$
  xtitle='x (mm)',ytitle='Delta y (A)',background=255,color=0,$
  linecolors=colors[diffmask],$
  legend=legstr[diffmask],$
  title='Difference in raw profile with '+legstr[baseIndex],ytickformat='(i)'
 ;;stats calculation
diffstats_m=list(histostats(ydiff_m[0],$
    title=titleString+'distribution of differences with '+legstr[baseIndex]+' (A)',$
    nbins=nbins,/noplot,background=255,color=0,position=12,$
    locations=difflocations,hist=diffhist,xtitle='Delta z (A)',ytitle='Fraction of total number',$
    /normalize,min=lmin(ydiff_m),max=lmax(ydiff_m)))
difflocations_m=list(difflocations)
diffhist_m=list(diffhist)
if ndiffvectors gt 1 then begin
  for i=1,ndiffvectors-1 do begin
    diffstats_m=diffstats_m+list(histostats(ydiff_m[i],$
        nbins=nbins,/noplot,locations=difflocations,hist=diffhist,$
        /normalize,min=lmin(ydiff_m),max=lmax(ydiff_m)))
    difflocations_m=difflocations_m+list(difflocations)
    diffhist_m=diffhist_m+list(diffhist)
  endfor
endif
 ;;stats plot. The plot needs to be done in a different step to account for the vertical range.
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+outname+'_diffhist.eps', /COLOR,/encapsulated  
endif else window,3
expansionFactor=1.1
plot,[0],[0],title='Distribution of differences with '+legstr[baseIndex]+' (A)',$
    background=255,color=0,xtitle='z (A)',ytitle='Fraction of total number',$
    xrange=range8(ydiff_m),yrange=[0,lmax(diffhist_m)*expansionFactor]
oplot,difflocations_m[0],diffhist_m[0],color=colors[diffmask[0]],psym=10
for i=1,ndiffvectors-1 do begin
  oplot,difflocations_m[i],diffhist_m[i],color=colors[diffmask[i]],psym=10
endfor
legend,legstr[diffmask],color=colors[diffmask],position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;restore graphics settings
if ps ne 0 then begin
  !P.thick=thstore[0]
  !X.thick=thstore[1]
  !y.thick=thstore[2]
  !P.charthick=thstore[3]
endif

;create report tex file and compile it
;;create stats table
statsheader=['Mean','PV','Min','Max','Rms',$
              'Ra','Stndrd dev of mean','Variance','Skewness','Residual kurtosis'] ;complete list of names for the fields
conversion=[10.^(-4),10.^(-4),10.^(-4),10.^(-4),10.^(-4),10.^(-4),10.^(-4),10.^(-4),1.,1.] ;complete list of conversion factors for the fields
;conversion=rebin(conversion,n_elements(statsheader),nfiles)
;
statsmask=[0,2,3,1,4,5,8,9] ;used to select and sort names and values
formatstring='(a,'+strjoin(replicate('f8.4',nfiles),',')+')'
vals=zstats_m[statsmask,*]*rebin(conversion[statsmask],n_elements(statsmask),nfiles)
statstable=makelatextable(string(vals),rowheader=statsheader[statsmask],$
   colheader=latextableline(["",labels]),format=formatstring)
   
;;create diff table
statsmask=[0,2,3,1,4,5] ;used to select and sort names and values
formatstring='(a,'+strjoin(replicate('f8.4',ndiffvectors),',')+')'
vals=diffstats_m[statsmask,*]*rebin(conversion[statsmask],n_elements(statsmask),ndiffvectors)
diffstatstable=makelatextable(string(vals),rowheader=statsheader[statsmask],$
   colheader=latextableline(["",labels[where(indgen(nfiles) ne baseIndex)]]),format=formatstring)

;now all data are loaded (and figure generated if ps=1)
;If a report object is passed append the text, otherwise create it.
createReport=(obj_valid(report) eq 0)
if createReport then report=obj_new('lr',outfolder+path_sep()+outname+'_report.tex',title=title,$
                author=author,level=sectionlevel)
                
;General description
if (sectionlevel eq report->get_lowestLevel()) then begin
  report->section,sectionlevel,'Samples '+outname,nonum=nonum
endif else report->section,sectionlevel,outname,nonum=nonum
report->append,'Results folder: '+outfolder
report->append,''
report->append,'Outname: '+outname
report->append,['','']
if n_elements(text) ne 0 then report->append,text
report->list,labels+': '+filelist,/nonum

;Raw data
if in (strlowcase(type),['debug','differences','psd']) then begin
  report->section,sectionlevel+1,'Scan Data',nonum=nonum
  parstable=makelatextable(string(scan_pars_m),rowheader=['Stylus radius',$
      'Full scan Length','N of points', 'X step','Roi Start','Roi End'],$
      colheader=latextableline(["",labels]))
  report->table,parstable,strjoin(replicate('c',nfiles+1)),caption='Scan parameters, values in$\mu$m.'
  report->figure,img_dir+path_sep()+outname+'_rawdata',caption='Raw data profile.',parameters='width=0.75\textwidth'
endif

;Leveling and profile stats
if in (strlowcase(type),['debug','psd']) then begin
  report->section,sectionlevel+1,'Profile analysis',nonum=nonum
  formatstring='(a,'+strjoin(replicate('f8.4',nfiles),',')+')'
  leveltable=makelatextable(string(level_m/10000.),rowheader=['a0','a1','a2'],$
     colheader=latextableline(["",labels]),format=formatstring)
  report->table,leveltable,strjoin(replicate('c',nfiles+1)),caption='Components removed for leveling, values in $\mu$m (N.B.:):'
  report->figure,img_dir+path_sep()+outname+'_profile',caption='Profile after leveling.',parameters='width=0.75\textwidth'
  report->table,statstable,strjoin(replicate('c',nfiles+1)),caption='Statistics after leveling, values in $\mu$m,'+$
      ' skewness and kurtosis are dimensionless.'
  report->figure,img_dir+path_sep()+outname+'_hist',caption='Distribution of heights.',parameters='width=0.75\textwidth'
endif

;PSD average (includes calculation)
if in (strlowcase(type),['debug','psdaverage']) then begin
  if ps ne 0 then begin
    file_mkdir,img_dir
    SET_PLOT, 'PS'
    DEVICE, filename=img_dir+path_sep()+outname+'_avg_psd.eps', /COLOR,/encapsulated  
  endif else window,5
  
  ;check that all the psd are calculated over the same frequency points
  xchk=f_m[*,0]
  for i=1,nfiles-1 do begin
    if array_equal(f_m[*,i],xchk) ne 1 then begin 
      print, 'Frequency of ',i,'-th vector does not correspond to the 0th frequency'
      print, 'Average of PSD not performed'
      goto, exitPsdAvg
    endif
  endfor
  averagePSD=total(psd_m,2)/nfiles
  
  ;fit
  Result=PSD_FIT(xchk,averagepsd,avgPARS)
  fitavgpsd=avgpars

  plot,xchk*10000000.,averagePSD*10d-12,/xlog,/ylog,ytickformat='exponent',$
    xtitle='Frequency (mm^-1)',ytitle='Amplitude (um^3)',background=255,color=0,$
    title=titleString+'average PSD from '+string(nfiles,format='(i2)')+' profiles'
  oplot,xchk*10000000.,fitavgpsd[0]/(ABS(F)^fitavgpsd[1])*10d-12,color=colors[0],linestyle=2
  highlightLam=[0.01,0.03] ;lambda in mm^-1    
  for i =0,n_elements(highlightLam)-1 do begin
    oplot,[highlightLam[i],highlightLam[i]],10^!Y.Crange,color=6,linestyle=2
  endfor
  legend,['Average PSD','Fit'],position=12,color=[0,colors[0]]
  
  exitPsdAvg:
  if ps ne 0 then begin
    DEVICE, /CLOSE 
    SET_PLOT_default
  endif

  report->section,sectionlevel+1,'Average PSD',nonum=nonum      
  report->figure,img_dir+path_sep()+outname+'_avg_psd',caption='Average PSD from '+strjoin(labels,', ')+'.'+$
          ' Fit parameters (according to $PSD(f)=K|f|^{-N}$): '+strjoin((['K=','N=']+string(fitavgpsd)),', '),$
          parameters='width=0.75\textwidth'
endif

;PSD analysis and fit
if in (strlowcase(type),['debug','psd','psdaverage']) then begin
  report->section,sectionlevel+1,'PSD analysis',nonum=nonum
  report->figure,img_dir+path_sep()+outname+'_psd',caption='PSD after leveling, smoothing with Hann window and normalization.',$
          parameters='width=0.75\textwidth'
          ;normpars=[integral,var,1/integral*var]
          conversion=rebin([10.^(-4),10.^(-4),1.,10.^(-12),1.],5,nfiles)
  psdtable=makelatextable(string([normpars_m,fitpars_m]*conversion),$
        rowheader=['(Integrated PSD)$^{\frac{1}{2}}$ ($\mu$m)','$\sigma$ ($\mu$m)',$
        'Scaling factor','K ($\mu$m$^3$) from fit','N from fit'],$
        colheader=latextableline(["",labels]))
  report->table,psdtable,strjoin(replicate('c',nfiles+1)),caption='Fit parameters for PSD '+$
      '(according to $PSD(f)=K|f|^{-N}$).'
endif

;Differences
if in (strlowcase(type),['differences']) then begin
  report->section,sectionlevel+1,'Differences between raw data',nonum=nonum
  formatstring='(a,'+strjoin(replicate('f8.4',nfiles),',')+')'  
  report->figure,img_dir+path_sep()+outname+'_differences',caption='Differences in measured profile' $
    +' with respect to '+labels[baseIndex] ,parameters='width=0.75\textwidth'
  report->figure,img_dir+path_sep()+outname+'_diffhist',caption='Distribution of differences in heights.',$
  parameters='width=0.75\textwidth'
  report->table,diffstatstable,strjoin(replicate('c',ndiffvectors+1)),caption='Statistics from differences with '+$
      legstr[baseIndex]+', values in $\mu$m.'
endif

if createReport then begin
  report->compile,2,/pdf,/clean
  obj_destroy,report
endif
end

pro test_multi_psdv8

  roi_um= [1000,59000]
  nbins=100
  ;obj_destroy,report
  
  ;filelist=['H:\psf\vincenzo_glass1\A01_00F_L.csv',$
  ;          'H:\psf\vincenzo_glass1\A01_00F_C.csv',$
  ;          'H:\psf\vincenzo_glass1\A01_00F_R.csv']
  filelist=['/home/cotroneo/Desktop/PSD/Vincenzo_glass1/A01_00F_L.csv',$
            '/home/cotroneo/Desktop/PSD/Vincenzo_glass1/A01_00F_C.csv',$
            '/home/cotroneo/Desktop/PSD/Vincenzo_glass1/A01_00F_R.csv']
  author='Vincenzo Cotroneo'       
  outfolder='/home/cotroneo/Desktop/PSD/Vincenzo_glass1/test1'
  outname='A01_00F'   
  title='PSD analysis of '+outname+' files'
  sectionlevel=1
  labels=stripext(map('file_basename',filelist)) 
           
  multipsdv8,filelist,roi_um=roi_um,nbins=nbins,sectionlevel=sectionlevel,outname=outname,$
    report=report,author=author,title=title,outfolder=outfolder,labels=labels,/nonum,type='debug'
end

test_multi_psdv8
  
end