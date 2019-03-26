;2012/10/02 from profiles_characterization in nanovea_characterization



function average_Vector_List,vlist,err=err
  ; average a list of vectors
  
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

function load_vector_list,listoffiles,_extra=extra,xlist=xlist,copyfolder=copyfolder,prefix=prefix
  if n_elements(prefix) eq 0 then prefix=''
  nfiles=n_elements(listoffiles)
  xlist=list()
  ylist=list()
  for i=0,nfiles-1 do begin
    readcol,listoffiles[i],x,y,_strict_extra=extra
    writecol,copyfolder+path_sep()+prefix+(strsplit(listoffiles[i],path_sep(),/extract))[-1],x,y
  xlist.add,x
  ylist.add,y
  endfor
  return,ylist
end

function level_vector_list,xlist,ylist,degree=degree
  ;level each vector in a list of vectors
  nvec=n_elements(ylist)
  vlev=list()
  for i=0,nvec-1 do begin
    vlev.add,level(xlist[i],ylist[i],degree=degree)
  endfor
  return,vlev
end


function psd_vector_list,xlist,ylist,freqlist=freqlist
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

function smooth_vector_list,xlist,ylist,nwidth,xwidth=xwidth,_extra=exta,npout=npout
  nvec=n_elements(ylist)
  nw=lonarr(nvec)
  if n_elements(nwidth) and n_elements(xwidth) ne 0 then message,"NWIDTH and XWIDTH are both set!"
  if n_elements(nwidth) ne 0 then begin
     if n_elements(nwidth) ne nvec then begin
        if n_elements(nwidth) ne 1 then message,"unrecognized number of elements for NWIDTH"
        nw=replicate(nwidth,nvec)
     endif else nw=nwidth        
  endif
  if n_elements(xwidth) ne 0 then begin
     if n_elements(xwidth) ne nvec then begin
        if n_elements(xwidth) ne 1 then message,"unrecognized number of elements for NWIDTH"
        xw=replicate(xwidth,nvec)
     endif else xw=xwidth        
     for i=0,nvec-1 do begin
        step=(xlist[i])[1]-(xlist[i])[0] ;
        nw[i]=fix(xw[i]/step+0.5)    ;number of points in the smoothing window
     endfor
  endif 
  npout=nw
  ysm_list=list()
  for i=0,nvec-1 do begin
    x0=xlist[i]
    y0=smooth(ylist[i],nw[i],/edge_truncate,_extra=extra)
    ysm_list.add,y0
  endfor
  
  return,ysm_list
end
