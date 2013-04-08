;2012/10/02 from profiles_characterization in nanovea_characterization

;FIXME: x coordinates are ignored in averaging (and probably everywhere), 
;   it works only if vectors have the same x coordinates.



pro profileList::getproperty,xlist=xlist,ylist=ylist,nscans=nscans
  IF Arg_Present(xlist) THEN xlist = self.xlist 
  IF Arg_Present(ylist) THEN ylist = self.ylist
  IF Arg_Present(nscans) THEN nscans = self.nscans
end

function profileList::average,err=err
  ; average a list of vectors
  
  vlist=self.ylist
  nvec=n_elements(vlist)
  avg=vlist[0]*0
  err=vlist[0]*0
  npoints0=n_elements(vlist[0])
  for i=0,nvec-1 do begin
    if n_elements(vlist[i]) ne npoints0 then message,'wrong number of elements for vector '+string(i)
    avg=avg+vlist[i]
  endfor
  avg=avg/nvec
  
  for i=0,nvec-1 do begin
    err=err+(vlist[i]-avg)^2
  endfor
  err=sqrt(err/nvec)
  return,avg
end

pro profileList::load,listoffiles,_extra=extra,copyfolder=copyfolder,prefix=prefix

  if n_elements(prefix) eq 0 then prefix=''
  nfiles=n_elements(listoffiles)
  xlist=list()
  ylist=list()
  for i=0,nfiles-1 do begin
    readcol,listoffiles[i],x,y,_strict_extra=extra
    if n_elements(copyfolder) ne 0 then $
      writecol,copyfolder+path_sep()+prefix+(strsplit(listoffiles[i],path_sep(),/extract))[-1],x,y
    xlist.add,x
    ylist.add,y
  endfor
  self.xlist=xlist
  self.ylist=ylist
  self.nscans=nfiles
end

function profileList::level,degree=degree
  xlist=self.xlist
  ylist=self.ylist
  ;level each vector in a list of vectors
  nvec=n_elements(ylist)
  vlev=list()
  for i=0,nvec-1 do begin
    vlev.add,level(xlist[i],ylist[i],degree=degree)
  endfor
  return,vlev
end

pro profileList::level,degree=degree
  self.ylist=self.level(degree=Degree)
end


function profileList::psd,freqlist=freqlist
  xlist=self.xlist
  ylist=self.ylist
  nvec=n_elements(ylist)
  x0=xlist[0]
  freqlist=list()
  psdlist=list()
  for i=0,nvec-1 do begin
    if not (array_equal(x0, xlist[i])) then begin
      beep
      message,'non corresponding x for vector '+string(i),/info
    endif
    psd=prof2psd(xlist[i],ylist[i],f=freq,/positive_only,/hanning)
    ;psd normalization
    f2=freq
    psd2=psd
    integral = 2*INT_TABULATED( F2,psd2,/sort ) ;the factor 2 to include the negative frequencies 
    ;;histogram of heights
    zstats=histostats(Ylist[i],/noplot)
    var=zstats[7]
    print,'integralpsd=',integral,' variance=',var
    psd=psd*var/integral
    normpars=[sqrt(integral),sqrt(var),var/integral]
    psdlist.add,psd
    freqlist.add,freq
  endfor
  
  return,PSDLIST
end

;function smooth_vector_list,nwidth,xwidth=xwidth,_extra=exta
;  xlist=self.xlist
;  ylist=self.ylist
;  nvec=n_elements(ylist)
;  nw=lonarr(nvec)
;  if n_elements(nwidth) and n_elements(xwidth) ne 0 then message,"NWIDTH and XWIDTH are both set!"
;  if n_elements(nwidth) ne 0 then begin
;     if n_elements(nwidth) ne nvec then begin
;        if n_elements(nwidth) ne 1 then message,"unrecognized number of elements for NWIDTH"
;        nw=replicate(nwidth,nvec)
;     endif else nw=nwidth        
;  endif
;  if n_elements(xwidth) ne 0 then begin
;     if n_elements(xwidth) ne nvec then begin
;        if n_elements(xwidth) ne 1 then message,"unrecognized number of elements for NWIDTH"
;        xw=replicate(xwidth,nvec)
;     endif else xw=xwidth        
;     for i=0,nvec-1 do begin
;        step=(xlist[i])[1]-(xlist[i])[0] ;
;        nw[i]=fix(xw[i]/step+0.5)    ;number of points in the smoothing window
;     endfor
;  endif 
;  
;  ysm_list=list()
;  for i=0,nvec-1 do begin
;    x0=xlist[i]
;    y0=smooth(ylist[i],nw[i],/edge_truncate,_extra=extra)
;    ysm_list.add,y0
;  endfor
;  
;  return,ysm_list
;end


pro profileList::write,outfile,_extra=extra
  ;write a list of column on file,
  ;if YLIST is provided, vectors of xlist and ylist are alternated.
  xlist=self.xlist
  ylist=self.ylist
  nx=size(xlist,/n_dimensions)
  ny=n_elements(ylist)
  if nx ne 1 then begin
    if ny ne 0 and ny ne (size(xlist,/dimensions))[0] then message, 'non corresponding number of elements nx and ny'
    xar=xlist.toarray()
  endif else xar=transpose(xlist)
  head='Y('+sindgen(nx)+')'
  if ny ne 0 then begin
    xar=[xar,ylist.toarray()]
    head=['X('+sindgen(ny)+')',head]
  endif
  write_datamatrix,outfile,xar,header=head,_extra=extra
  
end


function profileList::Init
  return,1
end

pro profileList::Cleanup

end




pro profileList__define
struct={profileList,$
        filelist:list(),$
        xlist:list(),$
        ylist:list(),$
        nscans:0l,$
        INHERITS IDL_Object $
        }
end
