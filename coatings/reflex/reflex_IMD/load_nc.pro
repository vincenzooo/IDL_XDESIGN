;load refraction indices using IMD function (moved here from refle_funk_beta. 
; call .run imdstart (or .run IMD and close all windows) before running this code, prompt should change to IMD>


function load_nc,lam, materials,c_mat
  ;carica gli indici di rifrazione. c_mat va passato esplicitamente se c'e'.
  c_flag=0
  if n_elements(c_mat) ne 0 then c_flag=n_elements(c_mat)
  nm=n_elements(materials)
  nl=n_elements(lam)
  nc=complexarr(nm+1+c_flag,nl)
  vac=complexarr(nl)+1  ;il primo strato e' il vuoto
  nc[0,*]=vac
  ;carica gli indici dei materiali dello specchio bare
  ;i materiali vanno nelle ultime colonne
  ;i indica il materiale
  for i= 0,nm-1 do begin
    ;print,i
    ind=IMD_NK(materials[i],lam)
    nc[i+1+c_flag,*]=ind
  endfor
  if c_flag ne 0 then nc[1,*]=IMD_NK(c_mat,lam)
  return,nc
end