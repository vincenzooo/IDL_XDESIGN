pro marker::setProperty,position=position,label=label, points=points,color=color
  if n_elements(position) ne 0 then self.position=position
  if n_elements(label) ne 0 then self.label=label
  if n_elements(points) ne 0 then self.points=points
  if n_elements(color) ne 0 then self.color=color
end

pro marker::getProperty,position=position,label=label, points=points,color=color
  if arg_present(position) ne 0 then position=self.position
  if arg_present(label) ne 0 then label=self.label
  if arg_present(points) ne 0 then points=self.points
  if arg_present(color) ne 0 then color=self.color
end

pro marker::draw,_extra=extra
  xx=[]
  yy=[]
  foreach p,self.points do begin
    xx=[xx,p[0]]
    yy=[yy,p[1]]
  endforeach
  if n_elements(self.points) ne 0 then plots,[xx,xx[0]],[yy,yy[0]],$
    color=n_elements(color) ne 0?color:self.color,thick=2,linestyle=2,_extra=extra $
  else begin
    beep
    message,"no points defined in markers, no plot.",/info
  endelse
end

pro marker::setRect,rsize
  if n_elements(rsize) gt 2 then message,"Too many elements for size."
  if n_elements(rsize) eq 0 then rsize=0
  if n_elements(rsize) eq 1 then rsize=[rsize,rsize]
  if n_elements(rsize) eq 2 then rsize=[-rsize[0]/2.,rsize[0]/2.,$
                                        -rsize[1]/2.,rsize[1]/2.]
  x0=self.position[0]+rsize[0]
  x1=self.position[0]+rsize[1]
  y0=self.position[1]+rsize[2]
  y1=self.position[1]+rsize[3]
  self.points=list()
  self.points.add,[x0,y0]
  self.points.add,[x1,y0]
  self.points.add,[x1,y1]
  self.points.add,[x0,y1]                                        
end

function marker::Init,position,color=color,label=label
  self.label=n_elements(label) eq 0? '': label
  self.position=position
  if n_elements(color) eq 0 then color=0 $
  else begin
    if size(color,/tname) eq 'STRING' then self.color=cgcolor(color) $
    else self.color=color
  endelse
  self.points=list()
  self.label=n_elements(label) eq 0?"":label
  return,1
end

pro marker__define
struct={marker,$
        label:"",$
        position:fltarr(2),$  ;processed data (e.g. leveled) (2d matrix)
        points:list(),$
        color:0, $
        INHERITS IDL_Object $
        }
end

x=findgen(100)
y=x^2
plot,x,y
m=marker([50,3000],color=cgcolor('red'))
m.setrect,[20,200]
m.draw

end
