;it is a single dataset (Map)
;define the basic operations on a dataset
;TODO: 2012/09/14 added zfactor in __setdata for conversion from data to points. Then removed,
; it creates ambiguity when set together with data (rather than later).
; the best solution is making zfactor a read-only property (can be set only at initialization). 
 

pro CMMsurface::__setplane,plane
   if n_elements(plane) eq 0 then begin
      message,'Plane argument not provided, plane will not be set',/informational 
      return
    endif
    
    ;if n_elements(plane) ne n_elements(*self.plane) then begin
    if n_elements(plane) eq 1 then begin
      if plane eq 0 then p0=self->getproperty(/plane)*0 else message,'scalar, non-null value provided for plane, cannot set! Plane:'+string(plane)
    endif else p0=plane
    
    if size(p0,/n_dimensions) eq 1 then begin    ;vector
        ndim=n_elements(p0)
        if ndim ne n_elements(self->getproperty(/plane)) then message,'non-matching number of dimension for plane (vector), plane:'+string(p0)
    endif else message ,'unrecognized matrix for plane:'+string(p0)
    
    *self.plane=p0
    self.changed=1
    
end

pro CMMsurface::__setgrid,xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy,edgecut=edgecut
  ;EDGECUT is the number of points to cut on the edge in format [-x,+x,-y,+y], if a scalar value is provided,
;  this is usedd for all edges. NPX and NPY are the number of points without including the cut ones,
  ;corresponding to the final number of points in the grid

  if n_elements(edgecut) eq 0 then ec=0 else ec=edgecut
  if n_elements(ec) eq 1 then ec=replicate(ec,4)
  
  if n_elements(xgrid) eq 0 then begin 
    if n_elements(npx) ne 0 then begin
      xrange=range((self->getproperty(/points))[*,0])
      xgrid=creategrid(x0=xrange[0],x1=xrange[1],np=npx+ec[0]+ec[1])
      xgrid=xgrid[ec[0]:npx+ec[0]-1]
    endif else begin
      message,' neither xgrid or npx are set, cannot set grid',/informational
      return
    endelse
  endif else begin
      if n_elements(npx) ne 0 then $
        message,' xgrid and npx are both set, npx will be ignored',/informational
  endelse
  
  if n_elements(ygrid) eq 0 then begin 
    if n_elements(npy) ne 0 then begin
       yrange=range((self->getproperty(/points))[*,1])
       ygrid=creategrid(x0=yrange[0],x1=yrange[1],np=npy+ec[2]+ec[3]) 
       ygrid=ygrid[ec[2]:npy+ec[2]-1]
    endif else begin
      message,' neither ygrid or npy are set, cannot set grid',/informational
      return
    endelse
  endif else begin
      if n_elements(npy) ne 0 then $
        message,' ygrid and npy are both set, npy will be ignored',/informational
  endelse
  
  *self.xgrid=xgrid
  *self.ygrid=ygrid
  self.changed=1
  
end

pro CMMsurface::__setpoints,points,y,z
  ;the value of points should be modified using this routine from inside the class,
  ;using CMMsurfaceObJ->setproperty,points=points from outside.
  if arg_present(y) eq 0 then $
    *self.points=points $ ;one matrix 3 x NPOINTS
  else $
    self->setproperty,points=[[points],[y],[z]] ;tree vectors
  self.changed=1
end


pro CMMsurface::addNoise,sigma,seed=seed
    npoints=n_elements(self->getproperty(/points))
    noise=randomn(seed,npoints)*sigma
    p=self->getproperty(/points)
    p[*,2]=p[*,2]+noise/self->getproperty(/zfactor)
    self->setproperty,points=p
end

pro CMMsurface::scale,xyzscale,seed=seed
    p=self->getproperty(/points)
    ;for i =0,n_elements(points)-1 do begin
    p[*,0]=p[*,0]*xyzscale[0]
    p[*,1]=p[*,1]*xyzscale[1]
    p[*,2]=p[*,2]*xyzscale[2]
    ;enddo
    self->setproperty,points=p
end

pro CMMsurface::__setdata,data
  self->griddata::setproperty,data=data
  self->getproperty,xgrid=xgrid,ygrid=ygrid
  if n_elements(xgrid)*n_elements(ygrid) ne n_elements(data) then message,'Number of elements in DATA do not correspond to grid.'
  ;set points from data
  ;zfactor=double(self->getproperty(/zfactor))
  ;points=matrixToPoints(data/zfactor,xgrid,ygrid)
  points=matrixToPoints(data,xgrid,ygrid)
  self->getproperty,plane=plane
  pz=points[*,2]+(plane[0]*points[*,0]+plane[1]*points[*,1]+plane[2]);subtract plane to set points
  self->setproperty,points=[[points[*,0]],[points[*,1]],[pz]]  
