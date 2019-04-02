;load refraction indices using IMD function (moved here from refle_funk_beta. 
; call .run imdstart (or .run IMD and close all windows) before running this code, prompt should change to IMD>

function load_nc,lam, matlist,c_mat
  ;carica gli indici di rifrazione. 
  ;c_mat (string with overcoating material) is unnecessary, but it is kept for backwards compatibility.
  
  materials=matlist
  nc=replicate(dcomplex(1,0),n_elements(lam))
  if n_elements(c_mat) ne 0 then materials=[c_mat,materials]
  foreach mat, materials do nc=[[nc],[IMD_NK(mat,lam)]]

  return,transpose(nc)
end

;function load_nc2,lam, materials,c_mat
;  ;this is the old load_nc. I had modified nc and vac from complex to dcomplex to obtain exactly
;  ;  same result as the new version
;  ;carica gli indici di rifrazione. c_mat va passato esplicitamente se c'e'.
;  c_flag=0
;  if n_elements(c_mat) ne 0 then c_flag=n_elements(c_mat)
;  nm=n_elements(materials)
;  nl=n_elements(lam)
;  nc=dcomplexarr(nm+1+c_flag,nl)
;  vac=dcomplexarr(nl)+1  ;il primo strato e' il vuoto
;  
;  nc[0,*]=vac
;  ;carica gli indici dei materiali dello specchio bare
;  ;i materiali vanno nelle ultime colonne
;  ;i indica il materiale
;  for i= 0,nm-1 do begin
;    ;print,i
;    ind=IMD_NK(materials[i],lam)
;    nc[i+1+c_flag,*]=ind
;  endfor
;  if c_flag ne 0 then nc[1,*]=IMD_NK(c_mat,lam)
;  return,nc
;end

en_vec =vector(0.1,10.,4)
lam=12.39845/en_vec

nc1=load_nc(lam,['a-C','Ir','Ni'])
;nc2=load_nc2(lam,['a-C','Ir','Ni'])
;nc3=load_nc2(lam,['Ir','Ni'],'a-C')

;print,"array equal?",array_equal(nc1,nc2)
;print,'range of differences:',range(nc1-nc2)
;print,"array equal?",array_equal(nc2,nc3)
print,nc1
end