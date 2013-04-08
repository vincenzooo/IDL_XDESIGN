function checkOverwrite,filename,text=text,title=title
;controlla se un file su cui scrivere gia' esiste,
;in tal caso chiede l'autorizzazione a sovrascrivere.
;restituisce 0 se si puo' sovrascrivere, 1 se il file
;esiste e l'autorizzazione e' negata.

;USO:
; if checkOverwrite(filename) eq 0 then <scrittura file>

  if n_elements (title) eq 0 then title='File existing!'
  if n_elements (text) eq 0 then text="File "+filename+" existing, overwrite?"
  info=file_info(filename)
  protected=0
  if info.exists eq 1 then begin
      if info.write eq 1 then begin 
          answer=dialog_message(text,title=title,/QUESTION)
          if answer eq 'No' then protected=1 
      endif else begin
          res=dialog_message("File "+filename+" existing and not writable!",$
          title='Error writing file!',/INFORMATION)
          protected=1 
      endelse
  endif
  return,protected
  
end