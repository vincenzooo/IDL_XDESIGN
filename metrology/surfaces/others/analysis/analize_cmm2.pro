pro analize_cmm2,file,npx,npy

setstandarddisplay
npx=21
npy=22
ps=1
nbins=100
outfolder='E:\work\work_ratf\run2b\2011_03_07\latact_test'+path_sep()+'latact_out'
img_dir=outfolder

report=obj_new('lr',outfolder+path_sep()+'report.tex',title='Lateral actuator',$
                author=author,level=sectionlevel,/toc)

report->section,0,'Single data files'
outname='0V'
file1='E:\work\work_ratf\run2b\2011_03_07\latact_test\Moore-Scan-Vert-surface-0V.dat'
analyze_single_measure,file1,outfolder=outfolder,$
  outname=outname,report=report,ps=ps,npx=npx,npy=npy,$
  xgrid=xgrid,ygrid=ygrid,zraw=z_meas1,zflat=zflatten1,sectionlevel=1

outname='60V'
file2='E:\work\work_ratf\run2b\2011_03_07\latact_test\surface-4x-Act15-60V.dat'
analyze_single_measure,file2,outfolder=outfolder,$
  outname=outname,report=report,ps=ps,npx=npx,npy=npy,$
  xgrid=xgrid,ygrid=ygrid,zraw=z_meas2,zflat=zflatten2,sectionlevel=1
  
report->section,0,'Differences'
report->append,'In this section the difference between different unleveled files'


diff21=z_meas2-z_meas1
diff21string=' '+file_basename(file2)+' - '+file_basename(file1)
barrange=range(diff21)

;differences 2-1
;plot of raw data
loadct,13
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'diff21.eps', /COLOR,/encapsulated  
endif else window,1,title='4: difference'+diff21string
TVimage, diff21, Margin=0.2, /Save, /White, /scale,$
  /Axes,/keep_aspect_ratio,xrange=range(xgrid),yrange=range(ygrid),$
  AXKEYWORDS={CHARSIZE:1.5, XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'difference'+diff21string}
FSC_colorbar,/vertical,range=barrange*1000.,title='Z (um)'
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif
report->figure,fn(img_dir+path_sep()+'diff21',/u),$
  caption='difference '+diff21string,$
  parameters='width=0.75\textwidth'

;statistics
outvars=[0,1,2,3,4,5]
statsheader=histostats(/header,outvars=outvars)
if ps ne 0 then begin
  file_mkdir,img_dir
  SET_PLOT, 'PS'
  DEVICE, filename=img_dir+path_sep()+'diffhist21.eps', /COLOR,/encapsulated  
endif else window,1,title='Difference'+diff21string
diff21Stats=histostats(diff21*1000.,nbins=nbins,$
  /normalize,min=barrange[0]*1000,max=barrange[1]*1000,$
  outvars=outvars,locations=diff21Loc,hist=diff21hist)
if ps ne 0 then begin
  DEVICE, /CLOSE 
  SET_PLOT_default
endif
;multi_plot,[[diff21Loc],[diff31Loc],[diff32Loc]],$
;           [[diff21hist],[diff31hist],[diff32hist]],$
;           background=fsc_color('white'),psym=10,$
;           legend=[diff21string,diff31string,diff32string],$
;           psfile=img_dir+path_sep()+'diffhist.eps',$
;           yrange=[0,max([[diff21hist],[diff31hist],[diff32hist]])*1.1]
report->figure,fn(img_dir+path_sep()+'diffhist21',/u),$
  caption='difference between raw data, statistics in table \ref{tab:diffstats}.',$
  parameters='width=0.75\textwidth'
           
diffStats=makelatextable([string(diff21Stats,format='(g0.3)')],$
          colheader=latextableline(['',diff21string]),$
          rowheader=statsheader)
report -> table,diffStats,strjoin(replicate('p{3cm}',5)),$
          caption='Statistics for difference (in um).\label{tab:diffstats}'

obj_destroy,report

end