end 

;pro CMMsurface::__setPointsFromData
;  xgrid=self->getproperty(/xgrid)
;  ygrid=self->getproperty(/ygrid)
;  ;grid=grid(xgrid,ygrid)
;  ;subtract plane 
;  ;plane=self->getproperty(/plane)
;  
;  ;plane=[0,0,0]
;  data=*self.data
;  ;data=data-plane[0]*grid[*,0]-plane[1]*grid[*,1]-plane[2]
;  ;points=[reform(data,n_elements(data))]
;  points=matrixToPoints(data,xgrid,ygrid)
;  self->__setpoints,points
;  
;end


pro     CMMsurface::getproperty,$
        ;filename=filename,$
        idstring=idstring,$
        plane=plane,$
        points=points,$  ;points as read from file (npoints x 3 array)
        data=data,$  ;processed data (e.g. leveled) (2d matrix)
        xgrid=xgrid,$
        ygrid=ygrid,$
        zfactor=zfactor,$
        resolution=resolution,_ref_extra=extra ;machine resolution in um, used for statistics computation
        
        if arg_present(data) then data=self->getproperty(/data)
        ;if arg_present(filename) then filename=self->getproperty(/filename)
        if arg_present(idstring) then idstring=self->getproperty(/idstring)
        if arg_present(plane) then plane=self->getproperty(/plane)
        if arg_present(points) then points=self->getproperty(/points)
        if arg_present(xgrid) then xgrid=self->getproperty(/xgrid)
        if arg_present(ygrid) then ygrid=self->getproperty(/ygrid)
        if arg_present(resolution) then resolution=self->getproperty(/resolution) 
        if arg_present(zfactor) then zfactor=self->getproperty(/zfactor) 
        self->griddata::getproperty,_extra=extra
end

function CMMsurface::getproperty,$
        ;filename=filename,$
        idstring=idstring,$
        plane=plane,$
        points=points,$  ;points as read from file (npoints x 3 array)
        data=data,$  ;processed data (e.g. leveled) (2d matrix)
        xgrid=xgrid,$
        ygrid=ygrid,$
        resolution=resolution,$
        zfactor=zfactor,$
        _ref_extra=_extra ;machine resolution in um, used for statistics computation
        
        if n_params() gt 1 then message,'called with more than one keyword, '+$
          'only the first one (according to the internal program order) will be returned.'
        if keyword_set(data) then begin
          self->_update
          return,*self.data  
          ;N.B: a reason to make return data and not data*zfactor is to maintain the simmetry between
          ;data and points: e.g. self->setproperty,data=self->getproperty(/data) would not work.
        endif
        ;if keyword_set(filename) then return,self.filename
        if keyword_set(idstring) then return,self->griddata::getproperty(/idstring)
        if keyword_set(plane) then return,*self.plane
        if keyword_set(points) then return,*self.points
        if keyword_set(xgrid) then return,self->griddata::getproperty(/xgrid)
        if keyword_set(ygrid) then return,self->griddata::getproperty(/ygrid)
        if keyword_set(resolution) then return,self->griddata::getproperty(/resolution)   
        if keyword_set(zfactor) then return,self->griddata::getproperty(/zfactor) 
        return,self->griddata::getProperty(_extra=_extra)
end

