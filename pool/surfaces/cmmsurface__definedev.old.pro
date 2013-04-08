;it is a single surface scan
;define the basic operations on a dataset

;CONVENTIONS
;in program and comments
;Rpoints: Raw points (npoints x 3 array)
;Tpoints: Transformed points (npoints x 3 array)
;Vpoints (in comments): Visualization points (2dim matrix, npx x npy) (in the program, these are stored in self.data, inherited by griddata)

;CHANGED FLAGS
;Rchanged: Rpoints have been changed -> recalculate Tpoints at first access.
;Tchanged: Tpoints have been changed -> recalculate Vpoints at first access. 
;N.B.: Vchanged would be unuseful, since there are no data to update if Vpoints are changed.
;TODO: Replace all occurrencies of old self.changed (or check I have removed all of them)

; routines whose name starts with __ are SUPERPRIVATE, they are considered internal routines
; of a method property set/get, they are out of the calling routine only to keep the code
; neat, but they are called from only one point (and they must not be called directly by
; derived classes.

;----------------------------------
;Internal routines used by SETPROPERTY
pro CMMsurface::__setPointsFromData
  ;this routine sets the transformation points from visualization points (self.DATA)
  ;in this routine self.DATA must be accessed directly to avoid infinite loop, 
  ;since this routine is called by SETPROPERTY, DATA = data.
  ;There is no risk for updates, if the routine is kept superprivate 
  ;(double underscore, it is called only by setproperty method).
  
  grid=grid(self->getproperty(/xgrid),self->getproperty(/ygrid))
  self->setproperty,Tpoints=[[grid[*,0]],[grid[*,1]],[reform(*self.data,n_elements(*self.data))]]
end

pro CMMsurface::__setgrid,xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy,edgecut=edgecut
  ;Internal routine used by setproperty.
  ;EDGECUT is the number of points to cut on the edge in format [-x,+x,-y,+y], if a scalar value is provided,
;  this is usedd for all edges. NPX and NPY are the number of points without including the cut ones,
  ;corresponding to the final number of points in the grid

  if n_elements(edgecut) eq 0 then ec=0 else ec=edgecut
  if n_elements(ec) eq 1 then ec=replicate(ec,4)
  
  if n_elements(xgrid) eq 0 then begin 
    if n_elements(npx) ne 0 then begin
      xrange=(range(self->getproperty(/Tpoints)))[*,0] ;range((*self.points)[*,0])
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
    if n_elements(npx) ne 0 then begin
       yrange=range((self->getproperty(/Tpoints))[*,1]) ; range((*self.points)[*,1])
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
  self.Tchanged=1
  
end

pro CMMsurface::__setplane,plane
  ;internal procedure used by setproperty to manage and validate the different cases for
  ;setting the plane. Plane can be a vector or a null scalar (=0).
  ;If it is zero the leveling is reset.
  
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
;----------------------------------
;SETPROPERTY
pro CMMsurface::setproperty,$
        ;filename=filename,$
        idstring=idstring,$
        plane=plane,$
        Tpoints=Tpoints,$ ; processed points (e.g. leveled) (npoints x 3 array)
        data=data,$  ;visualization data  (2d matrix)
        Rpoints=Rpoints,$ ;points as read from file (npoints x 3 array)
        resolution=resolution,$ ;machine resolution in um, used for statistics computation
        xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy,$ ;,ystep=ystep,yrange=yrange,xrange=xrange,xstep=xstep
        zfactor=zfactor,$
        edgecut=edgecut,_ref_extra=extra,$
        rototrans=rototrans
        
        ;if n_elements(filename) ne 0 then self.filename=filename
        if n_elements(idstring) ne 0 then self.idstring=idstring
        if n_elements(resolution) ne 0 then self.resolution=resolution
        if n_elements(zfactor) ne 0 then self.zfactor=zfactor
        
        ;check: only one at once can be changed among Tpoints, RPOINTS and DATA.
        if ((n_elements(Tpoints) ne 0) + (n_elements(Rpoints) ne 0) + (n_elements(data)ne 0)) gt 1 then $
          message,'only one of RPOINTS, TPOINTS and DATA can be set in one call!' 
        if n_elements(Tpoints) ne 0 then begin
          *self.Tpoints=Tpoints
          self.Tchanged=1
        endif
        if n_elements(data) ne 0 then begin 
          self->griddata::setproperty,data=data
          self->__setPointsFromData
        endif
        if n_elements(Rpoints) ne 0 then begin 
          *self.Rpoints=Rpoints
          self.Rchanged=1
        endif
        if (n_elements(xgrid) ne 0 or n_elements(npx) ne 0) and $
        (n_elements(ygrid) ne 0 or n_elements(npy) ne 0) then begin
          self->__setgrid,xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy,edgecut=edgecut
        endif
        if n_elements(plane) ne 0 then self->__setplane,plane
        if n_elements(rototrans) ne 0 then begin
          if n_elements(rototrans) ne 0 then message,"wrong number of elements passed for ROTOTRANS."
          self.rototrans=rototrans
        endif
        self->griddata::setproperty,_extra=extra
end

;----------------------------------
;Internal routines used by GETPROPERTY

pro CMMsurface::__resampleView  ;,flatten=flatten
      ;this is the internal resample function for populating visualization data
      ;starting from Transformed points.
      
      xy=transpose((*self.Tpoints)[*,0:1])
      z=(*self.Tpoints)[*,2]
      ;calling griddata with grid, you have to specify xout and yout,
      ;coordinates of the grid points on two axis
      griddeddata=griddata(xy,z,/grid,xout=*self.xgrid,yout=*self.ygrid)
      *self.data=griddeddata
end


;pro CMMsurface::_level ;,plane
;  ;flatten subtracting self.plane.
;  ;The best fit plane can be obtained by planefit
;  
;  self->getproperty,plane=p0
;  xraw=(*self.Tpoints)[*,0]
;  yraw=(*self.Tpoints)[*,1]
;  zraw=(*self.Tpoints)[*,2]
;  residuals=zraw-(p0[0]*xraw+p0[1]*yraw+p0[2])
;  ;*self.data=resample_surface(xraw,yraw,residuals,xgrid=*self.xgrid,ygrid=*self.ygrid)
;end

pro CMMsurface::_update,Tpoints=Tpoints
  ;update Tpoints and Vpoints. The default update both Vpoints and T points,
  ;to update only Tpoints set the /TPOINTS flag (Tpoints must be updated in any
  ;case, if you want to update Vpoints). 
  
  ;update Tpoints
   if self.Rchanged ne 0 then begin
    (*self.Tpoints)=(*self.Rpoints)[*,*]
    self->level
    self.Tchanged=0
  endif  
  
  if keyword_set(Tpoints) eq 0 then begin
    ;update Vpoints
    if n_elements(*self.xgrid) ne 0 and n_elements(*self.ygrid) ne 0 then begin
      if self.Tchanged ne 0 then begin
        self->__resampleView
        self.Tchanged=0
      endif 
    endif else begin
        if n_elements(*self.xgrid) eq 0 then message, 'Xgrid is not defined',/informational
        if n_elements(*self.ygrid) eq 0 then message, 'Ygrid is not defined',/informational
        message, 'cannot update Vpoints!',/informational
        self.Tchanged=0
        return
    endelse
  endif
  
end

;----------------------------------
;GETPROPERTY
pro     CMMsurface::getproperty,$
        ;filename=filename,$
        idstring=idstring,$
        plane=plane,$
        Tpoints=Tpoints,$ 
        data=data,$ 
        xgrid=xgrid,$
        ygrid=ygrid,$
        zfactor=zfactor,$
        resolution=resolution,_ref_extra=extra,$ ;machine resolution in um, used for statistics computation
        rototrans
        
        if arg_present(data) then data=self->getproperty(/data) ;this must always be the first in this procedure, because it calls the update
        if arg_present(idstring) then idstring=self->getproperty(/idstring)
        if arg_present(plane) then plane=self->getproperty(/plane)
        if arg_present(Tpoints) then Tpoints=self->getproperty(/Tpoints)
        if arg_present(Rpoints) then Rpoints=self->getproperty(/Rpoints)
        if arg_present(xgrid) then xgrid=self->getproperty(/xgrid)
        if arg_present(ygrid) then ygrid=self->getproperty(/ygrid)
        if arg_present(resolution) then resolution=self->getproperty(/resolution) 
        if arg_present(zfactor) then resolution=self->getproperty(/zfactor) 
        if arg_present(rototrans) then rototrans=self->getproperty(/rototrans) 
        self->griddata::getproperty,_extra=extra
end

function CMMsurface::getproperty,$
        ;filename=filename,$
        idstring=idstring,$
        plane=plane,$
        Tpoints=Tpoints,$
        data=data,$  ;processed data (e.g. leveled) (2d matrix)
        Rpoints=Rpoints,$
        xgrid=xgrid,$
        ygrid=ygrid,$
        resolution=resolution,$
        zfactor=zfactor,$
        _ref_extra=_extra,$ ;machine resolution in um, used for statistics computation
        rototrans
        
        if n_params() gt 1 then message,'called with more than one keyword, '+$
          'only the first one (according to the internal program order) will be returned.'
        if keyword_set(data) then begin
          self->_update
          return,*self.data
        endif
        if keyword_set(Tpoints) then begin
          self->_update,/TP
          return,*self.Tpoints
        endif
        if keyword_set(Rpoints) then return,*self.Rpoints
        if keyword_set(rototrans) then return,*self.rototrans
        ;if keyword_set(filename) then return,self.filename
        if keyword_set(idstring) then return,self->griddata::getproperty(/idstring)
        if keyword_set(plane) then return,*self.plane
        if keyword_set(xgrid) then return,self->griddata::getproperty(/xgrid)
        if keyword_set(ygrid) then return,self->griddata::getproperty(/ygrid)
        if keyword_set(resolution) then return,self->griddata::getproperty(/resolution)   
        if keyword_set(zfactor) then return,self->griddata::getproperty(/zfactor) 
        return,self->griddata::getProperty(_extra=_extra)
end

;---
;DATA TRANSFORMATION Methods

pro CMMsurface::reset
;+
;
; NAME:
; RESET
;
; PURPOSE:
; This procedure method restores Tpoints by copying from Rpoints. 
; Reset transformation properties.
; This procedure is also called by all other procedures that have a /RESET 
; option (see methodFunkTemplate).
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; CMMsurface->RESET
;
; MODIFICATION HISTORY:
;   2011/08/04: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-
    
    self->setproperty,Tpoints=self->getproperty(/Rpoints) ;self.Tchanged is set to 1 in the setproperty routine.
    self.Rchanged=0 ;even if they were changed, it doesn't matter, we are going to calculate Tpoints.
    self->setproperty,rototrans=[0.0,0.0,0.0]
    self->setproperty,plane=0
end

;;--------Resample
function CMMsurface::resample,xyout,xout=xout,yout=yout,_extra=extra,$
                reset=reset ;RPoints=RP,TPoints=TP,VPoints=VP
 
    ;+
    ;
    ; NAME:
    ; CMMsurface::resample (Transformation method function)
    ;
    ; PURPOSE:
    ; This function resamples Rpoints ,Tpoints or Vpoints over a new set of points
    ; specified either by XOUT and YOUT, or by XYOUT.
    ; These are not output values, they give the
    ; position of the point for which we want the interpolation output
    ; (called INTERPOLATES in the messy IDL help about GRIDDATA function).
    ;
    ; CATEGORY:
    ; CMMsurface 
    ;
    ; CALLING SEQUENCE:
    ; Result = CMMsurface->RESAMPLE( xyout)
    ;
    ;
    ; INPUTS:
    ; XYOUT: 
    ;
    ; OPTIONAL INPUTS:
    ; XOUT, YOUT:
    ; RESET:
    ; 
    ; KEYWORD PARAMETERS:
    ; RESET: 
    ;
    ; OUTPUTS:
    ; Describe any outputs here.  For example, "This function returns the
    ; foobar superflimpt version of the input array."  This is where you
    ; should also document the return value for functions.
    ;
    ; PROCEDURE:
    ; You can describe the foobar superfloatation method being used here.
    ; You might not need this section for your routine.
    ;
    ; EXAMPLE:
    ;
    ; MODIFICATION HISTORY:
    ;   2011/08/04: Written by Vincenzo Cotroneo, Date.
    ;   Harvard-Smithsonian Center for Astrophysics
    ;   60, Garden street, Cambridge, MA, USA, 02138
    ;   vcotroneo@cfa.harvard.edu
    ;   
    ;-

      
      ;arguments check
      if (n_elements(xout) ne 0) or (n_elements(yout) ne 0 )  then begin
        if n_elements(xyout) ne 0 then message,"Too many arguments set."
        if (n_elements(xout) eq 0) or (n_elements(yout) eq 0 ) then message,"Xout and Yout must be both set (or you can set xyout only)."
      endif else begin
        if n_elements(xyout) eq 0 then message,"Provide values for positions on which to interpolate (use XYOUT only or both XOUT and YOUT)." 
        xout=xyout[*,0]
        xout=xyout[*,1]
      endelse
      
;      ;determine which set of points is used as input
;      if (keyword_set(RP) +keyword_set(TP) +keyword_set(VP)) gt 1 then message,"Set only one flag among RP,TP and VP." 
;      if (keyword_set(RP)) then begin
;        points=self->getproperty(/Rpoints)
;      endif else if (keyword_set(VP)) then begin
;        points=MatrixToPoints(self->getproperty(/Vpoints),x=self->getproperty(/xgrid),y=self->getproperty(/ygrid))
;      endif else begin
        points=self->getproperty(/Tpoints) ;default
;      endelse
      
      xy=transpose((points)[*,0:1]) ;transpose((*self.Tpoints)[*,0:1])
      z=(points)[*,2] ;(*self.Tpoints)[*,2]
      resampled=griddata(xy,z,xout=xout,yout=yout,_extra=extra)
      return, resampled
end 


pro CMMsurface::resample,xyout,xout=xout,yout=yout,_extra=extra,reset=reset
        
      ;resample method procedure: Assign to Tpoints the values of the points resampled (see RESAMPLE function)
      
      resampled=self->resample(xyout,xout=xout,yout=yout,_extra=extra,reset=reset) 
      self->setproperty,Tpoints=resampled
end

;;Crop
function CMMsurface::crop,x,y,index=index,allpoints=points,_extra=extra,reset=reset,$
          RPoints=RP,TPoints=TP,VPoints=VP

;+
;
; NAME:
; CROP (Transformation method function)
;
; PURPOSE:
; This function extract from Tpoints the points inside a rectangular region.      
; if RESET flag is active, reset is performed BEFORE the transformation method. 
; This function is called by the corresponding procedure.
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; Result = CMMsurface->CROP( X,Y)
;
; INPUTS:
; X, Y: two elements arrays with X and Y limits. If any of them is set to zero 
;     the full range for the coordinate is considered.
; 
; KEYWORD PARAMETERS:
; _EXTRA
; RESET: if RESET flag is active, reset method is performed BEFORE the crop.
;
; OUTPUTS:
; Array with coordinates of the extracted points (nselpoints x 3 array).
;
; OPTIONAL OUTPUTS:
; INDEX: index of the selected points.
; ALLPOINTS: return the complete set of starting points.
; 
; PROCEDURE:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;   2011/08/04: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-  
      ;check if flags are correctly set
      if (keyword_set(RP) +keyword_set(TP) +keyword_set(VP)) gt 1 then message,"Set only one flag among RP,TP and VP." 
      ;RESET if selected
      if keyword_set(reset) then self->reset
      
      ;arguments check      
      if (keyword_set(RP)) then begin
        points=self->getproperty(/Rpoints)
      endif else if (keyword_set(VP)) then begin
        points=MatrixToPoints(self->getproperty(/Vpoints),x=self->getproperty(/xgrid),y=self->getproperty(/ygrid))
      endif else begin
        points=self->getproperty(/Tpoints) ;default
      endelse
      
      xp=points[*,0]
      yp=points[*,1]
      zp=points[*,2]
      if n_elements(x) eq 1 then begin
        if x ne 0 then message,'scalar value not recognized for x (if scalar can be set only to 0 to keep all points).'
        x=range(xp)
      endif else if n_elements(x) ne 2 then message,'wrong number of elements for x'
      if n_elements(y) eq 1 then begin
        if y ne 0 then message,'scalar value not recognized for y (if scalar can be set only to 0 to keep all points).'
        y=range(yp)
      endif else if n_elements(y) ne 2 then message,'wrong number of elements for y'
      
      index=where(points[*,0] le x[1] and points[*,0] ge x[0] and $
                 points[*,1] le y[1] and points[*,1] ge y[0],c)
      if c eq 0 then begin
        message,"No points in the crop interval, return -1"
        return,-1
      endif else return, points[index,*]
      
end

pro CMMsurface::crop,x,y,index=index,allpoints=points,_extra=extra,reset=reset,$
          RPoints=RP,TPoints=TP,VPoints=VP
         
;+
;
; NAME:
; CROP (Transformation method procedure)
;
; PURPOSE:
; This procedure assigns to Tpoints the values of the points after CROP.
; See CMMsurface::CROP function.
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; CMMsurface->CROP,X,Y
;
; PROCEDURE:
; Development notes: the procedure could be modified by removing the explicit 
; RESET keyword (it can be passed as _extra).
;
;-
      
      result=self->crop(x,y,index=index,allpoints=points,_extra=extra,reset=reset,$
          RPoints=RP,TPoints=TP,VPoints=VP) 
      self->setproperty,Tpoints=result
end

;CLIP
function CMMsurface::CLIP, min=min,max=max,clipvalue=clipvalue,addmarker=addmarker,$
    nsigma=nsigma, refimage=refimage,mask=mask,summary=summary,torefimage=torefimage,$
    _extra=extra,reset=reset,RPoints=RP,TPoints=TP,VPoints=VP
  ;TODO accept a CMMsurface as refimage
  ;TODO if ADDMARKER is set a marker is added for clipped points 
      
;+
;
; NAME:
; CMMsurface::CLIP (method function)
;
; PURPOSE:
; This function returns datapoints after clipping
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; Result = CMMsurface->CLIP()
;
; For clip parameters and keywords, see Clip function documentation.
; 
; KEYWORD PARAMETERS:
; /Rpoints,/Tpoints,/Vpoints: set which dataset is used for starting values (defaults is Tpoints)
; /RESET: if flag is active, reset is performed BEFORE the transformation method.
;
; MODIFICATION HISTORY:
;   2011/08/04: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-
      ;check if flags are correctly set
      if (keyword_set(RP) +keyword_set(TP) +keyword_set(VP)) gt 1 then message,"Set only one flag among RP,TP and VP." 
      ;RESET if selected
      if keyword_set(reset) then self->reset
      
      ;arguments check
      if (keyword_set(RP)) then begin
        points=self->getproperty(/Rpoints)
      endif else if (keyword_set(VP)) then begin
        points=MatrixToPoints(self->getproperty(/Vpoints),x=self->getproperty(/xgrid),y=self->getproperty(/ygrid))
      endif else begin
        points=self->getproperty(/Tpoints) ;default
      endelse
      
      zfactor=self.zfactor
      points=points*zfactor
  
      clippeddata=clip(points, min=min,max=max,clipvalue=clipvalue,nsigma=nsigma,$
          refimage=refimage,mask=mask,summary=summary,torefimage=torefimage,$
          _strict_extra=extra)
      clippeddata=clippeddata/zfactor

      ;do operations on points and return result
      return, clippeddata
      
end


pro CMMsurface::clip,_extra=extra
;+
;
; NAME:
; CMMsurface::CLIP (method procedure)
;
; PURPOSE:
; This procedure assigns to Tpoints the values of the points after clipping... 
; ;(see CMMsurface::CLIP function)
;
; CATEGORY:
; CMMsurface 
;
; MODIFICATION HISTORY:
;   2011/08/04: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-
  
  clippeddata=self->clip(_extra=extra)

  self->setproperty,Tdata=clippeddata
  
end


;planefit
function CMMsurface::planefit,PLANE=PLANE,_extra=extra,reset=reset,$
          RPoints=RP,TPoints=TP,VPoints=VP
;+
;
; NAME:
; PLANEFIT (method function)
;
; PURPOSE:
; This function fits the best plane to a set of points (default Tpoints).      
; This function is called by the corresponding procedure.
; The plane parameters are returned in PLANE.
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; Result = CMMsurface->PLANEFIT()
; 
; KEYWORD PARAMETERS:
; /Rpoints,/Tpoints,/Vpoints: set which dataset is used for starting values (defaults is Tpoints)
; /RESET: if flag is active, reset is performed BEFORE the transformation method.
; 
; OUTPUTS:
; A Npoints x 3 array with x, y ,z coordinates of leveled points.
;
; OPTIONAL OUTPUTS:
; PLANE is a 3-elements vector with plane parameters in the form [A,B,C] with z = Ax + By + C 
;
; PROCEDURE:
; Use the PLANE_FIT routine
;
; MODIFICATION HISTORY:
;   2011/08/04: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-
  
    ;check if flags are correctly set
    if (keyword_set(RP) +keyword_set(TP) +keyword_set(VP)) gt 1 then message,"Set only one flag among RP,TP and VP." 
    ;RESET if selected
    if keyword_set(reset) then self->reset
    
    ;arguments check
    if (keyword_set(RP)) then begin
      points=self->getproperty(/Rpoints)
    endif else if (keyword_set(VP)) then begin
      points=MatrixToPoints(self->getproperty(/Vpoints),x=self->getproperty(/xgrid),y=self->getproperty(/ygrid))
    endif else begin
      points=self->getproperty(/Tpoints) ;default
    endelse
    
    plane=plane_fit(points[*,1],points[*,1],points[*,1])
  
end

pro CMMsurface::planefit,idstring=newidstring
  ;+
  ;
  ; NAME:
  ; PLANEFIT (method procedure)
  ;
  ; PURPOSE:
  ; This procedure assigns to Tpoints the values of the points after <describe operation>... 
  ; ;(see <routineName> function)
  ;
  ; CATEGORY:
  ; CMMsurface 
  ;
  ; CALLING SEQUENCE:
  ; CMMsurface-> PLANEFIT
  ;-
  
  self->setproperty,plane=self->planefit(),idstring=newidstring
  if n_elements(newidstring) ne 0 then self->setproperty,idstring=newidstring
end

;--TRANSFORM METHODTEMPLATE FUNCTION AND ROUTINE--
function CMMsurface::transformMethodTemplate,args,_extra=extra,reset=reset,$
          RPoints=RP,TPoints=TP,VPoints=VP
      
;;transformMethodTemplate: 
;;Template for a transformation method function. (REMOVE THESE LINES)
;+
;
; NAME:
; ROUTINE_NAME (method function)
;
; PURPOSE:
; This function returns the result of <describe operation> on Tpoints.      
; This function is called by the corresponding procedure.
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; Result = CMMsurface->ROUTINE_NAME( Parameter1, Parameter2, Foobar)
;
; Note that the routine name is ALL CAPS and arguments have Initial
; Caps. 
;
; INPUTS:
; Parm1:  Describe the positional input parameters here. Note again
;   that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
; Parm2:  Describe optional inputs here. If you don't have any, just
;   delete this section.
; 
; KEYWORD PARAMETERS:
; /Rpoints,/Tpoints,/Vpoints: set which dataset is used for starting values (defaults is Tpoints)
; /RESET: if flag is active, reset is performed BEFORE the transformation method.
; 
; OUTPUTS:
; Describe any outputs here.  For example, "This function returns the
; foobar superflimpt version of the input array."  This is where you
; should also document the return value for functions.
;
; OPTIONAL OUTPUTS:
; Describe optional outputs here.  If the routine doesn't have any, 
; just delete this section.
;
; COMMON BLOCKS:
; BLOCK1: Describe any common blocks here. If there are no COMMON
;   blocks, just delete this entry.
;
; SIDE EFFECTS:
; Describe "side effects" here.  There aren't any?  Well, just delete
; this entry.
;
; RESTRICTIONS:
; Describe any "restrictions" here.  Delete this section if there are
; no important restrictions.
;
; PROCEDURE:
; You can describe the foobar superfloatation method being used here.
; You might not need this section for your routine.
;
; EXAMPLE:
; Please provide a simple example here. An example from the
; DIALOG_PICKFILE documentation is shown below. Please try to
; include examples that do not rely on variables or data files
; that are not defined in the example code. Your example should
; execute properly if typed in at the IDL command line with no
; other preparation. 
;
;       Create a DIALOG_PICKFILE dialog that lets users select only
;       files with the extension `pro'. Use the `Select File to Read'
;       title and store the name of the selected file in the variable
;       file. Enter:
;
;       file = DIALOG_PICKFILE(/READ, FILTER = '*.pro') 
;
; MODIFICATION HISTORY:
;   2011/08/04: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-
      
      ;check if flags are correctly set
      if (keyword_set(RP) +keyword_set(TP) +keyword_set(VP)) gt 1 then message,"Set only one flag among RP,TP and VP." 
      ;RESET if selected
      if keyword_set(reset) then self->reset
      
      ;arguments check
      if (keyword_set(RP)) then begin
        points=self->getproperty(/Rpoints)
      endif else if (keyword_set(VP)) then begin
        points=MatrixToPoints(self->getproperty(/Vpoints),x=self->getproperty(/xgrid),y=self->getproperty(/ygrid))
      endif else begin
        points=self->getproperty(/Tpoints) ;default
      endelse

      ;do operations on points and return result
      return, points
      
end

;--LEVEL FUNCTION AND ROUTINE--
function CMMsurface::LEVEL,plane,_extra=extra,reset=reset,$
          RPoints=RP,TPoints=TP,VPoints=VP,removedPlane=removedPlane
;+
;
; NAME:
; LEVEL (method function)
;
; PURPOSE:
; This function returns the result of level on Tpoints.  
; PLANE is a 3-elements vector with plane coefficients A,B,C.  
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; Result = CMMsurface->LEVEL( plane)
; 
; KEYWORD PARAMETERS:
; /Rpoints,/Tpoints,/Vpoints: set which dataset is used for starting values (defaults is Tpoints)
; /RESET: if flag is active, reset is performed BEFORE the transformation method.
; 
; OUTPUTS:
; The leveled data in format X,y,z
;
; OPTIONAL OUTPUTS:
; Describe optional outputs here.  If the routine doesn't have any, 
; just delete this section.
;
;
; MODIFICATION HISTORY:
;   2011/08/17: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-
      
      ;check if flags are correctly set
      if (keyword_set(RP) +keyword_set(TP) +keyword_set(VP)) gt 1 then message,"Set only one flag among RP,TP and VP." 
      ;RESET if selected
      if keyword_set(reset) then self->reset
      
      if n_elements(plane) eq 0 then message,"PLANE argument not provided to LEVEL function. " else begin
        A=plane[0]
        B=plane[1]
        C=plane[2]
      endelse
      
      ;arguments check
      if (keyword_set(RP)) then begin
        points=self->getproperty(/Rpoints)
      endif else if (keyword_set(VP)) then begin
        points=MatrixToPoints(self->getproperty(/Vpoints),x=self->getproperty(/xgrid),y=self->getproperty(/ygrid))
      endif else begin
        points=self->getproperty(/Tpoints) ;default
      endelse
      
      x=points[0,*]
      y=points[1,*]
      z=A*x + B*y + C 
      ;do operations on points and return result
      return, points-z
      
end

pro CMMsurface::level,plane,_extra=extra,reset=reset
      
;+
;
; NAME:
; LEVEL (method procedure)
;
; PURPOSE:
; This procedure assigns to Tpoints the values of the points after level 
; ;(see LEVEL function)
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; CMMsurface->LEVEL, Parameter1, Parameter2, Foobar
;
; MODIFICATION HISTORY:
;   2011/08/04: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-
      if n_elements(plane) ne 0 then self->setproperty,plane=plane
      result=self->level(self->getproperty(/plane),_extra=extra,reset=reset) 
      self->setproperty,Tpoints=result
end
;--end LEVEL FUNCTION AND ROUTINE--




pro CMMsurface::transformMethodTemplate,args,_extra=extra,reset=reset
      
;;transformMethodTemplate: 
;;Template for a transformation method procedure. (REMOVE THESE LINES)
;+
;
; NAME:
; ROUTINE_NAME (method procedure)
;
; PURPOSE:
; This procedure assigns to Tpoints the values of the points after <describe operation>... 
; ;(see <routineName> function)
;
; CATEGORY:
; CMMsurface 
;
; CALLING SEQUENCE:
; CMMsurface->ROUTINE_NAME, Parameter1, Parameter2, Foobar
;
; Note that the routine name is ALL CAPS and arguments have Initial
; Caps.
;  
; --- Remove all the following if identical to the function
; INPUTS:
; Parm1:  Describe the positional input parameters here. Note again
;   that positional parameters are shown with Initial Caps.
;
; OPTIONAL INPUTS:
; Parm2:  Describe optional inputs here. If you don't have any, just
;   delete this section.
; 
; KEYWORD PARAMETERS:
; KEY1: Document keyword parameters like this. Note that the keyword
;   is shown in ALL CAPS!
;
; KEY2: Yet another keyword. Try to use the active, present tense
;   when describing your keywords.  For example, if this keyword
;   is just a set or unset flag, say something like:
;   "Set this keyword to use foobar subfloatation. The default
;    is foobar superfloatation."
;
; OUTPUTS:
; Describe any outputs here.  For example, "This function returns the
; foobar superflimpt version of the input array."  This is where you
; should also document the return value for functions.
;
; OPTIONAL OUTPUTS:
; Describe optional outputs here.  If the routine doesn't have any, 
; just delete this section.
;
; COMMON BLOCKS:
; BLOCK1: Describe any common blocks here. If there are no COMMON
;   blocks, just delete this entry.
;
; SIDE EFFECTS:
; Describe "side effects" here.  There aren't any?  Well, just delete
; this entry.
;
; RESTRICTIONS:
; Describe any "restrictions" here.  Delete this section if there are
; no important restrictions.
;
; PROCEDURE:
; Development notes: the procedure could be modified by removing the explicit 
; RESET keyword (it can be passed as _extra).
;
; EXAMPLE:
; Please provide a simple example here. An example from the
; DIALOG_PICKFILE documentation is shown below. Please try to
; include examples that do not rely on variables or data files
; that are not defined in the example code. Your example should
; execute properly if typed in at the IDL command line with no
; other preparation. 
;
;       Create a DIALOG_PICKFILE dialog that lets users select only
;       files with the extension `pro'. Use the `Select File to Read'
;       title and store the name of the selected file in the variable
;       file. Enter:
;
;       file = DIALOG_PICKFILE(/READ, FILTER = '*.pro') 
;
; MODIFICATION HISTORY:
;   2011/08/04: Written by Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;   
;-

      result=self->transformMethodTemplate(args,_extra=extra,reset=reset) 
      self->setproperty,Tpoints=result
end
;--end TRANSFORMMETHODTEMPLATE FUNCTION AND ROUTINE--


function CMMsurface::duplicate
        
        result=obj_new('CMMsurface',$
                  self->getproperty(/Tpoints),$
                  self->getproperty(/idstring))
        result->setproperty,xgrid=self->getproperty(/xgrid),$
                            ygrid=self->getproperty(/ygrid),$
                            plane=self->getproperty(/plane),$
                            resolution=self->getproperty(/resolution),$
                            zfactor=self->getproperty(/zfactor)
        return,result
end



function CMMsurface::sphereFit,toll=toll,_extra=extra,residuals=residuals,psfile=psfile,window=w
  xgrid=self->getproperty(/xgrid)
  ygrid=self->getproperty(/ygrid)
  grid=grid(xgrid,ygrid)
  data=self->getproperty(/data)
  surfpoints=[[grid[*,0]],[grid[*,1]],[reform(data,n_elements(data))]]
  
  result=spherefit(surfpoints,toll=toll,residuals=residuals,weight=1/sqrt(grid[*,0]^2+grid[*,1]^2))
  residuals=reform(residuals,n_elements(xgrid),n_elements(ygrid))
  
  zfactor=self->getproperty(/zfactor)
  
  zr=range(residuals)*zfactor
  if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
     else if keyword_set (noplot) eq 0 then begin   
        if n_elements(w) eq 0 then window,/free else window,w
  endif
  cgimage, residuals*zfactor,xgrid,ygrid, position=plotpos, /Save,/scale,$
          /Axes,/keep_aspect,minus_one=0,xrange=range(xgrid),yrange=range(ygrid),$
          minvalue=zr[0],maxvalue=zr[1],$
          AXKEYWORDS={XTITLE:'X (mm)',YTITLE:'Y (mm)',title:'Residuals'}
  if n_elements(divisions) eq 0 then divisions=6
  if (zr[1]-zr[0])/divisions lt 1. then format='(g0.2)'
  cgcolorbar,/vertical,range=zr,divisions=divisions,$
          format=format,position=[0.93,0.2,0.96,0.8],charsize=charsize,title=bartitle
  if n_elements(psfile) ne 0 then ps_end
  
  
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
    statssurface=self->getstats(/table,$
                outvars=outvars,/surface,noplot=noplot,_extra=extra)
    statsplane=self->getstats(/table,$
                outvars=outvars,/plane,/noplot,_extra=extra)  
    statsplane=statsplane->transpose(/destroy)
    stats=statssurface->join(statsplane,/destroy)
   endif  
   
  self->_update
  ;single keywords set  
  if keyword_set(surface) then stats=self->griddata::getStats(/table,noplot=noplot,$
                outvars=outvars,locations=locations,hist=hist,header=header,window=w,$
                psfile=psfile,_extra=extra)
  
  if keyword_set(resampling) then begin
    ;get data
    xraw_1=(self->getproperty(/Tpoints))[*,0]  
    yraw_1=(self->getproperty(/Tpoints))[*,1]
    zraw_1=(self->getproperty(/Tpoints))[*,2]*self.zfactor
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
          if n_elements(w) eq 0 then window,/free else window,w
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
  
  return,stats->write(table=table,string=string,_extra=extra)
  
end

pro CMMsurface::load_data,x,y,z
  self->setproperty,Rpoints=[[x],[y],[z]]
end

pro CMMsurface::plotpoints,oplot=oplot,_extra=extra,$
    Rpoints=RP

    if keyword_set(RP) then points=self->getproperty(/Rpoints) $
      else points=self->getproperty(/Tpoints)
    xraw_1=points[*,0]  
    yraw_1=points[*,1]
    if keyword_set(oplot) then oplot,xraw_1,yraw_1,_extra=extra $
    else plot,xraw_1,yraw_1,_extra=extra
    
end

pro CMMsurface::plotResampling,silent=silent,noplot=noplot,$
    Stats=Stats,psfile=psfile,table=table,window=w,$
    diststats=diststats,_extra=extra,oplot=oplot,psym=psym,color=color,$
    Rpoints=RP
    
    ;if table is set, return stats as a table object.
    ;if silent is set, do not print stats (not printed 
    ;in any case if table is set).
  
  if n_elements(color) ne 2 then color= [cgcolor('red'),cgcolor('blue')]
  if n_elements(psym) ne 2 then psym= [1,4]
  ;plot of resampled points
  diststats=self->getstats(/resampling,/string,/noplot,_extra=extra)
    if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
       else if keyword_set (noplot) eq 0 then begin   
          if n_elements(w) eq 0 then window,/free else window,w
       endif
    
    if keyword_set(RP) then points=self->getproperty(/Rpoints) $
      else points=self->getproperty(/Tpoints)
    xraw_1=points[*,0]  
    yraw_1=points[*,1]
    xgrid=self->getproperty(/xgrid)
    ygrid=self->getproperty(/ygrid)
    gridMat=grid(xgrid,ygrid)
    rr=squarerange([xraw_1,xgrid],[yraw_1,ygrid],expansion=1.05)      
    if keyword_set(oplot) eq 0 then plot,[0],[0],/nodata,xrange=rr[0:1],yrange=rr[2:3],/isotropic,title=self.idstring,$
      background=cgcolor('white'),color=cgcolor('black'),_extra=extra
     self->plotpoints,psym=psym[0],color=color[0],symsize=1,/oplot,_extra=extra
     self->plotgrid,psym=psym[1],symsize=1,color=color[1],/oplot,_extra=extra
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



pro CMMsurface::rotate,angle,center,x0,y0
  data=self->getproperty(/data)
  if n_elements(center) eq 0 then pt=[0.0,0.0]
  data=rot(data,angle,1.0,/interp,/pivot,missing=min(data))
  self->setproperty,data=data
end

pro CMMsurface::rotategrid,angle,center,x0,y0
  data=self->getproperty(/data)
  if n_elements(center) eq 0 then pt=[0.0,0.0]
  data=rot(data,angle,1.0,/interp,/pivot,missing=min(data))
  self->setproperty,data=data
end

function CMMsurface::subtract,scan2,destroy=destroy,idstring=idstring
    ;create a copy to not alter self value
  tmp=self->duplicate()
  tmp->setproperty,xgrid=scan2->getproperty(/xgrid),ygrid=scan2->getproperty(/ygrid)
    ;store plane values and reset planes to zero
  planeself=tmp->getproperty(/plane)
  tmp->setproperty,plane=0
  planescan2=scan2->getproperty(/plane)
  scan2->setproperty,plane=0
    ;diff is performed on unflattened data
  diff=tmp->griddata::subtract(scan2,idstring=idstring)
  diff->setproperty,plane=planeself-planescan2
  obj_destroy,tmp
  if keyword_set(destroy) then begin
    obj_destroy,self
    obj_destroy,scan2
  endif else scan2->setproperty,plane=planescan2
  return,diff
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

function CMMsurface::Init,points,idstring,$
        plane=plane,$ 
        data=data,$  ;points as read from file (npoints x 3 array)
        resolution=resolution,$ ;machine resolution in um, used for statistics computation
        zfactor=zfactor,$
        xgrid=xgrid,xrange=xrange,xstep=xstep,npx=npx,$
        yrange=yrange,ystep=ystep,ygrid=ygrid,npy=npy,edgecut=edgecut,rototrans=rototrans
    
    self.Rchanged=0
    self.Tchanged=0
    self.Rpoints=ptr_new(/allocate_heap)  ;points as read from file (npoints x 3 array)
    self.Tpoints=ptr_new(/allocate_heap)  ;points for processed data (npoints x 3 array)
    self.plane=ptr_new(dblarr(3))
    self->setproperty,data=data,Rpoints=points
    if n_elements(zfactor) eq 0 then zfactor=1000.
    if n_elements(rototrans) eq 0 then rototrans=[0,0,0]
    if n_elements(resolution) eq 0 then self.resolution=0.1d else self.resolution=resolution
    if n_elements(edgecut) eq 0 then edgecut=1 
    result=self->griddata::Init(data,idstring,$
        resolution=resolution,zfactor=zfactor)
    self->setproperty,$
        plane=plane,$
        xgrid=xgrid,npx=npx,$
        ygrid=ygrid,npy=npy,edgecut=edgecut
    return,result
end

pro CMMsurface::Cleanup
  ptr_free,self.Tpoints
  ptr_free,self.Rpoints
  ptr_free,self.plane
  self->griddata::Cleanup
end

pro CMMsurface__define
struct={CMMsurface,$
        inherits griddata,$
        plane:ptr_new(),$
        Rpoints:ptr_new(),$  ;points as read from file (npoints x 3 array)
        Tpoints:ptr_new(),$  ;processed (e.g. leveled or rotated) points (npoints x 3 array)
        Tchanged:0, $
        Rchanged:0 $
;        idstring:"",$
;        data:ptr_new(),$  ;grid data  (2d matrix)
;        xgrid:ptr_new(),$
;        ygrid:ptr_new(),$
;        resolution:0.1d, $ ;vertical resolution, used for statistics computation
;        zfactor:1000. $
        }
end

set_plot_default
;file='E:\work\work_ratf\run2b\2011_03_07\latact_test\Moore-Scan-Vert-surface-0V.dat' ;windows
file='/export/cotroneo/work/work_ratf/run2b/2011_03_07/latact_test/Moore-Scan-Vert-surface-0V.dat' ;unix
readcol,file,z,x,y,format='X,F,F,F'
data=[[x],[y],[z]]
a=obj_new('CMMsurface',data,'prova',npx=21,npy=22,edgecut=1)
;a=obj_new('CMMsurface',data,'prova',npx=23,npy=24,edgecut=0)
;window,1
a->draw,title='Unleveled',/nointerp
a->plotResampling,/table,stats=stats
;a->setproperty,plane=a->planefit()
a->planefit
print,'plane=',a->getproperty(/plane)
a->draw,title='Leveled',/nointerp
;obj_destroy,a
;help,/heap
end