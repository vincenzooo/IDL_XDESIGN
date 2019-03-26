
;2012/05/16 synchronized with multipsd_v2
;TODO: adjust level in a way to return the legendre coefficients instead of the polynomial fit coefficients.
;  In alternative, in multipsd derive the Legendre coefficients from the polynomial coeff. by means of a routine
;  poly2legendre and write them in a table.
;TODO: check the input keyword parameters, at the moment they must be present and the default value is provided by
;  multipsd, it would be better to set to default here, but you must be sure that the default value is not set and 
;  returned in the caller routine.
;+
; NAME:
; EXTRACTPSD
;
; PURPOSE:
; This procedure performs the analysis of a single dektat file and return the
; values in variables. For processing more than one file, or generating plots
; and outputs, use MULTIPSD (that calls this procedure EXTRACTPSD).
;
; CATEGORY:
; Dektat
;
; CALLING SEQUENCE:
; EXTRACTPSD, Filename
;
; INPUTS:
; Filename:  The dektat csv (comma separated values) data file
; 
; INPUT KEYWORD PARAMETERS:
; ROI_UM: 2-elements array with start and end of the region of interest (values in um).
; NBINS: number of bins to use for histogram generation.
; XOFFSET: 
;
; OPTIONAL OUTPUTS:
; X_ROI_OUT, Y_ROI_OUT: vectors with the coordinates of points included in ROIs. 
; XRAW, YRAW: complete coordinates (x is corrected by the offset)
; FREQ: frequencies over which the PSD is calculated (in prof2psd)
; PSD: Corresponding PSD value (in prof2psd)
; ZLOCATIONS
; ZHIST
; LEVEL_COEFF: coefficients from 2nd-degree polinomial fit. If l=level_coeff,
;   P(x)=l[0]+l[1]*x+l[2]*x^2
; SCAN_PARS: array containing the scan parameters 
;   [stylus_rad(um),scanlen(um),npoints,step_um(um),zrange(kAngstrom),roi_um[0](um),roi_um[1](um)]
;   as read from the dektat data file.
; NORMPARS: Normalization parameters for PSD fit: [sqrt(integral),sqrt(var),var/integral],
;   where integral is the integral of PSD over the whole (negative and positive) frequency range,
;   var is the variance of the height distribution.
; FITPSD: 1-D array of fit parameters: PARS(0)=K_n, PARS(1)=N with PSD(f)=K_n/(ABS(f)^N)
; FITRANGE: 2 elements vector with the range of frequency to be used for power-law fit
; PSDWINDOW: string to set the type of window for psd. At the moment only 'hanning' is an acceptable value.
; LEVELPARTIAL:
; PARTIALSTATS:
;
; EXTERNAL DEPENDENCIES:
; range, file_extension, readnamelistvar, newline, stripext, histostats
; vector, prof2psd
;
;
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo, 18 Jan 2011.
;   2011/25/02: renamed variables using keyword arguments names.
;-

function level2,y,coeff=coeff
  ;remove piston, tilt and sag
  ;(i.e. mean, line and second order legendre polynomial)
  ;TODO: extend to a generic grade using recursion formola to generate npolinomyal
  
  grade=3
  N=n_elements(Y)
  yres=Y
  x=vector(-1.d,1.d,n) ;xvector
  L=max(x,/nan)-min(x,/nan)
  coeff=fltarr(grade)
  
  ;legendre normalized polynomials
  Leg0=sqrt(1.d/2)
  Leg1=x*sqrt(3.d/2)
  Leg2=(3.*x^2-1)/2*sqrt(5.d/2)
  
  a0=total(y*Leg0,/nan)*L/n
  yres=y-a0*Leg0
  
  a1=total(y*Leg1,/nan)*L/n
  Yres=Yres-a1*Leg1

  a2=total(y*Leg2,/nan)*L/n
  sag=a2*Leg2
  Yres=Yres-sag
  
  coeff=[a0,a1,a2]
  
  return, Yres

end

function level,x,y,coeff=coeff,degree=degree,partialdegree=partialdegree,partialstats=partialstats
;  perform a fit of y vs x using a polynomial of degree DEGREE.
;KEYWORDS:
;  COEFF: (out) coefficients of the polynomial fit, according to P(x)=sum(coeff[i]*x^i) i=0,DEGREE
;  DEGREE: (in) degree of the polynomial for the fit
;  PARTIALDEGREE: (in) if provided, PARTIALSTATS is evaluated.
;      useful for comparison with the values from the machine (linear leveling <-> partialdegree=1).
;  PARTIALSTATS: (out) array [rms, ra, PV] for the residuals after the subtraction of the first PARTIALDEGREE degrees of the polynomial

if n_elements(degree) eq 0 then degree=2
coeff = poly_fit(X, Y, Degree,yfit=yfit)

if n_elements(partialdegree) ne 0 then begin
  pc=coeff[0:partialdegree]
  reconstructed=dblarr(n_elements(x))
  for i=0,partialdegree do begin
    reconstructed=reconstructed+pc[i]*x^i
  endfor
  pr=reconstructed-y
  rms=sqrt(total(pr^2,/nan)/n_elements(pr))
  ra=total(abs(pr),/nan)/n_elements(pr)
  pv=range(pr,/size)
  partialstats=[rms,ra,pv]
endif

return,y-yfit ;return residuals
end