pro CMMsurface::setproperty,$
        ;filename=filename,$
        idstring=idstring,$
        plane=plane,$
        points=points,$  ;points as read from file (npoints x 3 array)
        data=data,$  ;processed data (e.g. leveled) (2d matrix)
        resolution=resolution,$ ;machine resolution in um, used for statistics computation
        xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy,$ ;,ystep=ystep,yrange=yrange,xrange=xrange,xstep=xstep
        zfactor=zfactor,$
        edgecut=edgecut,_ref_extra=extra
        
        ;grid and plane must be set before points and data!
        ;Keep it in mind, if you set the single properties in different steps.
        ;It is suggested to set the properties in the same function call,
        ; if you do this, the program will take care of priorities for you.
        ;To modify this behaviour, change the error message to /info in _update
        ; (see also program diagram on paper) and delay the calculation,
        ; as it was in a former version, but it was not completely working)
        
        ;if n_elements(filename) ne 0 then self.filename=filename
        if n_elements(idstring) ne 0 then self.idstring=idstring
        if n_elements(resolution) ne 0 then self.resolution=resolution
        if n_elements(zfactor) ne 0 then self.zfactor=zfactor  ;questo deve stare prima di data
        ;__setpoints does not use other info, so it can stay first.
        if n_elements(points) ne 0 then begin 
          if n_elements(data) ne 0 then message,'POINTS and DATA cannot be set together!' 
          self->__setpoints,points
        endif
        ;if npx|npy is set this uses points, it must stay after (it does not use data).
        if (n_elements(xgrid) ne 0 or n_elements(npx) ne 0) and $
        (n_elements(ygrid) ne 0 or n_elements(npy) ne 0) then begin
          self->__setgrid,xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy,edgecut=edgecut
        endif
        ;this needs the grid to set points, it must stay after grid.
        if n_elements(data) ne 0 then begin 
          self->__setdata,data
        endif
        if n_elements(plane) ne 0 then self->__setplane,plane
        self->griddata::setproperty,_extra=extra
end

pro CMMsurface::_resample  ;,flatten=flatten
      
      xy=transpose((self->getproperty(/points))[*,0:1])
      z=(self->getproperty(/points))[*,2]
      min_points=25<long(n_elements(z)/10)
      TRIANGULATE, xy[0,*], xy[1,*], tr
      griddeddata=griddata(xy,z,/grid,xout=*self.xgrid,yout=*self.ygrid,triang=tr, min_points=min_points,/linear)   
      *self.data=griddeddata
      
end

pro CMMsurface::_flatten ;,plane
  ;flatten subtracting self.plane.
  ;The best fit plane can be obtained by planefit
  ;it must be called after _resample (self.data must have been updated)

;  self->getproperty,points=points,plane=p0
;  xraw=(*self.points)[*,0]
;  yraw=(*self.points)[*,1]
;  zraw=(*self.points)[*,2]
;  residuals=zraw-(p0[0]*xraw+p0[1]*yraw+p0[2])
;  *self.data=resample_surface(xraw,yraw,residuals,xgrid=*self.xgrid,ygrid=*self.ygrid)

self->getproperty,xgrid=xg,ygrid=yg,plane=p0
grid=grid(xg,yg,xout=xraw,yout=yraw)
zraw=*self.data
residuals=zraw-(p0[0]*xraw+p0[1]*yraw+p0[2])
*self.data=residuals

end

pro CMMsurface::_update
  if n_elements(*self.xgrid) ne 0 and n_elements(*self.ygrid) ne 0 then begin
    if self.changed ne 0 then begin
      self->_resample
      self->_flatten
      self.changed=0
    endif 
  endif else begin
      if n_elements(*self.xgrid) eq 0 then message, 'Xgrid is not defined',/informational
      if n_elements(*self.ygrid) eq 0 then message, 'Ygrid is not defined',/informational
      message, 'cannot calculate data!' ;,/informational
      self.changed=0
      return
    endelse
end

function CMMsurface::extractProfile,xystart,xyend,npoints=npoints,$
      sampling=sampling,x=x  ;,flatten=flatten
      ;extract a profile of equally spaced points from points
      ;the number of points can be set, otherwise is set accordingly to the longest
      ; profile dimension.
      ;x return the x value in profile coordinates
      x0=double(xystart[0])
      y0=double(xystart[1])
      x1=double(xyend[0])
      y1=double(xyend[1])
      dx = x1-x0
      dy = y1-y0
      if abs(dx) > abs(dy) eq 0 then message, 'Zero length line.'
      xg=self->getproperty(/xgrid)
      yg=self->getproperty(/ygrid)
      if n_elements(npoints) ne 0 or n_elements(sampling) ne 0 then begin
        if n_elements(npoints) ne 0 then begin
          if n_elements(sampling) ne 0 then message, 'SAMPLING and NPOINTS cannot be both set'
          np=npoints 
        endif else begin
          np=1l+sqrt((xystart[0]-xyend[0])^2+(xystart[1]-xyend[1])^2)/sampling
        endelse
      endif else begin        
        dummy=where(xg ge x0<x1 and xg le x0>x1,c1)
        dummy=where(yg ge y0<y1 and yg le y0>y1,c2)
        if c1 eq -1 and c2 eq -1 then message,"too small interval, cannot set points automatically!"
        np=c1>c2
      endelse 
      xout=vector(x0,x1,np)
      yout=vector(y0,y1,np)
      x=sqrt((xout-x0)^2+(yout-y0)^2)
      xy=transpose((self->getproperty(/points))[*,0:1])
      z=((self->getproperty(/points))[*,2])*(self->getproperty(/zfactor))
      min_points=10<long(n_elements(z)/10)
      TRIANGULATE, xy[0,*], xy[1,*], tr
      profile=griddata(xy,z,xout=xout,yout=yout,triang=tr, min_points=min_points,/linear)   
      return,profile
      
