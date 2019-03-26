pro multipsd,filelist,roi_um=roi_um,nbins=nbins,sectionlevel=sectionlevel,outname=outname,$
  report=report,author=author,title=title,outfolder=outfolder,labels=labels,nonum=nonum,text=text,$
  includeSections=includeSections,baseIndex=baseIndex,allcouples=allcouples,xindex=xIndex,xoffset=xoffset,$
  groups=groups

;calculate all the parameters and data needed for a report.
; outfolder is the folder that contain the imgdir (<outname>_img).
; if a report object is not passed in <report>, create it in outfolder with name <outname>_report, 
; otherwise append.
; outname is used in the plot titles and for the names and folder of the created images.
; TODO: accept a string or a object in report, if string, use it as the name of the latex file to be created,
;       if object, append (as now).  
; TODO: compile the pdf only if latex did not give errors
; TODO: for now it dtermine the matrix dimensi
; on from first array, it works if the largest array is defined
; as first -> adapt to the general case
;values for includesections
    ;0 general information
    ;1 raw data and scan settings
    ;2 leveling and stats
    ;3 psd average with fit
    ;4 differences between raw profiles and stats   
    ;5 differences between leveled profiles and stats
    ;6 psd analysis and fit  
    
if n_elements(groups) ne 0 then includeSections=[6]

print,'**'+outname+'**'
nfiles=n_elements(filelist)
if n_elements(roi_um) eq 0 then roi_um_m=fltarr(2,nfiles) else begin
  if n_elements(roi_um) eq 2*nfiles then roi_um_m=reform(roi_um,2,nfiles) $
  else if n_elements(roi_um) eq 2 then roi_um_m=rebin(roi_um,2,nfiles) else message,$
    'wrong number of elements for roi, roi= ,+string(roi_um)
endelse
roi_um_m=float(roi_um_m)
if n_elements(window) eq 0 then window_m=strarr(nfiles) else window_m=replicate(window,1,nfiles)

ps=1
levelPartial=1
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

if n_elements(xoffset) eq 0 then xoffset=0
if n_elements(xoffset) eq 1 then xoffset=replicate(xoffset,nfiles) else $
  if n_elements(xoffset) ne nfiles then message,'invalid number of elements for xoffset='+string(n_elements(xoffset))
xoffset=float(xoffset)
  
get_lun,psfn
openw,psfn,img_dir+path_sep()+outname+'_verifyStats.txt'
printf,psfn,'Profile stats after the removal of the first ',levelPartial+1,' components,'
printf,psfn,'for comparison with the measuring software values.'
maxlennames=max(map('strlen',filelist))
printf,psfn
printf,psfn,'Filename','rms','Ra','PV',format='(a'+$
      ',T'+strtrim(string(maxlennames+3),2)+',TR7,a,TR8,a,TR8,a)'

for i=0,nfiles-1 do begin
  extractpsd,filelist[i],roi_um=roi_um_m[*,i],nbins=nins,$ ;img_dir='test',wplot=[1,2,3],$
    x_roi_A=x_roi,y_roi_A=y_roi,freq=f,psd=psd,zlocations=zlocations,zhist=zhist,$
    xraw=x,yraw=y,level_coeff=level,scan_pars=scan_pars,fitpsd=fitpars,$
    normpars=normpars,window=window_m[i],xoffset=xoffset[i],$
    levelPartial=levelPartial,partialStats=partialStats
  
  if i eq 0 then begin 
    x_roi_m=x_roi
    y_roi_m=y_roi
    x_m=x
    y_m=y
    f_m=f
    level_m=level
    psd_m=psd
    scan_pars_m=scan_pars
    normpars_m=normpars
    fitpars_m=fitpars
    partialStats_m=partialStats
  endif else begin
    x_roi_m=concatenate(x_roi_m,x_roi,2)
    y_roi_m=concatenate(y_roi_m,y_roi,2)
    x_m=concatenate(x_m,x,2)
    y_m=concatenate(y_m,y,2)
    f_m=concatenate(f_m,f,2)
    level_m=concatenate(level_m,level,2)
    psd_m=concatenate(psd_m,psd,2)
    scan_pars_m=concatenate(scan_pars_m,scan_pars,2)
    fitpars_m=concatenate(fitpars_m,fitpars,2)
    normpars_m=concatenate(normpars_m,normpars,2)
    partialStats_m=concatenate(partialStats_m,partialStats,2)
  endelse
  printf,psfn,filelist[i],partialstats[0],partialstats[1],partialstats[2],format='(a'+$
      ',T'+strtrim(string(maxlennames+3),2)+',f10.1,TR2,f10.1,TR2,f10.1)'
