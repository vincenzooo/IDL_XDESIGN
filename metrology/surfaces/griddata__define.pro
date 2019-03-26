;+
;it is a basic set of data (2d Map with a grid of coordinates).
;IMPORTANT: This class should be used for visualization only by inheriting classes, 
;these are responsable for loading the data each time they are changed. 
;Operations on data should not be performed inside this class.
;
;XGRID and YGRID can be set only by giving a suitable vector (more complex methods
;can be put in derived classes).
;The grid and the map are set independently, there is no way to check them
;for consistency when they are set because we don't know which one is set first.
;The only check (same number of elements) is performed at the moment
;of accessing data i.e. when data are plotted or written on file (the calculation of statistics 
;do not access the data).
;There is a ZFACTOR property that determines the different scaling of the z axis
;(e.g. zfactor=1000. if x and y are in mm and z in microns).

;POINTS is accessed like a property, but it is a frontend for DATA, converting
; to and from [3 x N] (POINTS) to [n x m] format (DATA).

;2012/08/30 added congrid instructions to draw with the SQUARE option 
;  to obtain square plots. The image is resampled to the dimension with more pixelse

pro     griddata::getproperty,$
        idstring=idstring,$
        data=data,$  ;processed data (e.g. leveled) (2d matrix)
        points=points,$
        xgrid=xgrid,$
        ygrid=ygrid,$
        resolution=resolution,$ ;resolution for z, used for statistics computation (set the binsize)
        zfactor=zfactor
        
        if arg_present(idstring) then idstring=self->getproperty(/idstring)
        if arg_present(xgrid) then xgrid=self->getproperty(/xgrid)
        if arg_present(ygrid) then ygrid=self->getproperty(/ygrid)
        if arg_present(resolution) then resolution=self->getproperty(/resolution) 
        if arg_present(zfactor) then zfactor=self->getproperty(/zfactor) 
        if arg_present(data) then data=self->getproperty(/data)
        if arg_present(points) then points=self->getproperty(/points)
end

function griddata::roiAverage,xr,yr,outside=outside,i_inside=inside_i,i_outside=outside_i
;extract the average height inside a square region delimited by
;XR and YR.  
  
  points=self->getproperty(/points)
  pixel_i=where(points[*,0] le xr[1] and points[*,0] ge xr[0],c,$
      ncomplement=nc,complement=outside_i)
  if c eq 0 or nc eq 0 then message, 'no points in interval'
  tmp=where(points[pixel_i,1] le yr[1] and points[pixel_i,1] ge yr[0],c,$
    ncomplement=nc,complement=outside_tmp)
  if c eq 0 or nc eq 0 then message, 'no points in interval'
  outside_i=[outside_i,pixel_i[outside_tmp]]
  inside_i=pixel_i[tmp]
  
  inside=total((points[inside_i,2]))/n_elements(inside_i)
  outside=total((points[outside_i,2]))/n_elements(outside_i)
  
  return, inside
end

pro griddata::smooth,xwidth,ywidth,_extra=extra
;smooth the data with the number of points selected in xwidth and ywidth 
  ;it should not stay here (griddata should be a class for visualization,
  ;not data operations).
  
  data=self->getproperty(/data)
  data=smooth(data,[xwidth,ywidth],/edge_truncate)
  self->setproperty,data=data
  
end

function griddata::getproperty,$
        idstring=idstring,$
        data=data,$  ;processed data (e.g. leveled) (2d matrix)
        points=points,$
        xgrid=xgrid,$
        ygrid=ygrid,$
        resolution=resolution,$ ;machine resolution in um, used for statistics computation
        zfactor=zfactor
        
        if n_params() gt 1 then message,'called with more than one keyword, '+$
          'only the first one (according to the internal program order) will be returned.'
        if keyword_set(data) then return,*self.data
        if keyword_set(points) then begin
          self->getproperty,data=data,xgrid=xgrid,ygrid=ygrid
          points=matrixtopoints(reform(data),xgrid,ygrid)
        endif
        if keyword_set(idstring) then return,self.idstring
        if keyword_set(xgrid) then return,*self.xgrid
        if keyword_set(ygrid) then return,*self.ygrid
        if keyword_set(resolution) then return,self.resolution        
        if keyword_set(zfactor) then return,self.zfactor
end

