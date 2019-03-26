;2011/12/16 set of x and y data.
;TODO: want to be able to initialize by:
; 1) passing a filename, with files that can be in different formats (single or double column). 
; 2) passing x and y data directly
; 3) passing y data only, x is then a vector of generated indices
;

;The general idea is that for each transformation there is a procedure, that modifies the instance,
;   and a function, that returns a modified copy of the instance.
;   The code is written in the procedure with all parameter explicit for easier use. The function 
;     just creates a copy and call the procedure on it, then return it. Function parameters are specified by
;     extra (take attention to use ref_extra when proper).
;
; 


function xydata::selectRoi,data2,noplot=noplot,oplot=oplot,message=message
  ;interactively select a ROI. If NOPLOT is set, do not plot and uses the current window
  ; (useful if you want to plot more than one vector or additional objects).
  ;  Return a two vector with starting and ending index of the ROI. 
  if n_elements(message) ne 0 then message, message,/info
  return,GET_ROI((self.X).toarray(),(self.y).toarray())
  
end

pro xydata::level,coeff=coeff,degree=degree,partialdegree=partialdegree,$
  partialstats=partialstats,_ref_extra=extra
  x=self.getproperty(/x)  
  y=self.getproperty(/y) 
  self.setproperty,y=level(x,y,coeff=coeff,degree=degree,$
    partialdegree=partialdegree,partialstats=partialstats,_extra=extra)
  ;coeff=transpose(coeff)
end

function xydata::level,_ref_extra=extra,idstring=idstring
  ;  perform a fit of y vs x using a polynomial of degree DEGREE.
  ;KEYWORDS:
  ;  COEFF: (out) coefficients of the polynomial fit, according to P(x)=sum(coeff[i]*x^i) i=0,DEGREE
  ;  DEGREE: (in) degree of the polynomial for the fit
  ;  PARTIALDEGREE: (in) if provided, PARTIALSTATS is evaluated.
  ;      useful for comparison with the values from the machine (linear leveling <-> partialdegree=1).
  ;  PARTIALSTATS: (out) array [rms, ra, PV] for the residuals after the subtraction of the first PARTIALDEGREE degrees of the polynomial
  
  a=self.duplicate(idstring=idstring) 
  a.level,_strict_extra=extra
  return,a
end

PRO xydata::setProperty,x=x,y=y,idstring=idstring

    IF n_elements(idstring) ne 0 THEN self.idstring = idstring 
    IF n_elements(x) ne 0 THEN self.x = list(x,/extract)
    IF n_elements(y) ne 0 THEN self.y = list(y,/extract)

END

PRO xydata::GetProperty,x=x,y=y, npoints=npoints, offset=offset,idstring=idstring

    IF Arg_Present(npoints) THEN begin
        npoints = n_elements(self.getproperty(/x))
        if n_elements(Self.getproperty(/y)) ne npoints then message,'Non corresponding number of points in X and Y'
    endif
    IF Arg_Present(offset) THEN offset = self.offset ;self->getproperty(/offset)
    IF Arg_Present(idstring) THEN idstring = self.idstring ;self->getproperty(/idstring)
    IF Arg_Present(x) THEN x = (self.x).toarray() ;self->getproperty(/xdata)
    IF Arg_Present(y) THEN y = (self.y).toarray() ;self->getproperty(/ydata)

END

function xydata::GetProperty,x=x,y=y,npoints=npoints, offset=offset,idstring=idstring

    IF keyword_set(npoints) THEN self->getproperty,npoints=result
    IF keyword_set(offset) THEN self->getproperty,offset=result
    IF keyword_set(idstring) THEN self->getproperty,idstring=result
    if keyword_set(x) then self->getproperty,x=result
    if keyword_set(y) then self->getproperty,y=result
    return,result
    
END

pro xydata::readFromFile,filename,_extra=extra,cols=cols
   ;readcol,filename,x,y,_extra=extra
   data=read_datamatrix(filename,_extra=extra,/stripblank)
   if n_elements(cols) eq 0 then colind=[0,1] else colind=cols
   if n_elements(colind) ne 2 then message,'wrong number of columns selected.'
   x=double(data[colind[0],*])
   y=double(data[colind[1],*])
   self.setproperty,x=list(x,/extract),y=list(y,/extract)
end

