function clip, data, min=mmin,max=mmax,clipvalue=vvalue,$
    nsigma=nsigma, refimage=refimage,mask=mask,summary=summary,torefimage=torefimage

;+
; NAME:
; CLIP
;
; PURPOSE:
; This function cut data in an array that are outside a given range. The limits can be
; provided in scalar or array form. The comparison can be performed on the data or on
; the deviation from a reference array. The elements outside the range can be replaced 
; by a user provided value (scalar or array).
;
; CATEGORY:
; Array
;
; CALLING SEQUENCE:
; Result = CLIP(Data)
;
; INPUTS:
; Data: A 2-D array
;
; KEYWORD PARAMETERS:
;   MIN, MAX: Values in Data lower than MIN or higher than MAX are clipped. 
;     MIN and MAX can be scalar, 2-elements vector, or 2d (NxM) arrays.
;     (maybe I meant: MIN and MAX can be scalar or arrays of the same shape as DATA"?) 
;     If one of them is not provided the clipping is not performed in that direction.
;   REFIMAGE: if provided, MIN and MAX refer to the range of the deviation of DATA from REFIMAGE.
;   CLIPVALUE can be a scalar, a two element vector, a NxM or NxMx2 array with values to substitute in
;     clipped points. If scalar or NxM array, the same value is used for points smaller than MIN
;     and higher then MAX, otherwise the two values are used respectively for points outside MIn and MAX.
;   TOREFIMAGE: set in alternative to CLIPVALUE. If set, the value of clipped points is changed to the 
;     corresponding pixel in REFIMAGE.
;   NSIGMA if it is set, data that are out of a NSIGMA interval of standard deviations from average 
;      are clipped (statistics are calculated on the deviation from REFIMAGE if provided,
;      on Data if REFIMAGE is not provided).  
;
; OUTPUT KEYWORD:
;   MASK: return a NxMx2 (for min and max) mask array with 1 in the position of modified values. 
;   TODO SUMMARY: return a string with the sumary of the clipping
;
; OUTPUTS:
;   This function return a copy of Data with values outside bounds clipped according to the options.
;
; DEPENDENCES:
;   The test procedure uses the following routines
;      From Coyote library: cgimage, cgcolorbar
;      From Vincenzo's personal library: range, setstandarddisplay, grid
;      From Windt: vector
;      
; PROCEDURE:
;   Min, Max and clipvalue are internally converted to 2-D array of the same size as Data.
;
; EXAMPLE:
;   e.g. DATA is a single dataset, AVG is the average of dataset.
;   to clip points more that 3 sigma from average:
;   RESULT=clip(DATA,refimage=AVG,nsigma=3,/TOREFIMAGE)
;   See tests below for more examples.
;
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo, 2001/05/04.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   

  ;Define variables:
  ;If REFIMAGE is not explicitly set, it is a copy of data all zeroed.
  ;DEVIATION is the difference between data and refimage.
  ;DATASIZE are the dimensions of the data
  if keyword_set(toRefImage) and n_elements(refimage) eq 0 then message,'You have set TOREFIMAGE, but REFIMAGE is not provided.'
  if n_elements(refimage) eq 0 then refimage=data*0
  deviation=data-refimage
  ;the clipping locations are calculated on refimage.
  avg=moment(deviation,sdev=sigma)  
  avg=avg[0]
  datasize=size(data,/dimension)
  
  ;min and max are created as matrices by the value in the input keywords MIN=mmin and MAX=mmax.
  ;after this block, min and max are compared to DEVIATION= DATA - REFIMAGE.
  if n_elements(nsigma) ne 0 then begin
  ;nsigma set
    if n_elements(mmin) ne 0 or n_elements(mmax) ne 0 then $
              message,'if NSIGMA is set, MIN and MAX must not be set'
      min=replicate(avg-nsigma*sigma,datasize)
      max=replicate(avg+nsigma*sigma,datasize)
  endif else begin 
  ;nsigma not set
    if n_elements(mmin) eq 0 then min=min(data) else min=mmin;+refimage
    if n_elements(min) eq 1 then min=replicate(min,datasize) else $
      if not(array_equal(size(min,/dimension) , datasize)) then message, 'wrong size for MIN array'
    if n_elements(mmax) eq 0 then max=max(data) else max=mmax;+refimage
    if n_elements(max) eq 1 then max=replicate(max,datasize) else $
      if not(array_equal(size(max,/dimension) , datasize)) then message, 'wrong size for MAX array'
  endelse
  if (size(max,/n_dimension) ne n_elements(datasize)) then message, 'something wrong in managing MAX'
  if (size(min,/n_dimension) ne n_elements(datasize)) then message, 'something wrong in managing MIN'
  
  ;define matrix with new values MINCLIP and MAXCLIP to replace clipped points in DATA. 
  ;vvalue is the argument CLIPVALUE.
  if keyword_set(toRefImage) then begin ;the image is clipped to REFIMAGE
       minclip=refimage
       maxclip=refimage
  endif else begin
    if n_elements(vvalue) eq 0 then begin 
       ;points are clipped to minimum and maximum accepted values
       minclip=min+refimage
       maxclip=max+refimage
    endif else if n_elements(vvalue) eq 1 then begin
       ;points are clipped to the same scalar value
       minclip=replicate(vvalue,datasize)
       maxclip=replicate(vvalue,datasize)
    endif else if n_elements(vvalue) eq 2 then begin
        ;the two elements define respectively values for min and max.
        minclip=replicate(vvalue[0],datasize)
        maxclip=replicate(vvalue[1],datasize)
    endif else begin
      ;vvalue is one (or two for min/max) set of points with the same shape of data.
      if size(vvalue,/n_dim) eq n_elements(datasize) then begin
        minclip=vvalue
        maxclip=vvalue
      endif else begin      
        if size(vvalue,/n_dim) ne n_elements(datasize)+1 then message,'wrong number of dimensions for CLIPVALUE array'  
        ;for now implement manually only the 1 and two dimensional cases.
        ;a generic case can be implemented with reform and rebin
        if size(vvalue,/dimensions) eq 2 then begin 
          minclip=vvalue[*,0]
          maxclip=vvalue[*,1]
        endif else begin
          if size(vvalue,/dimensions) eq 3 then begin
            minclip=vvalue[*,*,0]
            maxclip=vvalue[*,*,1]
          endif else message,'number of dimensions not implemented, see program comments.'
        endelse
      endelse
      endelse  
  endelse
  
  clippeddata=data
  himask=fix(data*0)
  lomask=fix(data*0)
  ihi=where(deviation gt max,c1)
  ilo=where(deviation lt min,c2)
  
  if c1 ne 0 then begin
    himask[ihi]=1
    clippeddata[ihi]=maxclip[ihi]
  endif
  if c2 ne 0 then begin
    lomask[ilo]=1
    clippeddata[ilo]=minclip[ilo]
  endif
  
  mask=[[[lomask]],[[himask]]]
 
  return,clippeddata
  
end


pro run_tests
 
     npx=100
     npy=100
     zr=[-0.4,1.0]
     xvec=vector(-10.,10,npx)
     yvec=vector(-10.,10,npy)
     xygrid=grid(xvec,yvec)
     x=xygrid[*,0]
     y=xygrid[*,1]
     data=reform((sin(sqrt((x^2+y^2)))/sqrt(x^2+y^2)),npx,npy)
      
    result=dialog_message('execute test 1?',/information,/cancel)
    set_plot_default
    
    if result eq 'OK' then begin
       setstandarddisplay,/notek
       window,0
       cgimage, data, position=plotpos, /Save,/scale,$
              /Axes,/keep_aspect,minus_one=0,$
              minvalue=zr[0],maxvalue=zr[1],$
              AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Function'},_extra=extra
       if n_elements(divisions) eq 0 then divisions=6
       if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
       cgcolorbar,/vertical,range=zr,divisions=divisions,$
              format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
              ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
       
       ;test 1
       print,'clip to a minvalue of -0.1 and a max value of 0.4'
       cdata=clip(data,min=-0.1,max=0.4)
       window,1
        setstandarddisplay,/notek
       cgimage, cdata, position=plotpos, /Save,/scale,$
              /Axes,/keep_aspect,minus_one=0,$
              minvalue=zr[0],maxvalue=zr[1],$
              AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'clip to a minvalue of -0.1 and a max value of 0.4'},_extra=extra
       if n_elements(divisions) eq 0 then divisions=6
       if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
       cgcolorbar,/vertical,range=zr,divisions=divisions,$
              format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
              ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
    endif      
    
     ;test 2
    result=dialog_message('execute test 2?',/information,/cancel)
    if result eq 'OK' then begin
       data2=data+randomu(0,size(data,/dimension))/10.
       data2[50,20]=data[50,20]+range(data,/size)
       print,'data + noise and one artificial outlier, clip to data at three sigma'
       cdata=clip(data2,nsigma=3,refimage=data,/toref)
       ;zr=range([data,data2,cdata])
        window,1
       ;noisy data
        setstandarddisplay,/notek
       cgimage, data2, position=plotpos, /Save,/scale,$
              /Axes,/keep_aspect,minus_one=0,$
              minvalue=zr[0],maxvalue=zr[1],$
              AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Data with noise'},_extra=extra
       if n_elements(divisions) eq 0 then divisions=6
       if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
       cgcolorbar,/vertical,range=zr,divisions=divisions,$
              format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
              ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
       
       ;noise only
         window,2
        setstandarddisplay,/notek
       cgimage, data2-data, position=plotpos, /Save,/scale,$
              /Axes,/keep_aspect,minus_one=0,$
              minvalue=zr[0],maxvalue=zr[1],$
              AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Noise'},_extra=extra
       if n_elements(divisions) eq 0 then divisions=6
       if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
       cgcolorbar,/vertical,range=zr,divisions=divisions,$
              format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
              ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
        
        ;clipped data
        window,3
        setstandarddisplay,/notek
       cgimage, cdata, position=plotpos, /Save,/scale,$
              /Axes,/keep_aspect,minus_one=0,$
              minvalue=zr[0],maxvalue=zr[1],$
              AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Data after clipping'},_extra=extra
       if n_elements(divisions) eq 0 then divisions=6
       if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
       cgcolorbar,/vertical,range=zr,divisions=divisions,$
              format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
              ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided 
       
       ;noise after clipping              
       window,4
        setstandarddisplay,/notek
       cgimage, cdata-data, position=plotpos, /Save,/scale,$
              /Axes,/keep_aspect,minus_one=0,/noint,$
              minvalue=zr[0],maxvalue=zr[1],$
              AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:'Noise after 3 sigma clip to data.'},_extra=extra
       if n_elements(divisions) eq 0 then divisions=6
       if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
       cgcolorbar,/vertical,range=zr,divisions=divisions,$
              format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle;,_extra=extra
              ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
              
    endif
end

run_tests     

end