pro griddata::setproperty,$
        idstring=idstring,$
        data=data,$  ;processed data (e.g. leveled) (2d matrix)
        resolution=resolution,$ ;machine resolution in um, used for statistics computation
        zfactor=zfactor,$
        xgrid=xgrid,ygrid=ygrid ;,ystep=ystep,yrange=yrange,xrange=xrange,xstep=xstep
        
        if n_elements(idstring) ne 0 then self.idstring=idstring
        if n_elements(resolution) ne 0 then self.resolution=resolution
        if n_elements(data) ne 0 then *self.data=data
        if (n_elements(xgrid) ne 0) then *self.xgrid=xgrid
        if (n_elements(ygrid) ne 0) then *self.ygrid=ygrid
        if (n_elements(zfactor) ne 0) then self.zfactor=zfactor
end

function griddata::getStats,string=string,table=table,noplot=noplot,$
          outvars=outvars,locations=locations,hist=hist,header=header,$
          psfile=psfile,nbins=nbins,binsize=binsize,w=w,_ref_extra=extra
  
  if n_elements(nbins) eq  0 and n_elements(binsize) eq 0 then $ 
    if n_elements(self.resolution) eq 0 then message,'RESOLUTION is not set!' else binsize=self.resolution
  data=self->getproperty(/data)*self.zfactor
  if n_elements(outvars) eq 0 then ov=[10,0,1,2,3,4] else ov=outvars
  header=histostats(/header,outvars=ov)
  if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch else $
        if keyword_set(noplot) eq 0 then $
          if n_elements(w) eq 0 then window,/free,_extra=extra else window,w,_extra=extra
          
  stats=histostats(data,binsize=binsize,nbins=nbins,noplot=noplot,$
                   outvars=ov,stats=stats,locations=locations,hist=hist,/matrix,$
                   string=string,table=table,vecnames=self.idstring,_extra=extra,/normalize,$
                   xtitle='Z (um)',ytitle='Fraction of points')
  if n_elements(psfile) ne 0 then PS_End
  return,stats
end

pro griddata::getstats,_extra=extra
  a=self->getstats(_extra=extra)
  if n_elements(a) eq 1 then if obj_valid(a) then obj_destroy,a
end

pro griddata::translate,xyz
  if n_elements(xyz) ne 3 then message,'The argument for TRANSLATE must be a 3-element vector!' 
  xoffset=xyz[0]
  yoffset=xyz[1]
  zoffset=xyz[2]
  zfactor=self->getproperty(/zfactor)
  self->setproperty,xgrid=self->getproperty(/xgrid)+xoffset
  self->setproperty,ygrid=self->getproperty(/ygrid)+yoffset
  self->setproperty,data=self->getproperty(/data)+zoffset/zfactor
end