end

function CMMsurface::sphereFit,toll=toll,residuals=residuals,_extra=extra,$
                                psfile=psfile,window=w,noplot=noplot,amoeba=amoeba
  xgrid=self->getproperty(/xgrid)
  ygrid=self->getproperty(/ygrid)
  grid=grid(xgrid,ygrid)
  data=self->getproperty(/data)
  surfpoints=[[grid[*,0]],[grid[*,1]],[reform(data,n_elements(data))]]
  
  result=spherefit(surfpoints,toll=toll,residuals=residuals,amoeba=amoeba);,weight=1/sqrt(grid[*,0]^2+grid[*,1]^2))
  residuals=reform(residuals,n_elements(xgrid),n_elements(ygrid))
  
  zfactor=self->getproperty(/zfactor)
;    if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
;     else if keyword_set (noplot) eq 0 then begin   
;        if n_elements(w) eq 0 then window,/free else window,w
;    avsurf->draw,legend=['Best Sphere Fit','Xc:','Yc:','Zc','R:']+["",string(sphere)]
;    oplot, result[0:0],result[1:1], psym=1, color=cgcolor('white')
;    maketif,imgdir+path_sep()+'surface_level_centerfit'
;  if n_elements(psfile) ne 0 then ps_end
   
  zr=range(residuals*zfactor)  ;N.B.: it is different from range(residuals)*zfactor if zfactor<0
  if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
     else if keyword_set (noplot) eq 0 then begin   
        if n_elements(w) eq 0 then cgwindow,/free else cgwindow,w+1
  cgimage, residuals*zfactor,xgrid,ygrid, position=plotpos, /Save,/scale,$
          /Axes,/keep_aspect,minus_one=0,xrange=range(xgrid),yrange=range(ygrid),$
          minvalue=zr[0],maxvalue=zr[1],$
          AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',title:'Residuals'}
  if n_elements(divisions) eq 0 then divisions=6
  if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
  cgcolorbar,/vertical,range=zr,divisions=divisions,$
          format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle
  if n_elements(psfile) ne 0 then ps_end
  endif  

  return,result
end

;pro CMMsurface::spherefit,idstring=newidstring
;  self->setproperty,plane=self->planefit(),idstring=newidstring
;  if n_elements(newidstring) ne 0 then self->setproperty,idstring=newidstring
;end

function CMMsurface::getStats,outvars=outvars,string=string,table=table,$
                locations=locations,hist=hist,$
                noplot=noplot,psfile=psfile,header=header,window=w,$
                resampling=resampling,surface=surface,plane=plane,_extra=extra

