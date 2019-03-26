pro setStandardDisplay,notek=notek,ct=ct,_extra=e

device, decomposed =0
cgloadct, (n_elements(ct) eq 0?39:ct),_extra=e
if keyword_set(notek) eq 0 then tek_color

!x.style=!x.style or 1  ;set axis range as exact 
!y.style=!y.style or 17 ;set axis range as exact and ynozero
end