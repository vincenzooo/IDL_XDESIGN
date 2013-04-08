pro setPlotOutput,close=close,psfile=psfile,window=w,noplot=noplot
;if CLOSE is set, close psfile as ps
;if PSFILE is set a ps file is opened with that name and extension '.eps' appended.
;If it is not passed, a window is opened. The number of the window can be passed
;in WINDOW, if it is not a new window is opened. 

    if keyword_set(close) then begin
       if keyword_set(psfile) ne 0 then ps_end
    endif else begin
       if keyword_set(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
           else if keyword_set (noplot) eq 0 then begin   
              if n_elements(w) eq 0 then window,/free else window,w
       endif
    endelse
    
end