pro extractpsd,filename,roi_um=roi_um,nbins=nbins,$ 
    x_roi_out=X_ROI_OUT,y_roi_out=Y_ROI_OUT,freq=freq,psd=psd,zlocations=zlocations,zhist=zhist,$ 
    xraw=xraw,yraw=yraw,level_coeff=level_coeff,scan_pars=scan_pars,$
    normpars=normpars,fitpsd=fitpsd,fourierwindow=fourierwindow,xoffset=xoffset,$
    levelPartial=levelPartial,partialStats=partialStats,fCut=fCut
    
;xoffset in um
;levelPartial contains the partial level
ext=file_extension(filename,basename)
folder=file_dirname(filename)

readcol,filename,xx,yy,skip=reader.skip,delimiter=reader.delimiter

;read scan parameters and load them in the array scan_pars:
;;scan length
tmp=readnamelistvar(filename,'Sclen',separator=',')
tmp=strsplit(tmp,',',/extract)
scanlen=float(tmp[0])
;if strtrim(tmp[1],2) ne 'um' then message, 'Unrecognized unit of measure for scan lenght, unit: '+strtrim(tmp[0],2)
;;npoints
npoints=long(readnamelistvar(filename,'NumPts',separator=','))
;; vertical range
zrange=strsplit(readnamelistvar(filename,'Mrange',separator=','),/extract) ;to remove unit of measure
zrange=float(zrange[0])
;;step size
step_um=float(readnamelistvar(filename,'Hsf',separator=','))
;;stylus radius
stylus_rad=float(readnamelistvar(filename,'Stylus Type,Radius',separator=':'))
if step_um*npoints ne  scanlen then begin
  msg='Scan lenght, npoints and step length do not agree:'+newline()+$
      'Scan Len: '+strtrim(string(scanlen))+newline()+$
      'Step Len: '+strtrim(string(step_um))+newline()+$
      'Npoints: '+strtrim(string(npoints))+newline()+$
      '-----------------------------'
   message,msg
endif
scan_pars=[stylus_rad,scanlen,npoints,step_um,zrange,roi_um[0],roi_um[1]]

;adjust coordinates and convert all lenghts in angstrom
xraw=double(xx)+xoffset ;in um
yraw=double(yy) ;in Angstrom
xraw=xraw[0:npoints-1]
yraw=yraw[0:npoints-1]
xraw=xraw*10000
xstep=step_um*10000.
nyRange=[1./(Npoints*xstep),1./(2*xstep)]*10^7 ;Nyquist range in mm^-1

;select the ROI, at the end X_ROI_OUT and Y_ROI_OUT will contain the values inside the roi, npoints_roi the number of points in ROI.
if n_elements(roi_um) eq 2  then begin
  roi_start=value_locate(xraw,(roi_um[0]+xoffset)*10000.)+1
  roi_end=value_locate(xraw,(roi_um[1]+xoffset)*10000.)
  roi_start= (npoints-2 < roi_start)
  roi_end=(0>roi_end)
  X_ROI_OUT=xraw[roi_start:roi_end]
  Y_ROI_OUT=yraw[roi_start:roi_end]
  npoints_roi=roi_end-roi_start+1
  scanlen=(roi_um[1]-roi_um[0])*10000.
  print,'Selected ROI: ['+strtrim(string(roi_um[0]))+'-'+strtrim(string(roi_um[1]))+' um]'
  print,'points :'+strtrim(string(roi_start))+'-'+strtrim(string(roi_end))+']'
endif else begin
  print,'No ROI selected'
  X_ROI_OUT=xraw
  Y_ROI_OUT=yraw
  npoints_roi=npoints
endelse

;leveling
Y_ROI_OUT=level(x_roi_out,Y_ROI_OUT,coeff=level_coeff,degree=2,partialdegree=levelPartial,partialstats=partialstats) ;level(Y_ROI_OUT,coeff=level_coeff)
level_coeff=reform(level_coeff,3)
writecol,stripext(filename,/full)+'_level.dat',X_ROI_OUT,Y_ROI_OUT,header='X(um) Y(A)_leveled_data'
print,'min, max, PV',min(Y_ROI_OUT),max(Y_ROI_OUT),max(Y_ROI_OUT)-min(Y_ROI_OUT)

if n_elements(fourierwindow) ne 0 then begin 
  if strlowcase(fourierwindow) eq 'hanning' then hanning=1
endif
psd=prof2psd(X_ROI_OUT,y_ROI_OUT,f=freq,/positive_only,hanning=hanning)

;;histogram of heights
zstats=histostats(Y_ROI_OUT,title='Distribution of heights (A)',$
    nbins=nbins,$
    background=255,color=0,position=12,locations=zlocations,$
    hist=zhist,xtitle='z (A)',ytitle='Fraction',/normalize,$
    min=min,max=max,/noplot)

;psd
;normalization
if arg_present(normpars) ne 0 then begin
  f2=freq
  psd2=psd
  integral = 2*INT_TABULATED( F2,psd2,/sort ) ;the factor 2 to include the negative frequencies 
  var=zstats[7]
  print,'integralpsd=',integral,' variance=',var
  psd=psd*var/integral
  normpars=[sqrt(integral),sqrt(var),var/integral]
end

if arg_present(fitpsd) ne 0 then begin
  if n_elements(fCut) ne 0 then fitrange=[min(f2)*4,max(f2)/4] 
  Result=PSD_FIT(freq,psd,PARS,range=fitrange)
  fitpsd=pars
end

print,"Frequency in the range: ",min(freq),'-',max(freq)

end