;Generate a table with possible statistics, 
; selectable by means of flags /RESAMPLING, /SURFACE, /PLANE.
;the results created are:
;- statistics selected by OUTVARS in form of numbers, string (/STRING) or table (/TABLE). 
;- LOCATIONS and HIST for the variables unders exam
;- Plot if WINDOW or PSFILE are provided and /NOPLOT is not set

  ;multiple keywords set
  if keyword_set(resampling)+keyword_set(surface)+keyword_set(plane) gt 1 then $
    message,'Only one keyword among /resampling, /surface and /plane can be set.'
  if keyword_set(resampling)+keyword_set(surface)+keyword_set(plane) eq 0 then begin
    ;called without keywords return the surface and plane statistics (e.g. it is 
    ;used for the plot)
    statssurface=self->getstats(/table,psfile=psfile,$
                outvars=outvars,/surface,noplot=noplot,_extra=extra)
    statsplane=self->getstats(/table,psfile=psfile,$
                outvars=outvars,/plane,/noplot,_extra=extra)  
    statsplane=statsplane->transpose(/destroy)
    stats=statssurface->join(statsplane,/destroy)
   endif  
   
  ;self->_update
  ;single keywords set  
  if keyword_set(surface) then stats=self->griddata::getStats(/table,noplot=noplot,$
                outvars=outvars,locations=locations,hist=hist,header=header,window=w,$
                psfile=psfile,_extra=extra)
  
  if keyword_set(resampling) then begin
    ;get data
    xraw_1=(self->getproperty(/points))[*,0]  
    yraw_1=(self->getproperty(/points))[*,1]
    zraw_1=(self->getproperty(/points))[*,2]*self.zfactor
    xgrid=self->getproperty(/xgrid)
    ygrid=self->getproperty(/ygrid)
    pstore=self->getproperty(/plane)
    self->setproperty,plane=0  ;for the comparison I want unleveled data
    zresampled=self->getproperty(/data)*self.zfactor
    self->setproperty,plane=pstore  ;restore the leveling
    nz = n_elements(zresampled[UNIQ(zresampled, SORT(zresampled))])
    gridMat=grid(xgrid,ygrid)
    i=nearestn(transpose(gridmat),transpose([[xraw_1],[yraw_1]]),0,dist=dist2d)
    xdist=(gridmat[*,0]-xraw_1[i])*self.zfactor
    ydist=(gridmat[*,1]-yraw_1[i])*self.zfactor
    zdist=reform(zresampled,n_elements(zresampled))-zraw_1[i]
    dist3d=sqrt(dist2d^2+zdist^2)
    ;calculate (and plot) histogram
        
    if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
       else if keyword_set (noplot) eq 0 then begin   
          if n_elements(w) eq 0 then cgwindow,/free else cgwindow,w
    endif
    if n_elements(outvars) eq 0 then outvars=[0,1,2,3,4]
    diststats=histostats([[xdist],[ydist],[zdist]],binsize=self->getproperty(/resolution),$
               locations=locations,$
               hist=hist,noplot=noplot,/normalize,header=header,$
               outvars=outvars,/table,vecnames=['x','y','z'],xtitle='Change of coordinate for resampling (um)',$
               ytitle='Fraction of points',_extra=extra  )      

    if n_elements(psfile) ne 0 then ps_end    
    ;generate statistics
    rowheader=['N of distinct values:','Min','Max']
    stats=string([n_elements(xgrid),n_elements(ygrid),nz])
    stats=[[stats],[string([min(xraw_1),min(yraw_1),min(zresampled)])]]
    stats=[[stats],[string([max(xraw_1),max(yraw_1),max(zresampled)])]]
    stats=obj_new('table',caption='Resampling data for '+self.idstring+'.',$
        data=stats,colheader=['x','y','z'],rowheader=rowheader)
    diststats->setproperty,rowheader=header
    stats=stats->join(diststats,/destroy)
  endif 
  
  if keyword_set(plane) then begin
      plane=self->getproperty(/plane)
      stats=obj_new('table',caption='Plane for '+self.idstring+', z=Ax+By+C',data=transpose(plane),$
                      rowheader=self.idstring,colheader=['A','B','C'])
  endif
  
  result=stats->write(table=table,string=string,_extra=extra)
  return,result
  
end



;pro CMMsurface::oplotpoints,_extra=extra
;
;    xraw_1=(self->getproperty(/points))[*,0]  
;    yraw_1=(self->getproperty(/points))[*,1]
;    oplot,xraw_1,yraw_1,_extra=extra
;    
;end

pro CMMsurface::plotpoints,oplot=oplot,_extra=extra,$
    Rpoints=RP

    points=self->getproperty(/points) 
    xraw_1=points[*,0]  
    yraw_1=points[*,1]
    if keyword_set(oplot) then oplot,xraw_1,yraw_1,_extra=extra $
    else plot,xraw_1,yraw_1,_extra=extra
    
end

pro cmmsurface::crop,x,y
  xgrid=(self->getproperty(/xgrid))
  ygrid=(self->getproperty(/ygrid))
  if n_elements(xgrid)*n_elements(ygrid) eq 0 then $
        message,'tried to crop with non defined grid, impossible in this implementation.'
  if n_elements(x) eq 1 then begin
    if x ne 0 then message,'scalar value not recognized for x'
    x=range(xgrid)
  endif else if n_elements(x) ne 2 then message,'wrong number of elements for x'
  if n_elements(y) eq 1 then begin
    if y ne 0 then message,'scalar value not recognized for x'
    y=range(ygrid)
  endif else if n_elements(y) ne 2 then message,'wrong number of elements for x'
  xsel=where(xgrid le x[1] and xgrid ge x[0],c)
  if c ne 0 then xgrid=xgrid[xsel]
  ysel=where(ygrid le y[1] and ygrid ge y[0],c)
  if c ne 0 then ygrid=ygrid[ysel]
  self->setproperty,xgrid=xgrid,ygrid=ygrid

end

