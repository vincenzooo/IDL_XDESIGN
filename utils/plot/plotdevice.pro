pro plotDevice,plotRoutine,data,folders,windnum,filename=filename
;chiama la routine di plot sul giusto device, se fornito il filename
;plotta su PS.
;example:
;
;plotDevice,'plotFunction',data,folders,0
;
  if n_elements(filename) eq 0 then wind=windnum else wind=-1
  if wind eq -1 then SET_PLOT, 'PS' else window,windnum 
  if wind eq -1 then DEVICE, filename=filename, /COLOR
  
  call_procedure ,plotRoutine,data,folders,windnum
  if wind eq -1 then  DEVICE, /CLOSE 
  if wind eq -1 then  SET_PLOT, 'WIN' 
end