function reflexMatrix,ener, angle,dspacing, rough
;restituisce una matrice di riflettivita' in funzione di energia e angolo.
;gli indici di rifrazione devono essere stati caricati precedentemente.
  
  ntheta=n_elements(angle)
  rmatrix=dblarr(n_elements(ener),ntheta)
  for i =0,ntheta-2 do begin
    ref= reflexDLL (ener, angle[i], dSpacing, rough)
    rMatrix[*,i]=ref
  endfor
  rMatrix[*,ntheta-1]= reflexDLL (ener, angle[ntheta-1], dSpacing, rough, /unload)
  return,rmatrix
end

