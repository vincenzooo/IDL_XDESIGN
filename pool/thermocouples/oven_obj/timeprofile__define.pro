;set of x and y data.



PRO timeprofile::GetProperty,xdata=xdata,ydata=ydata, npoints=npoints, offset=offset,label=label

    IF Arg_Present(npoints) THEN npoints = self->getproperty(/npoints)
    IF Arg_Present(offset) THEN offset = self->getproperty(/offset)
    IF Arg_Present(label) THEN label = self->getproperty(/label)
    IF Arg_Present(xdata) THEN label = self->getproperty(/xdata)
    IF Arg_Present(ydata) THEN label = self->getproperty(/ydata)

END

function timeprofile::GetProperty, xdata=xdata,ydata=ydata,npoints=npoints, offset=offset,label=label

    IF keyword_set(npoints) THEN return, n_elements(*self.xdata)
    IF keyword_set(offset) THEN return, self.offset
    IF keyword_set(label) THEN return, self.label
    if keyword_set(xData) then return,*self.xdata
    if keyword_set(yData) then return,*self.ydata

END
 
;function timeprofile::x 
;  ;return the x vector
;  return, *self.xdata
;end
;
;function timeprofile::y 
;  ;return the y vector
;  return, *self.ydata
;end

;PRO PlotParams::SetProperty, Color=color, Linestyle=linestyle
;
;   IF N_Elements(color) NE 0 THEN self.color = color
;   IF N_Elements(linestyle) NE 0 THEN self.linestyle = linestyle
;
;END

pro timeprofile::Cleanup
  ptr_free,self.xdata
  ptr_free,self.ydata
end

pro timeprofile_test
  a=obj_new('timeprofile',[1.,2.,3.],[1,6,9])
  a->getproperty,npoints=np
  print,np
  plot, a.xdata,a.ydata
end

function timeprofile::Init,x,y,label=label

    npoints=n_elements(x)
    if n_elements(y) ne npoints then $
      message,'Different number of points for x ('+strtrim(string(npoints),2)+') and y('+strtrim(string(n_elements(y)),2)+')'
    self.xdata=ptr_new(x)
    self.ydata=ptr_new(y)
    *self.xdata=x
    *self.ydata=y
    if n_elements(label) ne 0 then self.label=label
    return,1
end

pro timeprofile__define
struct={timeprofile,$
        filename:"",$
        label:"",$
        offset:0.0d,$
        xdata:ptr_new(),$
        ydata:ptr_new(), $
        INHERITS IDL_Object $
        }
end