function cmmsurface::crop,x,y
    res=self->duplicate()
    res->crop,x,y
    return,res
end

pro CMMsurface::plotResampling,silent=silent,noplot=noplot,$
    Stats=Stats,psfile=psfile,table=table,window=w,$
    diststats=diststats,_extra=extra,oplot=oplot,psym=psym,color=color
    
    ;if table is set, return stats as a table object.
    ;if silent is set, do not print stats (not printed 
    ;in any case if table is set).
  
  if n_elements(color) ne 2 then color= [cgcolor('red'),cgcolor('blue')]
  if n_elements(psym) ne 2 then psym= [1,4]
  ;plot of resampled points
  diststats=self->getstats(/resampling,/string,/noplot,_extra=extra)
    if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
       else if keyword_set (noplot) eq 0 then begin   
          if n_elements(w) eq 0 then cgwindow,/free else window,w
       endif
    xraw_1=(self->getproperty(/points))[*,0]  
    yraw_1=(self->getproperty(/points))[*,1]
    xgrid=self->getproperty(/xgrid)
    ygrid=self->getproperty(/ygrid)
    gridMat=grid(xgrid,ygrid)
    rr=squarerange([xraw_1,xgrid],[yraw_1,ygrid],expansion=1.05)      
    if keyword_set(oplot) eq 0 then plot,[0],[0],/nodata,xrange=rr[0:1],yrange=rr[2:3],/isotropic,title=self.idstring,$
      background=cgcolor('white'),color=cgcolor('black'),_extra=extra
     self->plotpoints,psym=psym[0],color=color[0],symsize=1,_extra=extra,/oplot
     self->plotgrid,psym=psym[1],symsize=1,color=color[1],_extra=extra,/oplot
    if keyword_set(oplot) eq 0 then begin
      legend,['raw data','resampled'],position=13,color=color,/sym_only,_extra=extra,psym=psym
      legend,diststats,position=14,/nolines,color=cgcolor('black'),_extra=extra
    endif
    
;    cgwindow,'cgplot',[0],[0],wxsize=840,wysize=525,/nodata,xrange=rr[0:1],yrange=rr[2:3],/isotropic,title=self.idstring,$
;      background='white',_extra=extra,aspect=1.0
;    cgplot,gridMat[*,0],gridMat[*,1],psym=1,symsize=1,color='red',/overplot,_extra=extra, /ADDCMD
;    cgplot,xraw_1,yraw_1,psym=9,color='blue',symsize=1,/overplot,_extra=extra, /ADDCMD
;    cgwindow,'legend',['raw data','resampled'],position=13,color=[250,100],psym=[1,4],/sym_only,_extra=extra,/ADDCMD
;    cgwindow,'legend',stats,position=14,/nolines,color=cgcolor('black'),_extra=extra, /ADDCMD
    
    if n_elements(psfile) ne 0 then ps_end
end

function CMMsurface::planefit,levelonly=levelonly, offsetonly=offsetOnly
  ;return vector [A,B,C] of best fit plane Ax + By + C = z
  ; The fit is performed on DATA.

  ;xraw=(*self.points)[*,0]
  ;yraw=(*self.points)[*,1]
  ;zraw=(*self.points)[*,2]
  self->getproperty,plane=p0
  self->setproperty,plane=0
  self->getproperty,data=data,xgrid=xgrid,ygrid=ygrid
  points=matrixtopoints(data,xgrid,ygrid)
  self->setproperty,plane=p0
  plane=plane_fit(points[*,0],points[*,1],points[*,2])
  if keyword_Set(levelonly) then plane[2]=p0[2]
  if keyword_Set(offsetOnly) then plane[0:1]=p0[0:1]
  return,plane
end

pro CMMsurface::planefit,_extra=extra ;,idstring=newidstring
  self->setproperty,plane=self->planefit(_extra=extra) ; ,idstring=newidstring
  ;if n_elements(newidstring) ne 0 then self->setproperty,idstring=newidstring
end

pro cmmsurface::translate,xyz
  if n_elements(xyz) ne 3 then message,'The argument for TRANSLATE must be a 3-element vector!' 
  xoffset=xyz[0]
  yoffset=xyz[1]
  zoffset=xyz[2]
  ;differently from griddata, acts on points
  zfactor=self->getproperty(/zfactor)
  p=self->getproperty(/points)
  p=[[p[*,0]+xoffset],[p[*,1]+yoffset],[p[*,2]+zoffset/zfactor]]
  self->setproperty,points=p
  ;if the grid is defined, translates also the grid
  self->getproperty,xgrid=xg,ygrid=yg
  if n_elements(xg) ne 0 then xg=xg+xoffset
  if n_elements(yg) ne 0 then yg=yg+yoffset
  if n_elements(xg)*n_elements(yg) ne 0 then self->setproperty,xgrid=xg,ygrid=yg
