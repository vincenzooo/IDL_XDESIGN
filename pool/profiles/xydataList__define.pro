;2012/10/02 from profiles_characterization in nanovea_characterization

;FIXME: x coordinates are ignored in averaging (and probably everywhere), 
;   it works only if vectors have the same x coordinates.
;FIXME: bug in RESAMPLING routine  
; ;the following doesn't work for some bug in the resampling routine
; 
  ;datalist=xydatalist(filegroups)
  ;datalist.smooth,nsm
  ;datalist.write,'profiles_sm.txt'
  ;for i=0,n_elements(datalist)-1 do begin
  ;  (datalist[i]).write,fnaddsubfix(filegroups[i],'_sm'),x,y
  ;endfor
  ;return,datalist

pro xydatalist::getproperty,xlist=xlist,ylist=ylist,datalist=datalist,nscans=nscans
  
  nscans=n_elements(self.datalist)
  IF Arg_Present(xlist) THEN begin
    xlist=list()
    for i= 0,nscans-1 do begin
      tmp=((self.datalist)[i]).x
      xlist.add,tmp
    endfor
  endif  
  
  IF Arg_Present(ylist) THEN begin
    ylist=list()
    for i= 0,nscans-1 do begin
      tmp=((self.datalist)[i]).y
      ylist.add,tmp
    endfor
  endif  
  
  IF Arg_Present(datalist) THEN datalist = self.datalist[*]
end

pro xydatalist::add,item
  if not(OBJ_ISA(item, 'xydata')) then message,'Only xydata objects can be added to xydatalist!'
  (self.datalist).add,item
end

function xydatalist::duplicate
  result=xydatalist()
  ;if n_elements(idstring) ne 0 then id=idstring else id=self.idstring
  for i=0,n_elements(Self.datalist)-1 do begin
     result.add,((self.datalist)[i])->duplicate()
  endfor
  return, result
end

pro xydatalist::resample,newx,index=index,range=range
  
  dummy=where([n_elements(newx),n_elements(range),n_elements(index)] ne 0, c)
  if c gt 1 then message," only one between INDEX, NEWX and RANGE can be set!"
  if c eq 0 then begin
    ;determine best index
    ;2013/03/14 before now it was simply selecting the index 0, with:
    ;    ind=0 ;temporary easy solution
    ;    nx=((self.datalist)[ind]).x
    ; I add a 'smart' selection, the x vector is the one with more points
    ;   in the overlapping region.
    
    tmp=self->duplicate()
    ;determine overlapping range
    tmp->getproperty,xlist=xlist
    xrange=[min(xlist[0]),max(xlist[0])]
    for i=1,n_elements(xlist)-1 do begin
      xrange[0]=max([xrange[0],min(xlist[i])])
      xrange[1]=min([xrange[1],max(xlist[i])])
    endfor
    
    n=-1
    for i=0,n_elements(xlist)-1 do begin
      ind=where(xlist[i] gt xrange[0] and xlist[i] lt xrange[1],count)
      if count gt n then nx = (xlist[i])[ind]
    endfor
    
  endif else if n_elements(newx) ne 0 then nx=newx 
  
  for i=0,n_elements(self.datalist)-1 do begin
      tmp=(self.datalist)[i]
      tmp.resample,nx,range=range
      ((self.datalist)[i])=tmp
  endfor
  
end

function xydatalist::resample,newx,_extra=_ref_extra
  result=self->duplicate()
  result->resample,newx,_strict_extra=extra
  return,result
end

pro xydatalist::multiply,factor,idstring=idstring
  ;+ 
  ; multiply the y points by a given factor  
  ;-
  
  self->getproperty,nscans=nscans
  for i=0,nscans-1 do begin
    (self.datalist)[i]=((self.datalist)[i])*factor
  endfor
  if n_elements(idstring) ne 0 then self.idstring=idstring

end

function xydatalist::multiply,factor,idstring=idstring
  result=self->duplicate()
  result->multiply,factor,idstring=idstring
  return,result
end


