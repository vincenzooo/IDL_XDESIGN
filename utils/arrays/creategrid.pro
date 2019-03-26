function createGrid,x0=x0,x1=x1,step=step,npoints=npoints
  ;create a grid according to the settings.

  ;TODO possible cases:
  
  ;x0, x1 and npoints 
  ;x0, x1 and step
  ;x0, npoints and step

  if n_elements(x0) eq 0 then message,'X0 must be set!'
  
  if n_elements(x1) ne 0 then begin
    if (n_elements(npoints) ne 0) and (n_elements(step) ne 0) then $
        message,'Too many arguments: only two among NPOINTS, X1 and STEP'+$
          ' can be set (X0 must always be set).'
    if (n_elements(npoints) eq 0) and (n_elements(step) eq 0) then $
        message,'Not enough valid arguments (only X0 and X1 are set).'
    if (n_elements(step) ne 0) then np=fix((x1-x0)/step)+1 else np=npoints
    grid=vector(x0,x1,np)
  endif else begin  ;x0, npoints and step
    if (n_elements(npoints) eq 0) then $
        message,'Not enough valid arguments (only X0 and STEP are set).'
    if (n_elements(step) eq 0) then $
        message,'Not enough valid arguments (only X0 and NPOINTS are set).'
    grid=indgen(npoints,type=size(step,/type))*step+x0
  endelse
  
  return, grid
end