;pro xydata::bin,binsize,binpoints=bp,cutlast=cutlast
;  ;given an x and y vector bins the data on intervals defined by binspoints.
;  ; binpoints is a vector with ninterval+1 elements, defining start and end point
;  ; of each interval. The endpoint is included in the interval.
;  ;If the last point in binpoints is not the last data point, the remaining data
;  ; points are included only if CUTLAST is not set.
;  
;  if n_elements(binsize) eq 0 then begin
;    if n_elements(bp) eq 0 then message,'either BINSIZE or BINPOINTS must be set!'
;    if n_elements(bp) lt 2 then message,'set at least two BINPOINTS' 
;  endif else if n_elements(bp) ne 0 then message, 'BINSIZE and BINPOINTS cannot be both set'
;  
;  if n_elements(binsize) ne 0 then begin
;    if n_elements(binsize) gt 1 then message,'BINSIZE must be a scalar (use BINPOINTS otherwise)!'  
;    if binsize le 0 then message,'BINSIZE must be positive'
;    n=n_elements(self.x)
;    if n eq 0 then message,'Empty X vector'
;    if binsize gt n then message,'BINSIZE is larger than the number of points'
;    ninter=fix(n/binsize)
;    binpoints=[0,(lindgen(ninter)+1)*binsize-1]
;  endif else binpoints=bp
;  
;  x=self.x
;  y=self.y
;  xout=[total(x[binpoints[0]:binpoints[1]])/(binpoints[1]-binpoints[0]+1)]
;  yout=[total(y[binpoints[0]:binpoints[1]])/(binpoints[1]-binpoints[0]+1)]
;  if n_elements(x) ne n_elements(y) then message,"X and Y don't have the same number of elements."
;  for i=1,n_elements(binpoints)-2 do begin
;    ;the denominator does not include +1 to account for the missing starting point
;    xout=[xout,total(x[binpoints[i]+1:binpoints[i+1]])/(binpoints[i+1]-binpoints[i])] 
;    yout=[yout,total(y[binpoints[i]+1:binpoints[i+1]])/(binpoints[i+1]-binpoints[i])]
;  endfor
;  if not keyword_set(cutlast) then begin
;    n=n_elements(x)
;    xout=[xout,total(x[binpoints[i]+1:n-1])/(n-binpoints[i]-1)]
;    yout=[yout,total(y[binpoints[i]+1:n-1])/(n-binpoints[i]-1)]
;  endif
;  self.x=xout
;  self.y=yout
;end

pro xydata::bin,binsize,binxsize=binxsize,binpoints=bp,binindex=bi,cutlast=cutlast,_extra=extra
  ;given an x and y vector bins the data on intervals defined by binspoints.
  ; binindex is a vector with ninterval+1 elements, defining start and end point
  ; of each interval. The endpoint is included in the interval.
  ;If the last point in binpoints is not the last data point, the remaining data
  ; points are included only if CUTLAST is not set.
  ;The binsize can be set by number of points with BINSIZE or by x size by BINXSIZE
  if n_elements(binsize)*n_elements(binxsize)ne 0 then message,'BINSIZE and BINXSIZE cannot be both set'
  if n_elements(binxsize) ne 0 then begin
    binvalues=fix(range(self.x,/size)/binxsize)
    bp=value_locate(self.x,b)
    ;attenzione se è decrescente, attenzione al numero di intervalli
  endif
  stop
  self.x=bin(self.x,binsize,binpoints=bp,binindex=bi,cutlast=cutlast,extra=extra)
  self.y=bin(self.x,binsize,binindex=bi,cutlast=cutlast)
end

function xydata::bin,binsize,idstring=idstring,_ref_Extra=extra

  result=self->duplicate(idstring=idstring)
  result->resample,binsize,_strict_extra=extra
  return,result
end

;PRO PlotParams::SetProperty, Color=color, Linestyle=linestyle
;
;   IF N_Elements(color) NE 0 THEN self.color = color
;   IF N_Elements(linestyle) NE 0 THEN self.linestyle = linestyle
;
;END

pro xydata::draw,_extra=extra,oplot=oplot
  self.getproperty,x=x,y=y
  if keyword_set(oplot) then $
  oplot, x,y,_extra=extra,color=cgcolor('black') $
  else plot, x,y,_strict_extra=extra, background=cgcolor('white'),color=cgcolor('black')
end

function xydata::duplicate,idstring=idstring
  if n_elements(idstring) ne 0 then id=idstring else id=self.idstring
  result=obj_new('xydata',self.x,self.y,idstring=id)
  return, result