function xydatalist::average,err=xyerr,x=newx,index=ind,range=range
  ; average a list of vectors, vectors are resampled before the calculation.
  ;index indicates which vector to use for the x
  if n_elements(newx) eq 0 and n_elements(ind) eq 0 and n_elements(range) eq 0 then index=0 $
    else if n_elements(ind) eq 1 then index=ind else message,'INDEX must be a scalar.'
  self->getproperty,nscans=nscans
  if nscans eq 1 then begin
      message,'Only one scan, return the same scan as average!',/info
      beep
      xyerr=xydata(((self.datalist)[0]).x,(((self.datalist)[0]).x)*0)
      return,(self.datalist)[0]
  endif
  tmp=self.resample(newx,index=index,range=range)
  avg=tmp[0]
  nscans=tmp.nscans
  if nscans gt 1 then begin
    for i=1,nscans-1 do begin
      avg=avg+tmp[i]
    endfor
    avg=avg/nscans
  endif
  
  if arg_present(xyerr) then begin
    self->getproperty,ylist=ydata
    yerr=avg.y*0
    for i=0,nscans-1 do begin
      yerr=yerr+((ydata[i]-avg.y)^2)
    endfor
    yerr=sqrt(yerr/nscans)
    ;if nscans ne 1 then yerr=sqrt(yerr/(nscans-1)) else yerr=yerr*0
  xyerr=avg.duplicate()
  xyerr.y=yerr
  endif
  
  obj_destroy,tmp
  return,avg
end

;pro xydatalist::load,listoffiles,_extra=extra
;
;  nfiles=n_elements(listoffiles)
;  for i=0,nfiles-1 do begin
;    tmp=xydata(listoffiles[i],_extra=extra)
;    (self.datalist).add,tmp
;  endfor
;end

pro xyDataList::extractxrange,xStart=xS,xEnd=xE,xindex=xi
  ;xstart and xend can be passed as scalar or arrays.
  self->getproperty,nscans=nscans
  if n_elements(xs) eq 1 then xstart=replicate(xs,nscans) else $
    if n_elements(xs) ne nscans then message, 'number of elements in xstart not matching number of scans.'
  if n_elements(xe) eq 1 then xend=replicate(xe,nscans)else $
    if n_elements(xe) ne nscans then message, 'number of elements in xend not matching number of scans.'
  if arg_present(xi) ne 0 then xi=list()
  for i=0,nscans-1 do begin
    ((self.datalist)[i]).extractXrange,xStart=xStart[i],xEnd=xEnd[i],xindex=xindex
    if arg_present(xi) ne 0 then xi.add,xindex
  endfor
end

function xyDataList::extractXrange,_ref_extra=extra
  a=self.duplicate() 
  a.extractXrange,_extra=extra
  return,a
end

;function xyDataList::level,_ref_extra=extra
;  xlist=self.xlist
;  ylist=self.ylist
;  ;level each vector in a list of vectors
;  nvec=n_elements(ylist)
;  vlev=list()
;  for i=0,nvec-1 do begin
;    vlev.add,level(xlist[i],ylist[i],degree=degree,_extra=extra)
;  endfor
;  return,vlev
;end


pro xyDataList::level,coeff=coeff,degree=deg,$
  partialdegree=pd,partialstats=partialstats,_ref_extra=extra
  ;degree can be a vector, as well as partialdegree
  ; as a consequence, coeff and partialstats must be lists
  ; (not sure this is a good idea. Is there a case in which one wants
  ; really to have a vector for degree? Also in which cases you want to use
  ; partialdegree?).
  
  self->getproperty,nscans=nscans
  ;assign and check partialdegree
  if n_elements(pd) ne 0 then begin
     partialstats=list()
     if n_elements(pd) ne 1 then begin
        if n_elements(pd) ne nscans then $
          message,'Wrong number of elements for partialdegree.'
        partialdegree=pd
     endif else partialdegree=replicate(pd,nscans)
  endif 
  ;assign and check degree
  if n_elements(deg) ne 0 then begin
     coeff=list()
     if n_elements(deg) ne 1 then begin
        if n_elements(deg) ne nscans then $
          message,'Wrong number of elements for degree.'
        degree=deg
     endif else degree=replicate(deg,nscans)
  endif   
  
  for i=0,nscans-1 do begin
    if n_elements(degree) ne 0 then dd=degree[i]
    if n_elements(partialdegree) ne 0 then ppd=partialdegree[i]
    ((self.datalist)[i]).level,coeff=c,degree=dd,$
    partialdegree=ppd,partialstats=ps,_extra=extra
    coeff.add,c
    if n_elements(partialdegree) ne 0 then partialstats.add,ps
  endfor