endfor
free_lun,psfn

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
  color=0,xrange=range(x_m)/10000000.,yrange=range(y_m),$
  title=titleString+'raw profile',/nodata,ytickformat='(i)'
oplot,x_m[*,0]/10000000.,y_m[*,0],color=colors[0]
for i=1,nfiles-1 do begin
  oplot,x_m[*,i]/10000000.,y_m[*,i],color=colors[i]
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
  color=0,xrange=range(x_roi_m)/10000000.,yrange=range(y_roi_m),$
  title=titleString+'leveled profile',/nodata,ytickformat='(i)'
oplot,x_roi_m[*,0]/10000000.,y_roi_m[*,0],color=colors[0]
for i=1,nfiles-1 do begin
  oplot,x_roi_m[*,i]/10000000.,y_roi_m[*,i],color=colors[i]
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
  xtitle='Frequency (mm^-1)',ytitle='Amplitude ('+Greek('mu')+'!3m!E3!N)',background=255,color=0,$
  title=titleString+'PSD from leveled profile',/nodata,$
  xrange=range(f_m)*10000000.,yrange=range(psd_m)*10d-12
oplot,f_m[*,0]*10000000.,psd_m[*,0]*10d-12,color=colors[0]
oplot,f_m[*,0]*10000000.,fitpars_m[0,0]/(ABS(f_m[*,0])^fitpars_m[1,0])*10d-12,color=colors[0],linestyle=2
for i=1,nfiles-1 do begin
  oplot,f_m[*,i]*10000000.,psd_m[*,i]*10d-12,color=colors[i]
  ;oplot,f*10000000.,fitpars_m[0,i]*f*10000000.+fitpars_m[1,i]*10d-12,color=colors[i],linestyle=2
  oplot,f_m[*,i]*10000000.,fitpars_m[0,i]/(ABS(f_m[*,i])^fitpars_m[1,i])*10d-12,color=colors[i],linestyle=2
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
zstats_m=histostats(y_roi_m[where(finite(y_roi_m[*,0])),0],$
    nbins=nbins,/noplot,locations=zlocations,hist=zhist,$
    /normalize,min=min(y_roi_m,/nan),max=max(y_roi_m,/nan))
zlocations_m=zlocations
hist_m=zhist
for i=1,nfiles-1 do begin
zstats_m=[[zstats_m],[histostats(y_roi_m[where(finite(y_roi_m[*,i])),i],$
    nbins=nbins,/noplot,locations=zlocations,hist=zhist,$
    /normalize,min=min(y_roi_m,/nan),max=max(y_roi_m,/nan))]]
zlocations_m=concatenate(zlocations_m,zlocations,2)
hist_m=concatenate(hist_m,zhist,2)
endfor
;; plot data. The plot needs to be done in a different step to account for the vertical range.
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+outname+'_hist.eps', /COLOR,/encapsulated  
endif else window,3
expansionFactor=1.1
plot,[0],[0],title=titleString+'Distribution of heights for leveled data',$
    background=255,color=0,xtitle='z (A)',ytitle='Fraction',$
    xrange=range(y_roi_m),yrange=[0,max(hist_m,/nan)*expansionFactor]
oplot,zlocations_m[*,0],hist_m[*,0],color=colors[0],psym=10
for i=1,nfiles-1 do begin
  oplot,zlocations_m[*,i],hist_m[*,i],color=colors[i],psym=10
endfor
legend,legstr,color=colors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif

;create diff plot and data - raw profiles
;;calculate differences in raw profiles
ydiff_m=difffunc(x_m,y_m,x_mbase=xdiff_m,/removeBase,baseIndex=baseIndex,xIndex=xIndex,allcouples=allcouples,couples=couples)
tmp=size(ydiff_m,/dimension)
ndiffvectors=tmp[1]
diffcolors=[colors[couples[1,*]]]
;diffmask=where(indgen(nfiles) ne baseIndex) 
for i=0,ndiffvectors-1 do begin
  diffleg=(i eq 0)?strjoin(reverse(legstr[couples[*,i]]),' - '):[diffleg,strjoin(reverse(legstr[couples[*,i]]),' - ')]
endfor
multiplot,xdiff_m/10000000.,ydiff_m,psfile=(ps ne 0)?img_dir+path_sep()+outname+'_differences_raw.eps':'',$
  xtitle='x (mm)',ytitle='Delta y (A)',background=255,color=0,$
  linecolors=diffcolors,$
  legend=diffleg,$
  title='Difference in raw profiles ',ytickformat='(i)'
 ;;stats calculation
diffstats_m=histostats(ydiff_m[where(finite(ydiff_m[*,0])),0],$
    title=titleString+'distribution of differences in raw profile (A)',$
    nbins=nbins,/noplot,background=255,color=0,position=12,$
    locations=difflocations,hist=diffhist,xtitle='Delta z (A)',ytitle='Fraction of total number',$
    /normalize,min=min(ydiff_m,/nan),max=max(ydiff_m,/nan))
difflocations_m=difflocations
diffhist_m=diffhist
if ndiffvectors gt 1 then begin
  for i=1,ndiffvectors-1 do begin
    diffstats_m=[[diffstats_m],[histostats(ydiff_m[where(finite(ydiff_m[*,i])),i],$
        nbins=nbins,/noplot,locations=difflocations,hist=diffhist,$
        /normalize,min=min(ydiff_m,/nan),max=max(ydiff_m,/nan))]]
    difflocations_m=concatenate(difflocations_m,difflocations,2)
    diffhist_m=concatenate(diffhist_m,diffhist,2)
  endfor
endif
 ;;histogram plot. The plot needs to be done in a different step to account for the vertical range.
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+outname+'_diffhist_raw.eps', /COLOR,/encapsulated  
endif else window,4
expansionFactor=1.1
plot,[0],[0],title='Distribution of differences wrt "'+legstr[baseIndex]+'"',$
    background=255,color=0,xtitle='z (A)',ytitle='Fraction of total number',$
    xrange=range(ydiff_m),yrange=[0,max(diffhist_m)*expansionFactor]
oplot,difflocations_m[*,0],diffhist_m[*,0],color=diffcolors[0],psym=10
for i=1,ndiffvectors-1 do begin
  oplot,difflocations_m[*,i],diffhist_m[*,i],color=diffcolors[i],psym=10
endfor
legend,diffleg,color=diffcolors,position=12
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif


;create diff plot and data - leveled profiles
;;calculate differences in leveled profiles
ydiff_roi_m=difffunc(x_roi_m,y_roi_m,x_mbase=xdiff_roi_m,/removeBase,baseIndex=baseIndex2,allcouples=allcouples,couples=couples)
tmp=size(ydiff_roi_m,/dimension)
ndiffvectors=tmp[1]
diffmask=where(indgen(nfiles) ne baseIndex2)
multiplot,xdiff_roi_m/10000000.,ydiff_roi_m,psfile=(ps ne 0)?img_dir+path_sep()+outname+'_differences_lev.eps':'',$
  xtitle='x (mm)',ytitle='Delta y (A)',background=255,color=0,$
  linecolors=colors[diffmask],$
  legend=legstr[diffmask],$
  title='Difference in leveled profile with '+legstr[baseIndex2],ytickformat='(i)'
 ;;stats calculation
diff_roistats_m=histostats(ydiff_roi_m[where(finite(ydiff_roi_m[*,0])),0],$
    title=titleString+'distribution of differences with '+legstr[baseIndex2]+' leveled profile (A)',$
    nbins=nbins,/noplot,background=255,color=0,position=12,$
    locations=diff_roilocations,hist=diff_roihist,xtitle='Delta z (A)',ytitle='Fraction of total number',$
    /normalize,min=min(ydiff_roi_m,/nan),max=max(ydiff_roi_m,/nan))
