;all lenghts internally in angstrom

pro dektat::roiselect,roi_um
  ptr_free,self.roi
  self.roi=ptr_new()
  ;select the ROI
  if n_elements(roi_um) eq 2 then begin
    roi_start=fix(findex(x,roi_um[0]*10000.))+1
    roi_end=fix(findex(x,roi_um[1]*10000.))
    self.x=self.xdata[roi_start:roi_end]
    self.y=self.ydata[roi_start:roi_end]
    self.npoints_roi=roi_end-roi_start+1
    self.roilen=(roi_um[1]-roi_um[0])*10000.
    print,'Selected ROI: ['+strtrim(string(roi_um[0]))+'-'+strtrim(string(roi_um[1]))+' um]'
    print,'points :'+strtrim(string(roi_start))+'-'+strtrim(string(roi_end))+']'
  endif else begin
    print,'No ROI selected'
    self.x=self.xdata
    self.y=self.ydata
    self.npoints_roi=npoints
  endelse
end
;nyRange=[1./(Npoints*xstep),1./(2*xstep)]*10^7 ;Nyquist range in mm^-1

pro dektat::readdata
    readcol,filename,xx,yy,delimiter=','
    x=float(xx) ;in um
    y=float(yy) ;in Angstrom
    x=x[0:npoints-1]
    y=y[0:npoints-1]
    x=x*10000
    ptr_free,self.xdata,self.ydata,self.x,self.y
    self.xdata=ptr_new()
    self.ydata=ptr_new()
    *self.xdata=x
    *self.ydata=y
end

function dektat::Init,filename
    self.filename=filename
    self->readdata
    self->readscanparameters
    return,1
end

pro dektat::readscanparameters
  ;read scan parameters
  filename=self.filename
  ptr_free,self.scan_paramenters
  self.scan_parameters=ptr_new()
  
  sp={struct,scanlen:0d,npoints:0l,xstep:0d}
  tmp=readnamelistvar(filename,'Sclen',separator=',')
  tmp=strsplit(tmp,',',/extract)
  sp.scanlen=float(tmp[0])
  sp.npoints=long(readnamelistvar(filename,'NumPts',separator=','))
  step_um=float(readnamelistvar(filename,'Hsf',separator=','))
  if step_um*npoints ne  scanlen then begin
    msg='Scan lenght, npoints and step length do not agree:'+newline()+$
        'Scan Len: '+strtrim(string(scanlen))+newline()+$
        'Step Len: '+strtrim(string(step_um))+newline()+$
        'Npoints: '+strtrim(string(npoints))+newline()+$
        '-----------------------------'
     message,msg
  endif
  sp.xstep=step_um*10000.
  *self.scan_parameters= sp
end

function dektat::level,grade
  y=self.ydata
  ;remove piston, tilt and sag
  ;(i.e. mean, line and second order legendre polynomial)
  N=n_elements(Y)
  yres=Y
  x=vector(-1.d,1.d,n) ;xvector
  L=max(x)-min(x)
  
  ;legendre normalized polynomials
  Leg0=sqrt(1.d/2)
  Leg1=x*sqrt(3.d/2)
  Leg2=(3.*x^2-1)/2*sqrt(5.d/2)
  
  a0=total(y*Leg0)*L/n
  yres=y-a0*Leg0
  
  a1=total(y*Leg1)*L/n
  Yres=Yres-a1*Leg1
  
  a2=total(y*Leg2)*L/n
  sag=a2*Leg2
  Yres=Yres-sag
  
  return, Yres
end

pro dektat::Cleanup
  ptr_free,self.xdata
  ptr_free,self.ydata
  ptr_free,x
  ptr_free,y
  ptr_free,scan_parameters
end


pro dektat__define
struct={dektat,$
        inherits IDL_object, $
        filename:"",$
        xdata:ptr_new(),$
        ydata:ptr_new(),$
        x:ptr_new(),$
        y:ptr_new(),$
        scan_parameters:ptr_new(),$
        roi:ptr_new(),
        }
end 
