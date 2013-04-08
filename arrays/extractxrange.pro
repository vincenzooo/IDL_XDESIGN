function extractXrange,x,y,extractedX,xStart=xS,xEnd=xE,xindex=xindex
  ; given an (optional) min and max xvalues in xstart,xend,
  ;extract from the vectors x and y the elements in the range  
  
  if n_elements(xS) eq 0 then xStart=min(x) else xStart=xS
  if n_elements(xE) eq 0 then xEnd=max(x) else xEnd=xE
  if xstart gt xend then message,'ExtractDataRange function error: Lower'+$
    'bound is higher than higher bound. Low, High= ',string(xStart),string(xEnd)
  xindex=where((x ge xstart) and (x le xend),c)
  if c eq 0 then begin
     extractedX=[]
     xindex=[]
     return,[]
  endif
  extractedX=x[xindex]
  return,y[xindex]    
end