diff_roilocations_m=diff_roilocations
diff_roihist_m=diff_roihist
if ndiffvectors gt 1 then begin
  for i=1,ndiffvectors-1 do begin
    diff_roistats_m=[[diff_roistats_m],[histostats(ydiff_roi_m[where(finite(ydiff_roi_m[*,i])),i],$
        nbins=nbins,/noplot,locations=diff_roilocations,hist=diff_roihist,$
        /normalize,min=min(ydiff_roi_m,/nan),max=max(ydiff_roi_m,/nan))]]
    diff_roilocations_m=concatenate(diff_roilocations_m,diff_roilocations,2)
    diff_roihist_m=concatenate(diff_roihist_m,diff_roihist,2)
  endfor
endif
 ;;histogram plot. The plot needs to be done in a different step to account for the vertical range.
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+outname+'_diffhist_lev.eps', /COLOR,/encapsulated  
endif else window,4
expansionFactor=1.1
plot,[0],[0],title='Distribution of differences wrt "'+legstr[baseIndex2]+'" leveled profile',$
    background=255,color=0,xtitle='z (A)',ytitle='Fraction of total number',$
    xrange=range(ydiff_roi_m),yrange=[0,max(diff_roihist_m)*expansionFactor]
oplot,diff_roilocations_m[*,0],diff_roihist_m[*,0],color=colors[diffmask[0]],psym=10
for i=1,ndiffvectors-1 do begin
  oplot,diff_roilocations_m[*,i],diff_roihist_m[*,i],color=colors[diffmask[i]],psym=10
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

;!P.thick=1
;!X.thick=1
;!y.thick=1
;!P.charthick=1
  
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
   colheader=latextableline(['','\emph{'+labels+'}']),format=formatstring)
   
;;create diff raw table
statsmask=[0,2,3,1,4,5] ;used to select and sort names and values
formatstring='(a,'+strjoin(replicate('f8.4',ndiffvectors),',')+')'
vals=diffstats_m[statsmask,*]*rebin(conversion[statsmask],n_elements(statsmask),ndiffvectors)
diffstatstable=makelatextable(string(vals),rowheader=statsheader[statsmask],$
   colheader=latextableline(['','\emph{'+labels[where(indgen(nfiles) ne baseIndex)]+'}']),format=formatstring)

;;create diff leveled table
statsmask=[0,2,3,1,4,5] ;used to select and sort names and values
formatstring='(a,'+strjoin(replicate('f8.4',ndiffvectors),',')+')'
vals=diff_roistats_m[statsmask,*]*rebin(conversion[statsmask],n_elements(statsmask),ndiffvectors)
diff_roistatstable=makelatextable(string(vals),rowheader=statsheader[statsmask],$
   colheader=latextableline(['','\emph{'+labels[where(indgen(nfiles) ne baseIndex2)]+'}']),format=formatstring)
   
