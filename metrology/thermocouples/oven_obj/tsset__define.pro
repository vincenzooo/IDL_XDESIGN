; a set of timeseries that can be accessed individually by label or index

pro tsset::append,TS

if self.nseries eq 0 then begin 
  self.timeseries=ptr_new(ts)
  self.nseries=self.nseries+1
endif else begin
  self.timeseries=[self.timeseries,ptr_new(ts)]
  self.nseries=self.nseries+1
endelse
end

pro tsset::remove,index
  if size(index,/type) eq 7 then begin;string
  
  endif else begin ;index 
  ;
  endelse
end

PRO tsset::GetProperty, nseries=nseries

    IF Arg_Present(nseries) THEN nseries=self.nseries

END

function tsset::Init,TS
    ;TODO: put here  a test for the correct type of TS
    if n_elements(TS) ne 0 then self->append,ts
    return,1
end

pro tsset::Cleanup
end

pro tsset__define
  struct={tsset,timeseries:ptr_new(/allocate_heap),nseries:0}  
end

pro tsset_test
  a=obj_new('timeprofile',[1.,2.,3.],[1,6,9])
  b=obj_new('timeprofile',[1.,1.5,2.,3.],[1.1,5,6.1,9.1])
  k=obj_new('tsset')  ;create empty tsset
  k->append,a
  k->append,b
  k->getpropery,nseries=n
  print,'k has ',n,'series, that are:'
end