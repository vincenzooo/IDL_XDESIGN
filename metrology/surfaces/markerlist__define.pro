;ideally for each of the property (e.g. label, position, etc..) must return a list of 
; the values of the corresponding property for each of the markers in the list.

pro markerList::setProperty,markers=markers
  if n_elements(markers) ne 0 then self.markers=markers
end

pro markerList::getProperty,markers=markers
  if arg_present(markers) ne 0 then markers=self.markers
end

pro markerList::draw,_extra=extra
  foreach m, self.markers do begin
    m->draw,_extra=extra
  endforeach
end

pro markerList::Add,markers
  foreach m,markers do begin
    self.markers.add,m
  endforeach
end  

pro markerList::Remove,markers,all=all
  foreach m,markers do begin
    self.markers.remove,m,all=all
  endforeach
end                

function markerList::Init,markers
  self.markers=list()
  self.add,markers
  return,1
end

          
pro markerList__define
struct={markerList,$
        markers:list(),$
        INHERITS IDL_Object $
        }
end     

x=findgen(100)
y=x^2
plot,x,y
m1=marker([50,3000],color=cgcolor('red'))
m1.setrect,[20,200]
m2=marker([100,5000],color=cgcolor('yellow'))
m2.setrect,[5,100]
m=markerlist([m1,m2])
m.draw

end     