end

pro xydata::resample,newx,extrapolate=extrapolate,range=range
  ; x can be provided as a vector (or xydata) NEWX or as a 3 elements vector RANGE with [x0,x1,npoints]
  ;if extrapolate is not set, points outside the x range of self are not considered.
  if n_elements(newx) and n_elements(range) ne 0 then message,"NEWX and RANGE are both set!"
  if n_elements(range) ne 0 then begin
     nx=vector(range[0],range[1],range[2])        
  endif else begin
    if size(newx,/type) eq 11 then begin 
      if obj_isa(newx,'xydata') then nx=newx.x else message,'Non valid object!' 
    endif else nx=newx
  endelse
  if keyword_set(extrapolate) eq 0 then begin
    xr=range(self.getproperty(/x))
    tmp=where(nx ge xr[0] and nx le xr[1],c)
    if c eq 0 then message,'Resampling range do not match data range and /EXTRAPOLATE is not set.'
    nx=nx[tmp]
  endif
  ny=interpol(self.getproperty(/y),self.getproperty(/x),nx)
  self.setproperty,x=nx,y=ny
end

function xydata::resample,newx,idstring=idstring,_ref_Extra=extra

  result=self->duplicate(idstring=idstring)
  result->resample,newx,_strict_extra=extra
  return,result
end

pro xydata::smooth,nwidth,xwidth=xwidth,_extra=extra
  
  if n_elements(nwidth) and n_elements(xwidth) ne 0 then message,"NWIDTH and XWIDTH are both set!"
  if n_elements(nwidth) ne 0 then begin
     if n_elements(nwidth) ne 1 then message,"unrecognized number of elements for NWIDTH"
     nw=nwidth        
  endif
  if n_elements(xwidth) ne 0 then begin
        if n_elements(xwidth) ne 1 then message,"unrecognized number of elements for NWIDTH"
        xw=xwidth        
        x=self->getproperty(/x)
        step=(x)[1]-(x)[0] ;
        nw[i]=fix(xw[i]/step+0.5)    ;number of points in the smoothing window
  endif 
  y0=smooth(self->getproperty(/y),nw,/edge_truncate,_extra=extra)
  self.setproperty,y=y0
end

function xydata::smooth,nwidth,_ref_extra=extra,idstring=idstring

  result=self->duplicate(idstring=idstring)
  result->smooth,nwidth,_strict_extra=extra
  return,result
end

pro xydata::extractXrange,xStart=xS,xEnd=xE,xindex=xindex
  ;+ 
  ;given an (optional) min and max xvalues in xstart,xend,
  ; return an xydata object with the elements in the (x)range 
  ; extracted from the vectors x and y.   
  ;-
  
  self->getproperty,x=x,y=y
  extractedY=extractXrange(x,y,extractedX,xStart=xS,xEnd=xE,xindex=xindex)
  self.setproperty,x=extractedX,y=extractedY

end

function xydata::extractXrange,_ref_extra=extra,idstring=idstring
  ;+ 
  ;given an (optional) min and max xvalues in xstart,xend,
  ; return an xydata object with the elements in the (x)range 
  ; extracted from the vectors x and y.   
  ;-
  result=self->duplicate(idstring=idstring)
  result->extractXrange,_strict_extra=extra
  return,result
end

pro xydata::multiply,factor,idstring=idstring
  ;+ 
  ; multiply the y points by a given factor  
  ;-
  
  self->getproperty,y=y
  if n_elements(factor) ne 1 and n_elements(factor) ne n_elements(self) then message,'wrong number of elements'
  self.setproperty,y=y*factor
  if n_elements(idstring) ne 0 then self.idstring=idstring

end

function xydata::multiply,factor,idstring=idstring
  result=self->duplicate()
  result->multiply,factor,idstring=idstring
  return,result
end