end

pro CMMsurface::rotate,angle,center,x0,y0
;rotateGrid
  data=self->getproperty(/data)
  if n_elements(center) eq 0 then pt=[0.0,0.0]
  data=rot(data,angle,1.0,/interp,/pivot,missing=min(data))
  self->setproperty,data=data
end

pro CMMsurface::clip, min=min,max=max,clipvalue=clipvalue,$
    nsigma=nsigma, refimage=refimage,mask=mask,_extra=extra
  ;TODO accept a CMMsurface as refimage
  ;TODO if ADDMARKER is set a marker is added for clipped points 
  
  zfactor=self.zfactor
  data=self->getproperty(/data)*zfactor
  
  clippeddata=clip( data, min=min,max=max,clipvalue=clipvalue,nsigma=nsigma,$
      refimage=refimage,mask=mask,torefimage=torefimage,$
      _strict_extra=extra)
  clippeddata=clippeddata/zfactor
  
  message,'Clipping image data will transform the whole set of data '+self->getproperty(/idstring)$
        +', resampling information will be lost.',/informational

  self->setproperty,data=clippeddata
  self.changed=1
  
end

;function CMMsurface::duplicate,resample=resample,idstring=idstring,_extra=extra
;        ;if resample is set instead than duplicating points, uses data to set points
;        ;   (it can be used to have a downsampled faster version).
;        ; TODO: it should be made possible to change the grid at duplication and resample the data.
;        ; in general a RESAMPLE procedure would be useful (use _resample).
;        
;        if keyword_set(resample) eq 0 then points=self->getproperty(/points) $
;           else data =  self->getproperty(/data)
;        if n_elements(idstring) eq 0 then ids=self->getproperty(/idstring) else ids=idstring
;        result=obj_new('CMMsurface',$
;                  points,$
;                  idstring=ids)
;        result->setproperty,xgrid=self->getproperty(/xgrid),$
;                            ygrid=self->getproperty(/ygrid),$
;                            data = self->getproperty(/data),$
;                            plane=self->getproperty(/plane),$
;                            resolution=self->getproperty(/resolution),$
;                            zfactor=self->getproperty(/zfactor)
;        return,result
;end

function CMMsurface::duplicate
        
        result=obj_new('CMMsurface',$
                  self->getproperty(/points),$
                  idstring=self->getproperty(/idstring))
        result->setproperty,xgrid=self->getproperty(/xgrid),$
                            ygrid=self->getproperty(/ygrid),$
                            plane=self->getproperty(/plane),$
                            resolution=self->getproperty(/resolution),$
                            zfactor=self->getproperty(/zfactor)
        return,result
end

function CMMsurface::subtract,scan2,destroy=destroy,idstring=idstring
  ;subtract a scan from another. The result is a copy of the first
  ; object, with the difference values calculated from data property. 
  ;The grid is taken from the second scan, plane is the the difference 
  ;   of planes. 

  ;create a copy to not alter self value
  tmp=self->duplicate()
  tmp->setproperty,xgrid=self->getproperty(/xgrid),ygrid=self->getproperty(/ygrid)
  t=size(scan2,/type)
  if t eq 11 then begin
    tmp->setproperty,plane=(tmp->getproperty(/plane))-(scan2->getproperty(/plane))
    tmp->setproperty,data=(tmp->getproperty(/data))-(scan2->getproperty(/data))
  endif else begin 
    if t ge 1 and t le 5 then begin
      tmp->setproperty,plane=(tmp->getproperty(/plane))
      tmp->setproperty,data=(tmp->getproperty(/data))-scan2
    endif else message, 'Type not recognized'
  endelse
  
  if n_elements(idstring) ne 0 then tmp->setproperty,idstring=idstring
  
  if keyword_set(destroy) then begin
    obj_destroy,self
    obj_destroy,scan2
  endif ;else scan2->setproperty,plane=planescan2
  ;return,diff
  return, tmp
end


