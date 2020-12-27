;2020/06/11 not sure about the purpose of this function (tests added today),
;  clearly made to uniform output device, but not sure what was the principle.
;  There are no usage examples, can probably be removed or improved,
;  e.g.: incorporating this mechanism:
;      if !D.Name eq 'WIN' || !D.Name eq 'X' then window,ww,xsize=600,ysize=400 else $
;      device,filename=filename+string(ww)+'.'+!D.name
;  TODO: remove 



pro setPlotOutput,close=close,psfile=psfile,window=w,noplot=noplot
;if CLOSE is set, close psfile as ps
;if PSFILE is set a ps file is opened with that name and extension '.eps' appended.
;If it is not passed, a window is opened. The number of the window can be passed
;in WINDOW, a new window is opened if not already open. 

    if keyword_set(close) then begin
       if keyword_set(psfile) ne 0 then ps_end
    endif else begin
       if keyword_set(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
           else if keyword_set (noplot) eq 0 then begin   
              if n_elements(w) eq 0 then window,/free else window,w
       endif
    endelse
    
end

pro make_test_plot
    setstandarddisplay
    plot,[1,2,3],[1,4,9],title='powers',color=0,background=1,yrange=[0,30]
    oplot,[1,2,3],[1,8,27],color=2
end

;outfolder = 'tests'+path_sep()+'setplotoutput'
cleanup   ;close all windows
window,1  ;make simple plot on window 1
make_test_plot

;this is unwanted behavior (I think):
window,2  ;created empty
;create window 3, but /noplot suppress output
setplotoutput,window=3,/noplot  ;noplot simply do nothing, not sure why it is there.
make_test_plot ;as a consequence, this is plotted on window 2



end