end

function xyDataList::level,_ref_extra=extra
  a=self.duplicate() 
  a.level,_extra=extra
  return,a
end

pro xyDataList::smooth, nwidth,_ref_extra=extra
    
  self->getproperty,nscans=nscans
  for i=0,nscans-1 do begin
    ((self.datalist)[i]).smooth,nwidth,_extra=extra
  endfor
end

function xyDataList::smooth,nwidth,_ref_extra=extra

  result=self->duplicate()
  result->smooth,nwidth,_strict_extra=extra
  return,result
end

;function xyDataList::psd,freqlist=freqlist
;  xlist=self.xlist
;  ylist=self.ylist
;  nvec=n_elements(ylist)
;  x0=xlist[0]
;  freqlist=list()
;  psdlist=list()
;  for i=0,nvec-1 do begin
;    if not (array_equal(x0, xlist[i])) then begin
;      beep
;      message,'non corresponding x for vector '+string(i),/info
;    endif
;    psd=prof2psd(xlist[i],ylist[i],f=freq,/positive_only,/hanning)
;    ;psd normalization
;    f2=freq
;    psd2=psd
;    integral = 2*INT_TABULATED( F2,psd2,/sort ) ;the factor 2 to include the negative frequencies 
;    ;;histogram of heights
;    zstats=histostats(Ylist[i],/noplot)
;    var=zstats[7]
;    print,'integralpsd=',integral,' variance=',var
;    psd=psd*var/integral
;    normpars=[sqrt(integral),sqrt(var),var/integral]
;    psdlist.add,psd
;    freqlist.add,freq
;  endfor
;  
;  return,PSDLIST
;end

pro xyDataList::draw,_extra=extra
    Self->getproperty,nscans=nscans
    col=plotcolors(nscans-1)
    (self[0]).draw,color=cgcolor('black'),background=cgcolor('white'),_extra=extra
    if nscans gt 1 then begin
      for i=1,nscans-1 do begin
         (self[i]).draw,color=col[i-1],/oplot,_extra=extra
      endfor
    endif    
end

function xydataList::sum,value,idstring=idstring,_extra=extra
  ;sum the two y data. Data are resampled (interpolated) on the first X data.

  self->getproperty,nscans=nscans
  result=self->duplicate()
  for i=0,nscans-1 do begin
    result[i]=result[i]+value
  endfor
  return, result
end

function xydatalist::_overloadPlus,first,second
  if size(first,/type) eq 11 then begin
    if (obj_isa(first,'xydatalist')) then begin
      result=self->sum(second)
    endif else begin
      if not size(second,/type) eq 11 then message,'none of the arguments is a xydatalist object'
      result=second.sum(first)
    endelse
  endif else begin
    result=second.sum(first)
  endelse 
  return,result
end

function xydatalist::_overloadAsterisk,first,second
  if size(first,/type) eq 11 then begin
    if (obj_isa(first,'xydatalist')) then begin
      result=self->multiply(second)
    endif else begin
      if not size(second,/type) eq 11 then message,'none of the arguments is a xydatalist object'
      result=second.multiply(first)
    endelse
  endif else begin
    result=second.multiply(first)
  endelse 
  return,result
end

function xyDataList::_overloadMinus,first,second
  return,self->sum(second*(-1))
end

;pro xyDataList::write,outfile,index=index,_extra=extra,noaverage=noaverage
;  ;write all vectors on a file. The first version was resampling the vectors
;  ; to have the same number of elements and write them as a matrix, but this
;  ; was creating problems, e.g. is the ranges of x were not completely 
;  ; overlapping. The approach of no resampling and writing x and y for each
;  ; xydata gives problems if the number of points is different for the different
;  ; vectors.
;  ; TODO: add an option to write vectors without resampling 
;  ;   (one file per vector).
;  
;  tmp=self.duplicate()
;  tmp.resample,index=index
;  tmp.getproperty,xlist=xlist,ylist=ylist,nscans=nscans
;  xar=transpose(xlist[0])
;  head='Y('+sindgen(nscans)+')'
;  xar=[xar,[ylist.toarray()]]
;  head=['X',head]
;  if keyword_set(noaverage) eq 0 then begin
;    xar=[[xar],transpose((self.average(err=rms)).y)]
;    xar=[[xar],transpose(rms.y)]
;    head=[head,'Average   rms']
;  endif 
;  
;  write_datamatrix,outfile,xar,header=strjoin(head,'  '),_extra=extra
;  obj_destroy,tmp
;end

