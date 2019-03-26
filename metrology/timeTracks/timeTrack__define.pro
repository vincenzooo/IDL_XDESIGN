;+
; Derived from xydata, it is an xydata object where the x data is
;   a time (special methods and properties to deal with times extend the class).
;-

pro timeTrack::Cleanup
  ;ptr_free,self.xdata
  ;ptr_free,self.ydata
  xydata.cleanup
end

pro timeTrack::readFromFile,filename,cols=cols,format=format,_ref_extra=extra
      ;read data from file and set it in points
    data=read_datamatrix(filename,_extra=extra)
    if n_elements(cols) eq 0 then colindex=1 else colindex=cols
    if n_elements (format) eq 0 then begin
      if n_elements(cols) gt 1 then message,$
        'if no format is set only one column can be used and it must contain the time in seconds'
      self.xdata=data[cols]
    endif else begin
      self.xdata=matrixtojd(data,format,timeCols=Cols,seconds=seconds)
    endelse
end

function timeTrack::Init,x,y,idstring=idstring

;    npoints=n_elements(x)
;    if n_elements(y) ne npoints then $
;      message,'Different number of points for x ('+strtrim(string(npoints),2)+') and y('+strtrim(string(n_elements(y)),2)+')'
;    ;self.xdata=ptr_new(x)
;    ;self.ydata=ptr_new(y)
;    self.xdata=x;list(x,/extract)
;    self.ydata=y;list(y,/extract)
;    self.npoints=n_elements(self.xdata)
;    if n_elements(self.ydata) ne self.npoints  then message, 'Xdata and Ydata have different length.'
;    if n_elements(label) ne 0 then self.label=label
    return,xydata.Init(x,y,idstring=idstring)
end

pro timeTrack__define
struct={timeTrack,$
        format:"",$
        startTime:"",$
        INHERITS xydata $
        }
end

function timeTrack_test
  x=findgen(10)
  y=x^2
  print,'x= ',x
  print,'y= ',y
  ;a=timeTrack(x,y)
  a=obj_new('timetrack',x,y)
  print,'npoints:',a.npoints
  print,'plotting xy data...'
  a.draw
  b=a.extractxrange(xs=3,xe=6.5)
  b.draw,/overplot,color=cgcolor('red'),psym=4
  obj_destroy,b
  return,a
end

pro timeTrack_test
  a=timeTrack_test()
end

a=timetrack_test()

end