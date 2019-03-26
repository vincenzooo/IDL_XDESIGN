;it is a single dataset (profile)
;define the basic operations on a dataset

pro CMMprofile::read_data

end

pro CMMprofile::resample,xgrid,ygrid

end

pro CMMprofile::subtract,scan2

end

function CMMprofile::Init,filename,idstring,xgrid,ygrid
    self.filename=filename
    self->read_data,filename
    if n_elements(xgrid) ne 0 and n_elements(ygrid) ne 0 then self->resample,xgrid,ygrid
    return,1
end


pro CMMprofile::Cleanup
  if self.written eq 0 then self->write
  ptr_free,rawdata
  ptr_free,xgrid
  ptr_free,ygrid
end

pro CMMprofile__define
struct={CMMprofile,$
        filename:"",$
        idstring:"",$
        type:"",$
        rawdata:ptr_new(),$
        data:ptr_new(),$
        xgrid:ptr_new(),$
        ygrid:ptr_new()$
        }
end