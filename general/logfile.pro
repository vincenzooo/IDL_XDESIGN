function logFile, logU, close=close
;presa da hewoffaxis.pro e in snippets
;ma mi sa che non funziona
;return the suitable file number for a log file:
;- logU is a filename (provided as a string): open it and return the number
;- logU is a number, assumes that is an open file and return the same number
;- logU non e' fornito, usa lo standard output
;------------------------------------------
;USO:
;uf=logFile(logU)
;printf,uf,"log message"
;result=logFile(uf,/close)

if n_elements(close) ne 0 then begin
  free_lun,logU
  return, 0
endif 

logFlag=n_elements(logU)
  if logFlag ne 0 then begin
     tU=size(logU,/type)
     if tU eq 7 then begin   ;e' stringa
        get_lun, logFileN
        openw,logFileN,logU
     endif else begin
       if (tU eq 2) or (tU eq 3) or (tU eq 12) or (tU eq 13) then begin
        logfileN=logU
        ;si potrebbe mettere una funzione che lo crea da data se non gia' aperto
        ;openw,logFileN,'log'+strjoin(strsplit(systime(0),' :',/extract))+'.dat'
       endif else begin
          logFileN=-1 ;standard output
       endelse
     endelse
  endif
  
return, logFileN
  
  
  end