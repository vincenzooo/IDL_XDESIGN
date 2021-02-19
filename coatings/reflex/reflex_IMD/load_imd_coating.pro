
function load_imd_coating,file,lam,ind,mat,th,sigma,subs=subs
  ;+
  ; Create an index matrix(nlayer) reading a coating structure from a text file in IMD format. 
  ; Works as load_nc, but starts from a structure file, rather than from an array of material strings.
  ; Parameters returned can be passed to Fresnel.
  ; This is a reduced version of the format, can be extended to full set of columns.
  ;
  ;   format:
  ;   layer#(1=top)    material    thickness(A)    roughness(A)
  ;   
  ; LAM:   must be provided to interpolate wavelength
  ; IND:   Layer nr.
  ; MAT:   String containing the name of nk material file (no extension)
  ; TH:    List of thickness in A
  ; SIGMA: Roughness/diffuseness in A
  ; SUBS:  String for substrate material
  ;-
  
  readcol,file,ind,mat,th,sigma,comment=';',format='I,A,F,F,X,X,X,X'
  nc = load_nc (lam,[mat,subs])
  return, nc

end
