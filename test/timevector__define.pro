;contains a list of strings indicating time in format hh:mm:ss
;done to test the new object in idl8

function timevector::Init,x,y

    npoints=n_elements(x)
    
    if n_elements(y) ne npoints then $
      message,'Different number of points for x ('+strtrim(string(npoints),2)+') and y('+strtrim(string(n_elements(y)),2)+')'
    
    ;self.npoints=npoints
    self.xdata=list(x,/extract)
    self.ydata=y
    ;if n_elements(label) ne 0 then self.label=label
    return,1
end

pro timevector__define
struct={timevector, $
        xdata:list(), $
        ydata:list() $
        ;INHERITS IDL_Object $
        }
end