function xydata::fitcircles,roirange=roi,roiindex=roiindex,$
  outfile=outfile,xyrguess=xyrguess,residuals=res,yfactor=yf,$
  circle=circle,region=region,rms=rms
  
  ;returns the center coordinates and radius as a 3-elements vector.
  ;
  ;either one of ROI (2-vector with min and max x to select a roi) 
  ; or ROIINDEX (a vector of index selecting points) can be used to select
  ; a subset of data to be used for the fit
  ;OUTFILE is (not) used for the output
  ;XYRGUESS is used to provide a guess of X,Y and R, if not provided, default 
  ;  is calculated
  ;YFACTOR is a factor that multiply X to obtain Y 
  ; (e.g. X in mm, Y in um, YFACTOR=1000)
  ;RESIDUALS is the deviation of data from fit (as xydata), CIRCLE is 
  ; the fit (as xydata). Both have same units as self.
  ;If REGION is set, CIRCLE and RESIDUALS are built only on the subset of
  ;   points used for the fit, otherwise the entire range of self is used.
  ;The rms value calculated as sqrt(total(RES^2)/(N-1))
 
  circles=list()
  circles_res=list()
  if n_elements(roi) ne 0 and n_elements(roiindex) ne 0 then $
      message,'ROI and ROIINDEX cannot be both set!'
  if n_elements(yf) ne 0 then yfactor=yf else begin
     message,'No YFACTOR provided, set to 1.0',/info
     beep
     yfactor=1.0
  endelse
  if n_elements(roi) ne 0 then $
    datasel=self.extractxrange(xs=roi[0],xe=roi[1]) $ 
  else begin ;set to [0,0] to fit over the entire range
    if n_elements(roiindex) ne 0 then begin
        self->getproperty,x=x,y=y
        extractedX=x[roiindex]
        extractedY=y[roiindex]
        datasel=xydata(extractedX,extractedY)
    endif else datasel = self.duplicate() 
  endelse
     
  x=datasel.x
  y=datasel.y ;y is in datasel.y units (i.e. microns)
  c1=fit_circle(x,y/yfactor,xyrguess,tolerance=10^(-12),_extra=extra)
  
  if keyword_set(region) eq 0 then self->getproperty,x=x,y=y
  ycirclep=(c1[1]+sqrt(c1[2]^2-(x-c1[0])^2))*yfactor
  ycirclem=(c1[1]-sqrt(c1[2]^2-(x-c1[0])^2))*yfactor
  ;select the most appropriate half according to the lesser residuals
  if total((ycirclep-y)^2) lt total((ycirclem-y)^2) then $
      ycircle=ycirclep else ycircle=ycirclem
  ;ycircle is in microns
  circle=xydata(x,ycircle)
  res=y-ycircle
  rms=sqrt(total(res^2)/(n_elements(res)-1))
  if n_elements(outfile) ne 0 then writecol,outfile,x,y,ycircle,res,$
    header='X Y Y_FIT RESIDUALS'
  
  return,c1

end

pro xydata::join,xydata2,yShiftVec=yshift,roiindex=roiindex
  ;join two data set replacing the internal region of the first with the second.
  ;
  ;shifta il secondo array per farlo coincidere con il primo nel
  ;punto di indice joinIndex. L'entita' (media) dello shift puo' essere restituito
  ;in yshift.
  
  self.getproperty,y=data1,x=xdata
  tmp=xydata2.resample(xdata)
  data2=tmp.y
  yshift=[] ;[1.] ;in idl non si possono creare array vuoti.
  correctedData=data1
  ;scegli le regioni del secondo set di dati da rimpiazzare
  badpoints2=roiindex ;indgen(roiindex[1]-roiindex[0]+1)+roiindex[0]
  nbad=n_elements(badpoints2)
  badstart=badpoints2[0]
  badend=badpoints2[nbad-1]
  ;calcola yshift a seconda del caso
  ;two points joint
  shiftVec=(correctedData[badstart]-data2[badstart])+indgen(nbad)*$
  ((correctedData[badend]-data2[badend])-(correctedData[badstart]-data2[badstart]))/(nbad-1) 
  correctedData[badpoints2]=data2[badpoints2]+shiftVec
  self.setproperty,y=correctedData
  yshift=[yshift,total(shiftVec)/nbad]
end

function xydata::join,xydata2,_ref_extra=extra
  result=self->duplicate()
  result->join,xydata2,_strict_extra
  return,result
end

function xydata::_overloadSize
   return,SIZE(self->getproperty(/x), /DIMENSIONS)
end

pro xyData::write,filename,_extra=extra
  ;write X and Y vectors on a file. 
  
  x=self.x
  y=self.y
  writecol,filename,x,y
  
end


