pro maketif, filename
;create a tif with the content of the current graphic window
;saving in the file "filename".
;c'era un parametro inutile plottif, l'ho rimosso. Rimuovere dal programma chiamante.

  ;if (!D.name eq 'WIN') then begin
    img=transpose(reverse(transpose(tvrd(true=1))))
    write_tiff,filename+'.tif',img
  ;endif
end