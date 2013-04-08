pro routineWithLog,log=logU
;presa da hewoffaxis.pro

logFlag=n_elements(logU)
  if logFlag ne 0 then begin
     tU=size(logU,/type)
     if tU eq 7 then begin   ;e' stringa
        get_lun, logFileN
        openw,logFileN,folder+path_sep()+logU
     endif else begin
        logFileN=-1 ;standard output
     endelse
  endif
  
  ; dopodiche' scrivere i messagi di log con :
  ;printf,logFileN
  printf,logFileN, "LOG message"
  
  ;alla fine liberare con
  if logFlag ne 0 then free_lun,logFileN
  
  end