function getwfree, _extra=extra
  ; return number of first free window without opening it (it actually opens and close behind the scene).
  ;non funziona, visto che finestre sopra 32 (aperte con /free), sono diverse
  ;  da quelle sotto (che possono essere aperte con window,wnum)

  ;nota che
  ; Device, Window_State=theseWindows
  ; restituisce in theseWindows un array (di lunghezza 32) che e' uguale a 1
  ;  dove la corrispondente finestra e' aperta. Si puo' iterare per ottenere nr
  ;  sotto 32.

  Device, Window_State=theseWindows ;theseWindows is 65 elements array
  closed = where(theseWindows eq 0,c)
  if c eq 0 then return, !NULL

  return, closed[0]


  ;  window,/free,_extra=extra
  ;  ww=!D.window
  ;  wdelete,ww
  ;  return, ww

end

pro windowfree,w=w,_extra=ex
  ;+
  ;  replacement command for window,/free,...
  ;  differently from original command, doesn't distinguish
  ;  between window numbers below and above 32,
  ;  the number of the created window is in w.
  ;
  ;  uses GETWFREE.
  ;-

  w = getwfree()
  if w ge 32 then begin
    ; first 32 windows were open
    wcheck = w  ;this must match the opened window 
    window,/free,_extra=e
    w=!D.window
    if w ne wcheck then message,'something wrong with handling window numbers'   
  endif else begin
    window,w,_extra=e
  endelse

end

pro test_getwfree


  ;test getwfree
  print, 'test GETWFREE'
  cleanup
  print,'open windows 1 and 3'
  window, 1
  window, 3

  print,'get first available window with GETWFREE (call twice)'  
  print,'first available window: ',getwfree()
  print,'first available window: ',getwfree()
  Device, Window_State=theseWindows
  print,'open windows: ',where(theseWindows,c)
  print,'-------------'
  
  cleanup
  ;open 33 windows
  print,'open windows 0-32'
  for i=0,31 do begin
    window,i
  endfor  
  window,/free   ;open first window above 31 (=32)
  
  print,'get first available window with GETWFREE (call twice)'
  print,'first available window: ',getwfree()
  print,'first available window: ',getwfree()
  Device, Window_State=theseWindows
  print,'open windows: ',where(theseWindows,c)
  print,'-------------'  

end

pro test_windowfree
  ;test windowfree
  print, 'test WINDOWFREE'
  cleanup
  print,'open windows 1 and 3'
  window, 1
  window, 3
  print,'open other two windows with WINDOWFREE'
  
  windowfree,w=w
  print,'opened window: ',w
  windowfree,w=w
  print,'opened window: ',w
  Device, Window_State=theseWindows
  print,'open windows: ',where(theseWindows,c)
  print,'-------------'
  
  cleanup
  ;open 33 windows
  print,'open windows 0-32'
  for i=0,31 do begin
    window,i
  endfor
  window,/free   ;open first window above 31 (=32)
  
  print,'open other two windows with WINDOWFREE'
  windowfree,w=w
  print,'opened window: ',w
  windowfree,w=w
  print,'opened window: ',w
  Device, Window_State=theseWindows
  print,'open windows: ',where(theseWindows,c)
  print,'-------------'
end

test_getwfree
test_windowfree
cleanup

end
