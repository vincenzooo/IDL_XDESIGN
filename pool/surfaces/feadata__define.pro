;function read_data,nodesfile=nodesfile,deffile=deffile,skip=skip,colorder=colorder,$
;                   deviations=deviations,numlines=numline,noshift=noshift
;    
;    if n_elements(nodesfile) ne 0 then nodesfile=fn(nodesfile)
;    if n_elements(deffile) ne 0 then deffile=fn(deffile)
;    
;    if strlen(nodesfile) ne 0 then begin
;      ;read nodes
;      readcol,nodesfile,col0,col1,col2,format='X,F,F,F'
;    endif
;    cols=[[col0],[col1],[col2]]
;    xdata=cols[*,(colorder)[0]-1]
;    ydata=cols[*,(colorder)[1]-1]
;    zdata=cols[*,(colorder)[2]-1]
;    points=[[xdata],[ydata],[zdata]]
;    if strlen(deffile) ne 0 then begin
;  ;      ;read deformations    
;        if n_elements(skip) eq 0 then skip=18
;        readcol,deffile,xd0,xd1,xd2,format='X,F,F,F,X,X,X',skip=skip,numline=numline
;    endif
;    
;    cols=[[col0],[col1],[col2]]
;    xshift=cols[*,(colorder)[0]-1]
;    yshift=cols[*,(colorder)[1]-1]
;    zshift=cols[*,(colorder)[2]-1]
;    if keyword_set(noshift) eq 0 then begin
;      xshift=xshift*0
;      yshift=yshift*0
;    endif
;    
;    if strlen(nodesfile) ne 0 then begin
;      points=[[col0],[col1],[col2]]
;      if keyword_set(deviations) then points[*,2]=points[*,2]*0 ;consider only the deviation in z
;      if strlen(deffile) ne 0 then points=points+[[xshift],[yshift],[zshift]]
;      if (size(points,/dimensions))[0] ne n_elements(zshift) then message, "Number of points not matching in simulation files."
;    endif else begin
;      if strlen(deffile) eq 0 then message,"Both NODESFILE and DEFFILE are not defined!"
;      points=[[xshift],[yshift],[zshift]]
;    endelse
;    
;    return,points
;end

function read_data,nodesfile=nodesfile,deffile=deffile,skip=skip,scaleCoeff=scale,$
                   deviations=deviations,numlines=numline,noshift=noshift
    
    if n_elements(nodesfile) ne 0 then nodesfile=fn(nodesfile)
    if n_elements(deffile) ne 0 then deffile=fn(deffile)
    if n_elements(scale) eq 0 then scaleCoeff=findgen(n_elements(deffile))+1 else scaleCoeff=scale
    
    if strlen(nodesfile) ne 0 then begin
      ;read nodes
      readcol,nodesfile,col0,col1,col2,format='X,F,F,F'
    endif
    
    if n_elements(deffile) ne 0 then begin
         if n_elements(skip) eq 0 then skip=18
         xd=0
         yd=0
         zd=0
         ;read deformations    
         for i=0,n_elements(deffile)-1 do begin
              readcol,deffile[i],xd0,yd0,zd0,format='X,F,F,F,X,X,X',skip=skip,numline=numline
              zd=zd+zd0*scaleCoeff[i]
              if keyword_set(noshift) eq 1 then begin
                  xd=xd+xd0*0
                  yd=yd+yd0*0
              endif else begin
                  xd=xd+xd0*scaleCoeff[i]
                  yd=yd+yd0*scaleCoeff[i]
              endelse
         endfor
    endif

    if strlen(nodesfile) ne 0 then begin
      points=[[col0],[col1],[col2]]
      if keyword_set(deviations) then points[*,2]=points[*,2]*0 ;consider only the deviation in z
      if n_elements(deffile) ne 0 then points=points+[[xd],[yd],[zd]]
      if (size(points,/dimensions))[0] ne n_elements(zd) then message, "Number of points not matching in simulation files."
    endif else begin
      if n_elements(deffile) eq 0 then message,"Both NODESFILE and DEFFILE are not defined!"
      points=[[xd],[yd],[zd]]
    endelse
    
    return,points
end

function FEAdata::Init,idstring,nodesfile=nodesfile,deffile=deffile,_extra=extra,$
                  deviations=deviations,skip=skip,numlines=numlines,noshift=noshift,$
                  colorder=colorder, scaleCoeff=scaleCoeff
    ;2012/09/18 added multifile support. Deffile can be an array (or list) of filenames.
    ;   a n optional SCALECOEFF array of rescaling coefficients with the same lenght can be passed. 
    ; Also, corrected condition check on keyword_set(noshift).
    
    self.colorder=ptr_new(/allocate_heap)
    if n_elements(colorder) eq 0 then *self.colorder=[1,2,3] else *self.colorder=colorder
    points=read_data(nodesfile=nodesfile,deffile=deffile,skip=skip,deviations=deviations,$
                      noshift=noshift,numlines=numlines, scaleCoeff=scaleCoeff)
    if n_elements(idstring) eq 0 then $
        self.idstring=(strlen(self.deffile) ne 0)?file_basename(self.deffile):file_basename(self.nodesfile)
    return,self->CMMsurface::init(points,idstring=self.idstring,zfactor=1000,_extra=extra)
end



pro FEAdata::Cleanup
  self->CMMSurface::Cleanup
end

pro FEAdata__define
struct={FEAdata,$
        nodesfile:'',$
        deffile:'',$
        colorder:ptr_new(),$
        inherits CMMsurface $
        }
end

cd, programrootdir()
set_plot_default
setstandarddisplay,/notek
!P.charsize=1.0

deffile=fn('test\feadata\100mm_round_1p5um_w_str_gauge_6pt_bc13.dat')
nodesfile='test\feadata\100mm_round_nodes.txt'
a=obj_new('FEAdata',nodesfile=nodesfile,deffile=deffile,idstring='simulation',npx=21,npy=22,edgecut=1,numl=31681)
;obj_new('FEAdata',deffile=deffile,idstring='simulation',xgrid=xg,ygrid=yg,edgecut=1);obj_new('FEAdata',nodesfile,deffile,npx=21,npy=22,edgecut=1)

end