pro CMMSurface::createreport,outfolder=outfolder,$
  outname=outname,report=report,ps=ps,npx=npx,npy=npy,$
  xgrid=xgrid,ygrid=ygrid,zraw=z_meas1,zflat=z_flatten,$
  sectionlevel=sectionlevel
  ;this method of CMMsurface create a complete report about a CMMsurface.
  ;the report includes a section about resampling, and plots of the raw 
  ;and leveled (if plane is defined and stats tables.  

  if n_elements (sectionlevel) eq 0 then  sectionlevel=0
  if n_elements(outname) eq 0 then outname=self.idstring
  
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
  
  report->section,sectionlevel,'Resampling'
  self->plotResampling,psfile=outname+'_resampling'

end

function CMMsurface::Init,points,idstring=idstring,$
        plane=plane,$ ;points as read from file (npoints x 3 array)
        data=data,$  ;processed data (e.g. leveled) (2d matrix)
        resolution=resolution,$ ;machine resolution in um, used for statistics computation
        zfactor=zfactor,$
        xgrid=xgrid,xrange=xrange,xstep=xstep,npx=npx,$
        yrange=yrange,ystep=ystep,ygrid=ygrid,npy=npy,edgecut=edgecut
    
    self.changed=0
    self.points=ptr_new(/allocate_heap)  ;points as read from file (npoints x 3 array)
    self.plane=ptr_new(dblarr(3))
    self->setproperty,points=points
    if n_elements(zfactor) eq 0 then zfactor=1.
    if n_elements(resolution) eq 0 then self.resolution=0.1d else self.resolution=resolution
    if n_elements(edgecut) eq 0 then edgecut=1 
    result=self->griddata::Init(data,idstring=idstring,$
        resolution=resolution,zfactor=zfactor,xgrid=xgrid,ygrid=ygrid)
    self->setproperty,$
        plane=plane,$
        xgrid=xgrid,npx=npx,$
        ygrid=ygrid,npy=npy,edgecut=edgecut
    return,result
end

pro CMMsurface::Cleanup
  ptr_free,self.points
  ptr_free,self.plane
  self->griddata::Cleanup
end

pro CMMsurface__define
struct={CMMsurface,$
        inherits griddata,$
        plane:ptr_new(),$
        points:ptr_new(),$  ;points as read from file (npoints x 3 array)
        changed:0 $
;        idstring:"",$
;        data:ptr_new(),$  ;processed data (e.g. leveled) (2d matrix)
;        xgrid:ptr_new(),$
;        ygrid:ptr_new(),$
;        resolution:0.1d, $ ;vertical resolution, used for statistics computation
;        zfactor:1000. $
        }
end

pro _compare_twosurf,a,b
  help,a->getproperty(/points)
  help,b->getproperty(/points)
  print,range(a->getproperty(/points))
  print,range(b->getproperty(/points))
  print,range(a->getproperty(/data))
  print,range(b->getproperty(/data))
end

pro test_basic,a
  a->draw,title='Unleveled',/nointerp
  a->plotResampling,/table,stats=stats
  ;a->setproperty,plane=a->planefit()
  a->planefit
  print,'plane=',a->getproperty(/plane)
  a->draw,title='Leveled',background=255
  
  a->getproperty,data=data 
  print,a->getproperty(/plane)
  print,range(data)
  print,a->getproperty(/plane)
  a->setproperty,data=data
  print,range(data)
  a->getproperty,data=data 
  print,a->getproperty(/plane)
  print,range(data)
end

;function test_duplicate,a
;
;  print,'duplicate a:'
;  b=a->duplicate()
;  _compare_twosurf,a,b
;  print, 'duplicate with resample to 10x10:'
;  a->getproperty,xg=xg,yg=yg
;  a->setproperty,npx=10,npy=10
;  b=a->duplicate(/resample)
;  a->setproperty,xg=xg,yg=yg
;  _compare_twosurf,a,b
;  
;  return,b
;end

heap_gc
cd, programrootdir()
outfolder='test'+path_sep()+'cmmsurface'
file_mkdir,outfolder
datafolder=outfolder+path_sep()+'input_files'
set_plot_default

file=datafolder+path_sep()+'Moore-Scan-Vert-surface-0V.dat' ;windows
;file='/export/cotroneo/work/work_ratf/run2b/2011_03_07/latact_test/Moore-Scan-Vert-surface-0V.dat' ;unix

if obj_valid(a) then obj_destroy,a
readcol,file,z,x,y,format='X,F,F,F'
data=[[x],[y],[z]]
a=obj_new('CMMsurface',data,idstring='prova',npx=21,npy=22,edgecut=1,zfactor=-1000.)

;test_basic,a
b=test_duplicate(a)
;obj_destroy,a
help,/heap
end
