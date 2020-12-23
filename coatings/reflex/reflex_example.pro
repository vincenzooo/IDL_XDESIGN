; in progress

function interface,angle,ener,materials=materials, lib=lib, loadindex=loadindex
;+
; generic facade between consistent call to reflectivity calculation and 
;   reflectivity calculation library (IMD, IRT or fortran dll, called with
;   appropriate syntax).
;
;-

  
  if keyword_set(loadindex) then begin
    if lib eq 'dll' then  else $
    if lib eq 'imd' then 
    if lib eq 'irt' then refind, materials
  endif  
  
  if lib eq 'dll' then begin
    dllFile='f_dll.so'
    if materials then loadRI,ener,materials[0],materials[1],materials[2],dllFile
    if ~keyword_set(loadindex) then ref= reflexDLL (ener, angle, dSpacing, rough, dll=dllFile ,/unload)
  endif else if lib eq 'imd' begin
    if ~keyword_set(loadindex) then load_nc,lam, materials,c_mat
    Reflex_IMD, th, lam, materials,z,sigma,c_thick,c_mat
  endif else begin
    if ~keyword_set(loadindex) then refind, materials
    ref=tref()
  endelse
  
return ref



pro test_lib_reflex,lib
  ;from reflexDLLexample, adapted to use generic librariese

  ;dllFile='f_dll.so'
	;lancia le routine dll
	
	
	ener=vector(1,80.,1000)
	nbil=200
	a=105.
	b=-0.9
	c=0.27
	gamma=0.35
	dspacing=thicknessPL(a,b,c,nbil,gamma)
	folder=ProgramRootDir()
	;file_dirname(file_which('reflexdllexample.pro',/INCLUDE_CURRENT_DIR))
	
	;dspacing=reverse(dspacing)
	angle=3.5e-3
	rough=4.
	mat1=folder+path_sep()+'af_files\a-Si.dat'
	mat2=folder+path_sep()+'af_files\a-C.dat'
	mat3=folder+path_sep()+'af_files\Pt.dat'

	;loadRI,ener,mat1,mat2,mat3,dllFile
	;ref= reflexDLL (ener, angle, dSpacing, rough, dll=dllFile ,/unload)
	plot, ener,ref

	writecol,'exampleRef.txt',ener,ref
	writecol,'exampleDspac.txt',dSpacing[indgen(nbil)*2],dSpacing[indgen(nbil)*2+1]

end

