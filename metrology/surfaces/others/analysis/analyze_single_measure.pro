pro analyze_single_measure,meas_file1,outfolder=outfolder,$
  outname=outname,report=report,ps=ps,npx=npx,npy=npy,$
  xgrid=xgrid,ygrid=ygrid,zraw=z_meas1,zflat=z_flatten,sectionlevel=sectionlevel,_extra=extra
  
;read a CMM datafile and create an output report, containing:
;resampling, leveling and basic statistics about raw(resampled) and leveled data.
;zflatten can be used to retrieve the flattened data.
;zraw can be used to retrieve the unleveled(resampled) data 
;npx and npy number of points in the grid (equal to npointsperside in measure - 2,
;to exclude the borders).

if n_elements (sectionlevel) eq 0 then  sectionlevel=0

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
;z_meas1 is the resampled plane image
;xraw_1,yraw_1 and z_raw1 are the points read from file
z_meas1=read_measure(meas_file1,$
  npx=npx,npy=npy,xgrid=xgrid1,ygrid=ygrid1,rawdata=raw1,_extra=extra)
  xgrid=xgrid1
  ygrid=ygrid1
xraw_1=raw1[*,0]  
yraw_1=raw1[*,1]
zraw_1=raw1[*,2]
if n_elements(ps) eq 0 then ps=0
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

;plane subtraction - fit and subtraction are performed on points from file xraw_1,yraw_1,zraw_1
;the result is then resampled in z_flatten
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
