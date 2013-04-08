   if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
       else if keyword_set (noplot) eq 0 then begin   
          if n_elements(w) eq 0 then window,/free else window,w
    endif
    
    if n_elements(psfile) ne 0 then ps_end 