;now all data are loaded (and figure generated if ps=1)
;If a report object is passed append the text, otherwise create it.
if n_elements(includeSections) ne 0 then begin
  createReport=(obj_valid(report) eq 0)
  if createReport then report=obj_new('lr',outfolder+path_sep()+outname+'_report.tex',title=title,$
                  author=author,level=sectionlevel)
  
  for j=0,n_elements(includeSections)-1 do begin ;add sections to report in the order listed in includeSections
    sectionIndex=includeSections[j] 
    
    newpage=1
    ;General description
    if sectionIndex eq 0 or sectionIndex eq -1 then begin
      if (sectionlevel eq report->get_lowestLevel()) then begin
        report->section,sectionlevel,'Samples '+outname,nonum=nonum
      endif else report->section,sectionlevel,outname,nonum=nonum,newpage=newpage
      report->append,'\emph{Results folder: '+outfolder+'}\\'
      report->append,'\emph{Outname: '+outname+'}'
      if n_elements(text) ne 0 then report->append,text
      report->list,'\emph{'+labels+'}: '+filelist,/nonum
    endif
    
    ;Raw data
    if sectionIndex eq 1 or sectionIndex eq -1 then begin  
        report->section,sectionlevel+1,'Scan Data',nonum=nonum,newpage=0
        parstable=makelatextable(string([scan_pars_m,partialStats_m]),rowheader=['Stylus radius ($\mu$m)',$
            'Full scan Length ($\mu$m)','N of points', 'X step ($\mu$m)','Vertical range (k\AA)','Roi Start ($\mu$m)',$
            'Roi End ($\mu$m)','Rms (k\AA, tilt removed)','R$_a$ (k\AA, t.r.)','TIR (k\AA, t.r.)'],$
            colheader=latextableline(['','\emph{'+labels+'}']))
        report->table,parstable,'p{4cm}'+strjoin(replicate('p{2cm}',nfiles)),caption='Scan parameters.' ;,autowidth='0.9\textwidth'
        report->figure,img_dir+path_sep()+outname+'_rawdata',caption='Raw data profile.',parameters='width=0.75\textwidth'
    endif 

    ;Leveling and profile stats
    if sectionIndex eq 2 or sectionIndex eq -1 then begin
      report->section,sectionlevel+1,'Profile analysis',nonum=nonum,newpage=newpage
      ;formatstring='(a,'+strjoin(replicate('f8.4',nfiles),',')+')'
      leveltable=makelatextable(string(level_m),rowheader=['a$_0$','a$_1$','a$_2$'],$
         colheader=latextableline(['','\emph{'+labels+'}']));,format=formatstring)
      report->table,leveltable,'p{1cm}'+strjoin(replicate('p{2cm}',nfiles)),$
          caption='Components removed for leveling (fit with 2$^\mathrm{nd}$ order polynomial), values in \AA:';,$
          ;autowidth='0.9\textwidth'
      report->figure,img_dir+path_sep()+outname+'_profile',caption='Profile after leveling.',parameters='width=0.75\textwidth'
      report->table,statstable,'p{3cm}'+strjoin(replicate('p{2cm}',nfiles)),caption='Statistics after leveling, values in $\mu$m,'+$
          ' skewness and kurtosis are dimensionless.';,autowidth='0.9\textwidth'
      report->figure,img_dir+path_sep()+outname+'_hist',caption='Distribution of heights for leveled data.',$
          parameters='width=0.75\textwidth'
    endif
   
   ;PSD average (includes calculation)
    if sectionIndex eq 3 or sectionIndex eq -1 then begin    
      ;check that all the psd are calculated over the same frequency points
      xchk=f_m[*,0]
      for i=1,nfiles-1 do begin
        if array_equal(f_m[*,i],xchk) ne 1 then begin 
          s= 'Frequency of '+string(i,format='(i2)')+'-th vector does not correspond to the 0th frequency.'
          s=s+ ' Average of PSD not performed'
          result=dialog_message(s)
          goto, exitPsdAvg
        endif
      endfor
      averagePSD=total(psd_m,2)/nfiles
      
      ;fit
      Result=PSD_FIT(xchk,averagepsd,avgPARS)
      fitavgpsd=avgpars
      
      if ps ne 0 then begin
        file_mkdir,img_dir
        SET_PLOT, 'PS'
        DEVICE, filename=img_dir+path_sep()+outname+'_avg_psd.eps', /COLOR,/encapsulated  
      endif else window,5
      plot,xchk*10000000.,averagePSD*10d-12,/xlog,/ylog,ytickformat='exponent',$
        xtitle='Frequency (mm^-1)',ytitle='Amplitude (um^3)',background=255,color=0,$
        title=titleString+'average PSD from '+string(nfiles,format='(i2)')+' profiles'
      oplot,xchk*10000000.,fitavgpsd[0]/(ABS(F)^fitavgpsd[1])*10d-12,color=colors[0],linestyle=2
      highlightLam=[0.01,0.03] ;lambda in mm^-1    
      for i =0,n_elements(highlightLam)-1 do begin
        oplot,[highlightLam[i],highlightLam[i]],10^!Y.Crange,color=6,linestyle=2
      endfor
      legend,['Average PSD','Fit'],position=12,color=[0,colors[0]]
      if ps ne 0 then begin
        DEVICE, /CLOSE 
        SET_PLOT_default
      endif
    
      report->section,sectionlevel+1,'Average PSD',nonum=nonum,newpage=newpage      
      report->figure,img_dir+path_sep()+outname+'_avg_psd',caption='Average PSD from \emph{'+strjoin(labels,'}, \emph{')+'}.'+$
              ' Fit parameters (according to $PSD(f)=K|f|^{-N}$): '+strjoin((['K=','N=']+string(fitavgpsd)),', '),$
              parameters='width=0.75\textwidth'
    endif
    exitPsdAvg:

    ;Differences raw
    if sectionIndex eq 4 or sectionIndex eq -1 then begin
      report->section,sectionlevel+1,'Differences between raw data',nonum=nonum,newpage=newpage
      formatstring='(a,'+strjoin(replicate('f8.4',nfiles),',')+')'  
      report->figure,img_dir+path_sep()+outname+'_differences_raw',caption=outname+': Differences in leveled profile' $
        +' with respect to \emph{'+labels[baseIndex]+'}',parameters='width=0.75\textwidth'
      report->figure,img_dir+path_sep()+outname+'_diffhist_raw',caption=outname+': Distribution of differences in heights'$
      +' with respect to \emph{'+labels[baseIndex]+'} (measured profiles).',parameters='width=0.75\textwidth'
      report->table,diffstatstable,'p{3cm}'+strjoin(replicate('p{2cm}',nfiles)),$
        caption=outname+': Statistics from differences with '+$
          'respect to \emph{'+legstr[baseIndex]+'} (measured profile), values in $\mu$m.';,autowidth='0.9\textwidth'
    endif
    
    ;Differences leveled
    if sectionIndex eq 5 or sectionIndex eq -1 then begin
      report->section,sectionlevel+1,'Differences between leveled data',nonum=nonum,newpage=newpage
      formatstring='(a,'+strjoin(replicate('f8.4',nfiles),',')+')'  
      report->figure,img_dir+path_sep()+outname+'_differences_lev',caption=outname+': Differences in leveled profile' $
        +' with respect to \emph{'+labels[baseIndex2]+'}',parameters='width=0.75\textwidth'
      report->figure,img_dir+path_sep()+outname+'_diffhist_lev',caption=outname+': Distribution of differences in heights'$
      +' with respect to \emph{'+labels[baseIndex2]+'} (leveled profiles).',parameters='width=0.75\textwidth'
      report->table,diff_roistatstable,'p{3cm}'+strjoin(replicate('p{2cm}',nfiles)),$
          caption=outname+': Statistics from differences with '+$
          'respect to \emph{'+legstr[baseIndex2]+'} (leveled profile), values in $\mu$m.';,autowidth='0.9\textwidth'
    endif

        ;PSD analysis and fit
    if sectionIndex eq 6 or sectionIndex eq -1  then begin
      report->section,sectionlevel+1,'PSD analysis',nonum=nonum,newpage=newpage
      report->figure,img_dir+path_sep()+outname+'_psd',caption='PSD after leveling, smoothing with Hann window and normalization.',$
              parameters='width=0.75\textwidth'
              ;normpars=[integral,var,1/integral*var]
              conversion=rebin([10.^(-4),10.^(-4),1.,10.^(-12),1.],5,nfiles)
      psdtable=makelatextable(string([normpars_m,fitpars_m]*conversion),$
            rowheader=['(Integrated PSD)$^{\frac{1}{2}}$ ($\mu$m)','$\sigma$ ($\mu$m)',$
            'Scaling factor','K ($\mu$m$^3$) from fit','N from fit'],$
            colheader=latextableline(['','\emph{'+labels+'}']))
      report->table,psdtable,'p{3cm}'+strjoin(replicate('p{2cm}',nfiles)),caption='Fit parameters for PSD '+$
          '(according to $PSD(f)=K|f|^{-N}$).';,autowidth='0.9\textwidth'
    endif
  endfor
  
  if createReport then begin
    report->compile,2,/pdf,/clean
    obj_destroy,report
  endif
endif

end

pro test_multi_psd

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
           
  multipsd,filelist,roi_um=roi_um,nbins=nbins,sectionlevel=sectionlevel,outname=outname,$
    report=report,author=author,title=title,outfolder=outfolder,labels=labels,/nonum,includeSections=[0,1,2,4,5,6]
end

test_multi_psd
  
end