pro setwindow,win,erase=erase,pwin=pwin
;+
; Set a specific windows as current for IDL plot functions.
;if windows is passed and is a valid name (string) reuse or create a window with that name.
; as side effect if invalid (e.g. number or empty array), use current.
; unless /ERASE is set, the window is erased.
; pwin can be used to store the window. This can be passed as current=pwin in plot functions.
;-

  
  if n_elements(win) ne 0 then begin
    ;this could be done by checking if window_title is a property of win, but didn't manage to find how:
    if typename(win) eq 'GRAPHICSWIN' || typename(win) eq 'PLOT' then win=win.window_title
    ;this returns a window, or an array (?) of windows, having name Window:
    pwin=getWindows(win,/current) 
    
    if pwin ne !NULL then pwin.window.setcurrent else pwin=window(name=win)
    if keyword_set(erase) then pwin.erase
  endif
  
end

cleanup

;create a new window and plot test line on it:
setwindow,'test1',pwin=pwin
p=plot(/test,/current)  ;same as plot(/test,current=pwin)

;this create a new window, as default of PLOT:
p2=plot(/test,name='p2') 

;this returns to previous window:
setwindow,'test1'  
p2=plot(/test,'Dr',name='p2red',/overplot)

;same as before, but this time non existing window, create.:
setwindow,'test3'  
p3=plot(/test,'Dr',name='p2red',/overplot)

;notice, it can be done in same way passing the window as current
!null=plot(/test,'Xb',name='p2cross',/overplot,current=pwin)

;same to retrieve a window, but this using a window object.:
setwindow,p3
!null=plot(/test,'ob',name='p2circle',/overplot)

end