function xydata::sum,second,idstring=idstring,_extra=extra
  ;sum the two y data. Data are resampled (interpolated) on the first X data.
  
  self->getproperty,x=x1,y=y1
  if size(second,/type) eq 11 then begin
    if obj_isa(second,'xyData') then begin
      dummy=second.resample(self,_extra=extra)
      dummy->getproperty,x=x2,y=y2
      y1=extractxrange(x1,y1,xs=min(x2),xe=max(x2),x1) 
    endif else message, "don't know how to deal with the second argument"
  endif else begin
    y2=second
    if n_elements(y2) ne 1 and n_elements(y2) ne n_elements(y1) then message,'wrong number of elements for second arg.'
  endelse
  
  result=xydata(x1,y1+y2,idstring=idstring,_extra=_extra)
  return, result
end

function xydata::_overloadAsterisk,first, second
  ;essentially the same as multiply
  if size(first,/type) eq 11 then begin
    if not (obj_isa(first,'xydata')) then message,'not recognized type of object for first arg.'
    factor= second
  endif else begin
    if obj_isa(second,'xydata') then begin
    factor= first
    endif else message,'none of the argument is an xydata object' ;this should never happen
  endelse
  result=self->multiply(factor)
  return,result
end

function xydata::_overloadSlash ,xydata, factor
  ;essentially the same as multiply
  result=xydata->multiply(FIX(1,TYPE=size((xydata.y)[0],/type))/factor)
  return,result
end

function xydata:: _overloadCaret, xydata,exponent
  if n_elements(exponent) ne 1 then message, 'exponent must be a scalar'
  tmp=xydata.y^2
  xydata.y=tmp
  return, xydata
end

function xydata::_overloadPlus,first,second
  ;sum the two y data. Data are resampled (interpolated) on the first X data.
  if size(first,/type) eq 11 then begin
    if not (obj_isa(first,'xydata')) then message,'not recognized type of object for first arg.'
    v= second
  endif else begin
    if obj_isa(second,'xydata') then begin
    v= first
    endif else message,'none of the argument is an xydata object' ;this should never happen
  endelse 
  return,self->sum(v)
end

function xydata::_overloadMinus,first,second
  ;sum the two y data. Data are resampled (interpolated) on the first X data.
  return,self->sum(second*(-1))
end


FUNCTION xydata::_overloadHelp, Varname
   
   class = OBJ_CLASS(self)
   text = ['The '+Varname+' variable is an object of class '+class+'(heap ID: '+string(obj_valid(self,/get))+')']
   text = [text, 'npoints= '+string(self->getproperty(/npoints))]
   text = [text, 'x range= '+strjoin(string(range(self->getproperty(/x))))+' (span '+string(range(self->getproperty(/x),/size))+')']
   yrange=range(self->getproperty(/y),irange)
   text = [text, 'y range= '+strjoin(string(yrange))+' (span '+string(range(self->getproperty(/y),/size))+$
          ', min/max@'+strjoin(string(irange))+')']
   return, text
END

pro xydata::Cleanup
  ;ptr_free,self.x
  ;ptr_free,self.y<
end

function xydata::Init,x,y,idstring=idstring,_extra=extra
    if size(x,/type) eq 7 then begin
      if n_elements(idstring) ne 0 then self.idstring=idstring else self.idstring=file_basename(x)
      self.readfromfile,x,_extra=extra
    endif else begin
      npoints=n_elements(x)
      if n_elements(y) ne npoints then $
        message,'Different number of points for x ('+strtrim(string(npoints),2)+') and y('+strtrim(string(n_elements(y)),2)+')'
      ;self.x=ptr_new(x)
      ;self.y=ptr_new(y)
      self.setproperty,x=x,y=y
      if n_elements(idstring) ne 0 then self.idstring=idstring else self.idstring=''
    endelse
    return,1
end

pro xydata__define
struct={xydata,$
        filename:"",$
        idstring:"",$
        offset:0.0d,$
        x:list(),$
        y:list(), $
        npoints:0l,$
        INHERITS IDL_Object $
        }
end

function xydata_test
  x=findgen(10)
  y=x^2
  print,'x= ',x
  print,'y= ',y
  ;a=xydata(x,y)
  a=obj_new('xydata',x,y)
  print,'npoints:',a.npoints
  print,'plotting xy data...'
  a.draw
  b=a.extractxrange(xs=3,xe=6.5)
  b.draw,/oplot,color=cgcolor('red'),psym=4
  obj_destroy,b
  return,a
end

pro xydata_sum_test,a
  b=a+a
  c=a+5
  d=5+a
  e=d*2
  f=2*d
  help,a,b,c,d,e,f
end

pro xydata_test,a
  a=xydata_test()
  xydata_sum_test,a
end