pro griddata::writeonfile,file,matrix=matrix,noaxis=noaxis,zfactor=zfactor
    ;write processed data on FILE. If MATRIX is set write as a matrix (otherwise three columns with coordinates.
    ;Usually if MATRIX is select, write x and y values in first row and column, if NOAXIS is selected the 
    ;x and y values are not written.
    ;if ZFACTOR is set data, the property ZFACTOR is used to rescale data.
    
    self->getproperty,data=data,xgrid=x,ygrid=y
    xygrid=grid(x,y)
    if keyword_Set(zfactor) then data=data*self.zfactor
    
    if keyword_set(noaxis) eq 0 then begin
      xx=x
      yy=y
    endif  
    if keyword_set(matrix) then write_datamatrix,fn(file),data,x=xx,y=yy $
    else writecol,fn(file),xygrid[*,0],xygrid[*,1],reform(data,n_elements(Data))

end

pro griddata::plotgrid,oplot=oplot,_extra=extra

    gridmat=grid(self->getproperty(/xgrid),self->getproperty(/ygrid))
    if keyword_set(oplot) then $
      oplot,gridmat[*,0],gridmat[*,1],_extra=extra $
    else plot,gridmat[*,0],gridmat[*,1],_extra=extra
    
end

function griddata::subtract,scan2,destroy=destroy,idstring=idstring
    
    if  not(array_equal(*self.xgrid,*scan2.xgrid)) then begin 
        message,'different xgrid for scans'+$
        newline()+self.idstring+' and '+scan2.idstring+'.'+newline()+$
        'Resampling on grid 2 (scan1 is modified).',/informational 
        self->setproperty,xgrid=scan2->getproperty(/xgrid)
    endif
    if  not(array_equal(*self.ygrid,*scan2.ygrid)) then begin
        message,'different ygrid for scans'+$
        newline()+self.idstring+' and '+scan2.idstring+'.'+newline()+$
        'Resampling on grid 2 (scan1 is modified).',/informational 
        self->setproperty,ygrid=scan2->getproperty(/ygrid)
    endif
    
    idstring=n_elements(idstring) ne 0? idstring:(self.idstring+'-'+scan2.idstring)
    ;result=obj_new(obj_class(Self),ptr_new(/allocate_heap),idstring=idstring)
    result=self->duplicate()
    result->setproperty,idstring=idstring
    ;result->setProperty,xgrid=*self.xgrid,ygrid=*self.ygrid
    ;TODO add a resampling here
    data=self->getproperty(/data)-scan2->getproperty(/data)
    result->setproperty,data=data
    if keyword_set(destroy) then begin
      obj_destroy,self
      obj_destroy,scan2
    endif
    return, result
end

pro griddata::markerAdd,marker
    ;this should be done in a more proper way overloading the foreach method of
    ;markerlist ?
    foreach m, marker.markers do begin 
      (self.markers).Add,marker
    endforeach
end

pro griddata::markerRemove,index,label=label
    if n_elements(label) ne 0 then begin
      if n_elements(index) ne 0 then message,"label and index cannot be both set!"
      for i=0,n_elements(self.markers)-1 do begin
        if self.markers[i] eq label then index=i
      endfor
    endif else begin
      if n_elements(index) eq 0 then BEGIN
        message,"label and index cannot are both unset, remove last marker!",/info
        beep
        index=n_elements(self.markers)-1
      endif
    endelse
    
    self.markers.remove,index
end

pro griddata::markerReset
    self.markers.remove,/all
end

pro griddata::draw,zrange=zrange,nodefault=nodefault,title=title,$
    charsize=charsize,legend=leg,divisions=divisions,format=format,$
    psfile=psfile,window=w,tridimensional=tridimensional,_extra=extra,$
    bartitle=bt,square=square,rotx=rotx,rotz=rotz,destroy=destroy,$
    idstring=idstring,interactive=interactive,nocloseps=nocloseps,tif=tif,$
    nomarkers=nomarkers,contour=contour,xsmooth=xsmooth,ysmooth=ysmooth,$
    realsize=realsize
    
    ;2012/09/03 commands added to the square keyword. Data are resized with congrid
    ; to have same number of points on x and y. It is still not the way it should work,
    ; but it allows to plot data on a square range. 
    ;TODO: what do I want from a plot? Usually I want the size of the plot to respect
    ; the physical units of X and Y axis that are the same unit.
    ; I want to add a key work to expand one of the axis, e.g. in case of narrow strips
    ;   (in which the extend of one dimension is much smaller than the other).
    ; Screen pixels are squares, so in case one dimension has more points than the other,
    ;    
    ; 
    ;2012/07/24 added contour keyword. Pass /fill to overwrite the image with filled contoura.
  
    if n_elements(*self.xgrid) eq 0 or n_elements(*self.ygrid) eq 0 then begin
        if n_elements(*self.xgrid) eq 0 then message, 'Xgrid is not defined',/informational
        if n_elements(*self.ygrid) eq 0 then message, 'Ygrid is not defined',/informational
        message, 'cannot draw!',/informational
        return
    endif
    
    tvlct,r_st,g_st,b_st,/get	;get the current color table to be restored at the end
    if n_elements(idstring) ne 0 then self->setproperty,idstring=idstring
;    if n_elements (bt) eq 0 then bartitle = 'Z ('+greek('mu',ps=(keyword_set(psfile) or keyword_set(tif)))+'m)'$
;      else bartitle= bt 
    if n_elements (bt) eq 0 then bartitle = 'Z (um)'$;'Z ('+greek('mu')+'m)'$
      else bartitle= bt 
         
    data=self->getproperty(/data)*self.zfactor
    if n_elements(xsmooth) eq 0 then xsm=1 else xsm=xsmooth
    if n_elements(ysmooth) eq 0 then ysm=1 else ysm=ysmooth
    data=smooth(data,[xsm,ysm],/edge_truncate)
    x=self->getproperty(/xgrid)
    y=self->getproperty(/ygrid)
    npx=n_elements(x)
    npy=n_elements(y)
    xstep=range(x,/size)/(npx-1)
    ystep=range(y,/size)/(npy-1)
    if npx ne (size(data,/dimensions))[0] then $
      message,'The number of points in XGRID ('+string(npx,format=i0)+$
          ') does not correspond to the number of x points in DATA ('+string((size(data,/dimensions))[0],format=i0)+').'
    if n_elements(y) ne (size(data,/dimensions))[1] then $
      message,'The number of points in YGRID ('+string(npy,format=i0)+$
          ') does not correspond to the number of y points in DATA ('+string((size(data,/dimensions))[1],format=i0)+').'
    ;the range is calculated in such a way to make the value correspond to the centers of pixels
;    if keyword_set(square) then begin
;        rr=squarerange(range(x)+[-xstep/2.,xstep/2.], $
;        range(y)+[-ystep/2.,ystep/2.],expansion=1.0)
;        data=congrid(data,npx>npy,npx>npy,/center) 
;        if npx gt npy then y=congrid(y,npx) else x=congrid(x,npy)
;        npx=npx>npy
;        npy=npx>npy
;    endif else rr=[range(x),range(y)]+[-xstep/2.,xstep/2.,-ystep/2.,ystep/2.] 
    rr=[range(x),range(y)]+[-xstep/2.,xstep/2.,-ystep/2.,ystep/2.]    
    
    if n_elements(zrange) eq 0 then zr=range(data) else zr=zrange
    if keyword_set(nodefault) eq 0 then setstandarddisplay,/notek,_extra=extra
    if n_elements(title) eq 0 then tit=self.idstring else tit=title
    
    if keyword_set(interactive) then begin
          cgsurface,data,x,y,/ele,/shaded,_extra=extra
    endif else begin
      if keyword_set (realsize) eq 0 then begin
        if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch,charsize=1. $
        else if n_elements(w) eq 0 then window,/free else window,w
      endif else begin
            ;this part uses z buffer to produce a realsize image
            ;from http://www.idlcoyote.com/graphics_tips/nowindow.html
            thisDevice = !D.Name
            Set_Plot, 'Z', /COPY
            Device, Set_Resolution=[npx,npy], Z_Buffer=0,Set_Pixel_Depth=24, Decomposed=1
            Erase    
      endelse
      if keyword_set(tridimensional) then begin
         datascl=bytscl(data,zr[0],zr[1],top=249)
         reg_st=!P.region
         !P.region=[0.05,0,0.93,1.0]
         cgsurf,data,x,y,xtitle='X (mm)',ytitle='Y (mm)',ztitle='Z (um)',charsize=2,/ele,$
              zrange=zr,title=title,xcharsize=1.5,rotx=rotx,rotz=rotz,$
              ycharsize=1.5,zcharsize=1.5,/save,charthick=1.2,shades=datascl,/shaded,_extra=extra
         cgsurf,data,x,y,xtitle='X (mm)',ytitle='Y (mm)',ztitle='Z (um)',charsize=2,$
              zrange=zr,title=title,xcharsize=1.5,thick=1.2,rotx=rotx,rotz=rotz,$
              ycharsize=1.5,zcharsize=1.5,/noerase,charthick=1.2,color=0,_extra=extra
         cgcolorbar,range=zr,title=bartitle,$
            position=[0.1,0.92,0.80,0.95],ncolors=250,/vertical
         !P.region=reg_st
;         if keyword_set(contour) then $
;            cgContour, data, xgrid,ygrid, Position=position, C_Colors=c_colors,$
;              /Outline,/overplot,label=1,fill=fill,_extra=extra
      endif else begin
      plotpos=[0.3,0.2,0.9,0.8]
      if n_elements(charsize) eq 0 then charsize=!P.charsize
;        cgimage, data, position=plotpos,ncolors=255,/Save,/scale,$
;          /Axes,/keep_aspect,xrange=rr[0:1],yrange=rr[2:3],minus_one=0,$
;          minvalue=zr[0],maxvalue=zr[1],/fit_inside,$
;          AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',TITLE:tit,charsize:charsize},_extra=extra
      ;cgimage seems unable to plot with 'isotropic' axis (same length on screen for same length
      ; on axis).
      
      if keyword_set(square_pixel) then asp=float(npy)/npx $
          else asp=abs((rr[3]-rr[2])/(rr[1]-rr[0]))
      imdisp,data,xrange=rr[0:1],yrange=rr[2:3],_extra=extra,color=0,back=255,$
            /axis,aspect=asp,/Save,range=zr,position=plotpos, $
            XTITLE='X (mm)',YTITLE='Y (mm)',TITLE=tit,charsize=charsize
        
        if n_elements(divisions) eq 0 then divisions=6
        if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
         if keyword_set(contour) then $
            cgContour, data, xgrid,ygrid, C_Colors=c_colors,$
              /Outline,_extra=extra,/onimage
        ;for some reason I am not able to have a colorbar with 
        ;   discrete filled contours if /fill is set 
        cgcolorbar,/vertical,range=zr,ncolors=255,$
          format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize;,title=bartitle;,_extra=extra
          ;set legend: if leg='' nolegend, if not provided set default, otherwise use the value provided
        cgtext,0.945,0.87,bartitle,align=0.5,/normal,charsize=charsize
        if n_elements(leg) eq 1 then if leg eq '' then begin
          if n_elements(psfile) ne 0 and keyword_set(nocloseps) eq 0 then ps_end,tif=tif,_extra=extra
          if keyword_set(destroy) then obj_destroy,self
          return
        endif
        if not keyword_Set(nomarkers) then begin
          foreach m, self.markers do begin
            m->draw
          endforeach
        endif
        
        if n_elements(leg) eq 0 then leg=self->getstats(/string,/noplot,_extra=extra)
        legend,leg,maxwidth=plotpos[0],position=[0.15,0.5],color=replicate(cgcolor('black'),n_elements(leg)),$
               /nolines,charsize=charsize,t_color=0
  ;      endif else legend,leg,position=[0.15,0.5],color=replicate(0,n_elements(leg)),/nolines,charsize=charsize,_extra=extra,t_color=0
      endelse
    endelse
    if keyword_set(realsize) then begin
      snapshot = TVRD()
      TVLCT, r, g, b, /Get
      Device, Z_Buffer=1  ;leave it enabled so you will not forget next time
      Set_Plot, thisDevice,/copy
      image24 = BytArr(3, npx, npy)
      image24[0,*,*] = r[snapshot]
      image24[1,*,*] = g[snapshot]
      image24[2,*,*] = b[snapshot]
      Write_JPEG, psfile+'.jpg', image24, True=1, Quality=100
    endif else if n_elements(psfile) ne 0 and keyword_set(nocloseps) eq 0 then $
        ps_end,tif=tif,_extra=extra
    tvlct,r_st,g_st,b_st
    if keyword_set(destroy) then obj_destroy,self
  
end

function griddata::duplicate,idstring=idstring

        if n_elements(idstring) eq 0 then ids=self->getproperty(/idstring) else ids=idstring
        result=obj_new('griddata',self->getproperty(/data),$
        idstring=ids)
        result->setproperty,xgrid=self->getproperty(/xgrid),$
                            ygrid=self->getproperty(/ygrid),$
                            resolution=self->getproperty(/resolution),$
                            zfactor=self->getproperty(/zfactor)
        return,result
end

function griddata::addNoise,sigma,seed=seed
    nx=n_elements(self->getproperty(/xgrid))
    ny=n_elements(self->getproperty(/ygrid))
    noise=randomn(seed,nx,ny)*sigma
    a=self->duplicate()
    a->setproperty,data=a->getproperty(/data)+noise
end

function griddata::Init,data,idstring=idstring,resolution=resolution,$ 
                        xgrid=xgrid,ygrid=ygrid,zfactor=zfactor 
        ;machine resolution in um, used for statistics computation
    
        self.data=ptr_new(/allocate_heap)  ;processed data (e.g. leveled) (2d matrix)
        self.xgrid=ptr_new(/allocate_heap)
        self.ygrid=ptr_new(/allocate_heap)
        self.zfactor=n_elements(zfactor) ne 0?zfactor:1d0
        self.markers=list()
        ;if n_elements(filename) eq 0 then filename=''
        self->setproperty,$
            idstring=idstring,$
            data=data,$  ;processed data (e.g. leveled) (2d matrix)
            resolution=resolution,$ ;machine resolution in um, used for statistics computation
            xgrid=xgrid,ygrid=ygrid
        return,1
end

pro griddata::Cleanup
  ptr_free,self.data
  ptr_free,self.xgrid
  ptr_free,self.ygrid
end

pro griddata__define
struct={griddata,$
        idstring:"",$
        data:ptr_new(),$  ;processed data (e.g. leveled) (2d matrix)
        xgrid:ptr_new(),$
        ygrid:ptr_new(),$
        resolution:0.1d, $ ;vertical resolution, used for statistics computation
        zfactor:1000., $
        markers:list() $
        }
end

cd, programrootdir()
outfolder='test'+path_sep()+'griddata'
file_mkdir,outfolder
set_plot_default
npx=13
npy=11
data=randomu(1,[npx,npy])
if obj_valid(a) then obj_destroy,a
a=obj_new('griddata',data,idstring='id_prova',xgrid=vector(10.,30.,npx),ygrid=vector(-5.,5.,npy),zfactor=1000.,resolution=0.1d)
a->draw,title='Griddata::draw',back=255
maketif,outfolder+path_sep()+'griddata_test_draw'
stats=a->getstats(title='Griddata::getstats',/table,nbins=20)
maketif,outfolder+path_sep()+'griddata_test_getstats'
a->writeonfile,outfolder+path_sep()+'test_griddata_matrix.dat',/matrix
a->writeonfile,outfolder+path_sep()+'test_griddata_points.dat'
help,stats
obj_destroy,stats
obj_destroy,a
help,/heap
end
  
