function grid::isdefined
;return 1 if all coordinates are set, 0 if any of them is not set.
;function createGrid,x0=x0,x1=x1,step=step,npoints=npoints
if not ptr_valid(self.grid) then return,0

for i =0,self.ndim-1 do begin
  if not (ptr_valid((*self.grid)[i])) then return,0
  if n_elements *((*self.grid)[i]) eq 0 then return,0
endfor
return,1
end



pro     grid::getproperty,$
        grid=grid,ndim=ndim,$
        _ref_extra=extra
        
        if arg_present(grid) then grid=self
        if arg_present(ndim) then ndim=self.ndim
        
end

function grid::getproperty,$
        grid=grid,ndim=ndim,$
        _ref_extra=extra

        if keyword_set(grid) then return,self
        if keyword_set(ndim) then return,self.ndim   
        
end

pro grid::setproperty,$
        grid=grid,ndim=ndim,$
        _ref_extra=extra
        
end

function grid::getcoord,index
    if n_elements(index) ne 1 then message,'index must be a scalar!' 
    return, *((*self.grid)[index])
end

pro grid::setcoord,grid,index
  if n_elements(index) ne 1 then message,'index must be a scalar!'
  (*self.grid)[index]=creategrid(x0=x0[i],x1=x1[i],np=np[i]) 
end

pro grid::creategrid,grid=grid,np=np,x0=x0,x1=x1

  if obj_valid(grid) eq 0 and n_elements(np) eq 0 then begin
      message,' neither grid or np are set, cannot set grid',/informational
      return
  endif
  if obj_valid(grid) ne 0 and n_elements(np) ne 0 then begin
      message,' grid and np are both set, np will be ignored',/informational
      return
  endif 

  if obj_valid(grid) ne 0 then begin
      ndim=grid->getproperty(/ndim)
      if ndim ne self.ndim then message,'wrong number of dimension for grid: '+string(ndim)+$
          ', instead of '+string(self.ndim)+'.'
      self.grid=grid
  endif else begin
       if self.ndim eq 1 then begin
         if size(np,/n_dimensions) ne 1 and size(np,/n_dimensions) ne 0 then message,'np must be a single vector of dimension'+string(self.ndim)+$
            'it is instead, np='+newline()+string(np)
         if size(x0,/n_dimensions) ne 1 and size(x0,/n_dimensions) ne 0 then message,'x0 must be a single vector of dimension'+string(self.ndim)+$
            'it is instead, x0='+newline()+string(x0)
         if size(x1,/n_dimensions) ne 1 and size(x1,/n_dimensions) ne 0 then message,'x1 must be a single vector of dimension'+string(self.ndim)+$
            'it is instead, x1='+newline()+string(x1)
       endif else begin
         if size(np,/n_dimensions) ne 1 then message,'np must be a single vector of dimension'+string(self.ndim)+$
            'it is instead, np='+newline()+string(np)
         if size(x0,/n_dimensions) ne 1 then message,'x0 must be a single vector of dimension'+string(self.ndim)+$
            'it is instead, x0='+newline()+string(x0)
         if size(x1,/n_dimensions) ne 1 then message,'x1 must be a single vector of dimension'+string(self.ndim)+$
            'it is instead, x1='+newline()+string(x1)
       endelse
       if n_elements(np) ne self.ndim then message,'wrong number of dimension for np: '+string(n_elements(np))+$
        ', instead of '+string(self.ndim)+'.'
       if n_elements(x0) ne self.ndim then message,'wrong number of dimension for x0: '+string(n_elements(x0))+$
        ', instead of '+string(self.ndim)+'.'
       if n_elements(x1) ne self.ndim then message,'wrong number of dimension for x1: '+string(n_elements(x1))+$
        ', instead of '+string(self.ndim)+'.'
       for i =0,self.ndim-1 do begin
         *((*self.grid)[i])=creategrid(x0=x0[i],x1=x1[i],np=np[i])       
       endfor
  endelse
end

function grid::Init,ndim=ndim,grid=grid,np=np,x0=x0,x1=x1
;ndim is defined at start and cannot be changed
;grid can be populated in init or lately, using setcoord or setproperty
; a grid object can be provided, in that case is copied (the object is not destroyed at the ehd)
; in alternative vectors can be provided for np,x0,x1 

    self.ndim=ndim
    grid=ptrarr(self.ndim,/allocate_heap)
    self.grid=ptr_new(grid)
    if obj_valid(grid) or (n_elements(np) ne 0) or $
      (n_elements(x0) ne 0) or (n_elements(x1) ne 0) then self->creategrid,grid=grid,np=np,x0=x0,x1=x1
    return,1
end

pro grid::Cleanup
  for i=0,self.ndim-1 do begin
    ptr_free,(*self.grid)[i]
  endfor
  ptr_free,self.grid
end

pro grid__define
struct={grid,$
        ndim:2,$
        grid:ptr_new()$
        }
end

print,'one dimensional grid'
print,"a=obj_new('grid',ndim=1,x0=0,x1=1,np=10)"
a=obj_new('grid',ndim=1,x0=0,x1=10.,np=11)
help,a
print,'ndim:',a->getproperty(/ndim)
agrid=a->getproperty(/grid)
print,'grid:',agrid
help,agrid
print,'values:'
print,a->getcoord(0)
obj_destroy,a
help,/heap
print,'------------------------'

end