pro xyDataList::write,outfile,index=index,_extra=extra,noaverage=noaverage
  ;write all vectors on separate files and their average on a different one. 
  ;   The first version (above) was resampling the vectors
  ;   to have the same number of elements and write them as a matrix, but this
  ;   was creating problems, e.g. is the ranges of x were not completely 
  ;   overlapping. The approach of no resampling and writing x and y for each
  ;   xydata gives problems if the number of points is different for the different
  ;   vectors.
  ; Now resampling options (e.g. index) are used only for the average 
  
  self.getproperty,xlist=xlist,ylist=ylist,nscans=nscans
  if n_elements(outfile) ne 1 then begin
    ;outfile is a vector. Includes also the case in which is not defined
    onemore=keyword_set(noaverage)?0:1  ;=1 if one more name is needed for average
    if n_elements(outfile) ne nscans+onemore then message,'wrong number of arguments for vector outfile'
    outnames=outfile
  endif else begin
    ;outfile is a scalar
    for i =0,nscans -1 do begin
      outnames[i]=fnaddsubfix(outfile,'_'+string(i,'(i4.4)'))
    endfor    
    if not keyword_set(noaverage) then outnames=[outnames,fnaddsubfix(outfile,'_avg')]
  endelse
    
  for i =0,nscans -1 do begin
    self[i].write,outnames[i]
  endfor
    
  if keyword_set(noaverage) eq 0 then begin
    tmp=self->duplicate()
    tmp.resample,index=index
    tmp.getproperty,xlist=xlist,ylist=ylist,nscans=nscans
    xar=xlist[0]
    yar=(self.average(err=rms)).y
    ear=rms.y
    head=['X  Average_of'+strtrim(string(nscans),2)+'_profiles  rms']
    writecol,outnames[nscans],xar,yar,ear,header=head
    obj_destroy,tmp
  endif 
  
end

function xyDataList::_overloadBracketsRightSide,isRange,sub1
  if isRange ne 0 then begin
    message, 'subscript range not implemented.'
  endif else begin
    result=((self.datalist)[sub1]).duplicate()
    ;result=((self.datalist)[sub1])[*]
  endelse
  return,result
end

pro xyDataList::_overloadBracketsLeftSide,objRef, rValue, isRange, sub1
  if isRange ne 0 then begin
    message, 'subscript range not implemented.'
  endif else begin
    (self.datalist)[sub1]=rValue
  endelse
end

function xyDataList::Init,listoffiles,_extra=extra
    self.datalist=list()
    nfiles=n_elements(listoffiles)
    if nfiles ne 0 then begin
      type=size(listoffiles,/type)
      ;7=string, 11=list
      if type ne 7 and type ne 11 then message,'argument type not recognized'
      for i=0,nfiles-1 do begin
        if type eq 7 then tmp= xydata(listoffiles[i],_extra=extra) else tmp=listoffiles[i] 
        (self.datalist).add,tmp
      endfor  
    endif  
  return,1
end

pro xyDataList::Cleanup
  self->getproperty,nscans=nscans
  for i =0,nscans-1 do begin
    obj_destroy,(self.datalist)[i]
  endfor
end

pro xyDataList__define
struct={xyDataList,$
        datalist:list(),$
        INHERITS IDL_Object ,$
        INHERITS IDL_Container $
        }
end

pro test_rightbracket,aa
  c=aa.duplicate()
  window,0
  c[1].draw,title='datalist[1]before'
  window,1
  a=c[1]
  a.draw,title='a=datalist[i]'
  window,3
  a.level,degree=1
  a.draw,title='a after lev'
  window,4
  c[1].draw,title='datalist[1]after'
end
