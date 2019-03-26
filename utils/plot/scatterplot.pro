pro scatterPlot,X,Y,first=first,last=last,$
    _extra=e,square=square,plotrange=plotrange,$
    margin=margin,expansion=expansion,tif=tif,psfile=ps,$
    window=window,wxsize=wxsize,wysize=wysize

;+
; NAME:
; SCATTERPLOT
;
; PURPOSE:
; The routine create a scatter plot of Y vs X. It can generate output images.
;
; CATEGORY:
; Plot
;
; CALLING SEQUENCE:
;
; SCATTERPLOT, X, Y
;
; INPUTS:
; X and Y: vectors of points (same number of elements).
;
; OPTIONAL INPUTS:
; Parm2:  Describe optional inputs here. If you don't have any, just
;   delete this section.
; 
; KEYWORD PARAMETERS:
; 
; EXPANSION: factor for the expansion of axis ranges (it work only with /SQUARE,
;    and get the default from there if not provided).
; MARGIN: Add a margin to the range of the axis, can be a single value
;    or a 4 vector. The axis range used is returned in PLOTRANGE (that is an 
;    output, if you want to set the range, use XRANGE and YRANGE as in PLOT procedure).
; /SQUARE: create a square and isotropic plot.
; /FIRST, /LAST: highlight respectively the first and the last point.
; TIF, PS: If provided a tif/ps file is generated. TIF/PS is used as filename 
; (the extension is added by the program).
; WINDOW: number of the window used for the plot.
; WXSIZE,WYSIZE: size of the window.
;
; OPTIONAL OUTPUTS:
; PLOTRANGE: The axis range used for the plot. It is a 4-dim vector.
;
; DEPENDENCES:
; It uses the following routines and procedures:
; - newline, squareRange, maketif (kov) 
; - legend (Windt)
;
; EXAMPLE:
;   X=randomu(1,100)
;   Y=randomu(5,100)
;   scatterPlot,X,Y,margin=0.1,expansion=1.0,plotrange=plotrange,$
;   /square,psym=4,/first,/last,wxsize=640,wysize=640,$
;   title='100 random points',xtitle='randomu(1)',ytitle='randomu(5)'
;   print,'the range is: ',plotrange
;
; TODO:
;   - the legend is plotted with both 'first' and 'last' even if only one is set.
;   - extend expansion to work also for non square plot.
;   possible additions:
;   - highlighting more than one point at beginning and end.
;   - calculate some statistics.
;
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo, 17 Sep 2010.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden st., Cambridge, MA, 02138, US 
;   vcotroneo@cfa.harvard.edu
;   
;-

  USERSYM, [-2, 0, 2, 0, -2] , [0, 2, 0, -2, 0],thick=2
  if n_elements(window) eq 0 then window=0
  window,window,xsize=wxsize,ysize=wysize
  if n_elements(margin) eq 0 then pmargin=[0,0,0,0] $
  else begin 
    if n_elements(margin) eq 1 then pmargin=[-margin,margin,-margin,margin] $
    else if n_elements(margin) ne 4 then message,"the optional margin parameter "+$
    "can have 1 or 4 elements, it has "+strtrim(string(n_elements(margin)),2)+$
    " elements instead."+newline()+"margin= "+strtrim(string(margin),2)
  endelse
  
  if keyword_set(square) then begin
     plotrange=squarerange(X,Y,expansion=expansion)+pmargin
     isotropic=1
  endif else plotrange=[min(X),max(X),min(Y),max(Y)]+pmargin
  
  plot, X,Y,/ynozero,_strict_extra=e,isotropic=isotropic,$
        xrange=plotrange[0:1],yrange=plotrange[2:3]
  npoints=n_elements(X)
  if keyword_set(first) or keyword_set(last) then begin
    oplot, X[0:0],Y[0:0],color=50,psym=8
    oplot, X[npoints-1:npoints-1],Y[npoints-1:npoints-1],$
            color=250,psym=8
    legend,['First','Last'],color=[50,250],psym=[4,4]
  end
  
  if n_elements(tif) ne 0 then maketif,tif  
  if n_elements(ps) ne 0 then begin
    SET_PLOT, 'PS'
    DEVICE, filename=ps+'.eps', /COLOR,/encapsulated
    plot, X,Y,/ynozero,_strict_extra=e,isotropic=isotropic,$
          xrange=plotrange[0:1],yrange=plotrange[2:3]
    npoints=n_elements(X)
    if keyword_set(first) or keyword_set(last) then begin
      oplot, X[0:0],Y[0:0],color=50,psym=8
      oplot, X[npoints-1:npoints-1],Y[npoints-1:npoints-1],$
              color=250,psym=8
      legend,['First','Last'],color=[50,250],psym=[4,4]
    end
    DEVICE, /CLOSE 
    SET_PLOT_default
  endif
end

pro test_scatterplot
   X=randomu(1,100)
   Y=randomu(5,100)
   scatterPlot,X,Y,margin=0.1,expansion=1.0,plotrange=plotrange,$
   /square,psym=4,/first,/last,wxsize=640,wysize=640,$
   title='100 random points',xtitle='randomu(1)',ytitle='randomu(5)'
   print,'the range is: ',plotrange
end

test_Scatterplot

end