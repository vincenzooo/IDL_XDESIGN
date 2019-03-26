;2019/03/25 moved from multilayer (probably used for off axis analytical effective area)
function reflexDLL, ener, angle, dSpacing, rough, dllFile, symbolname=symbolname,unload=unload
;+
; NAME:
; ReflexDLL
;
; PURPOSE:
; Return the reflectivity of a multilayer as a function of energy.
;
; CATEGORY:
; Multilayer
;
; CALLING SEQUENCE:
; Result = REFLEXDLL, Ener, Angle, DSpacing, Rough, DllFile
;
; INPUTS:
; Ener: vector of energy values.
; Angle: angle in radians.
; DSpacing: vector with Dspacing in Angstrom from top (surface) to bottom (substrate).
; Rough: scalar (in this version), roughness of all layers.
;
; OPTIONAL INPUTS:
; DllFile: Dll file containing the FORTRAN compiled routines.
; 
; KEYWORD PARAMETERS:
; /UNLOAD: unload the dll. It should be called in the last execution.
;
; OUTPUTS:
; Vector of reflectivity for energies in Ener 
;
; SIDE EFFECTS:
; If the routine is called without having loaded the refraction index with
; loadRI, it can cause umpredictable results, or simply a crash.
; If the dll is not unloaded, the dll file could result locked to the OS.
; Also the dll remains loaded in memory, I am not able to say what the effects can be.
;
; EXAMPLE:
; See reflexdllexample.pro for a complete working example.
;
; ;Load the refraction indices with loadRI.
; loadRI,ener,mat1,mat2,mat3
; ;this is the last (and only) call: I unload the dll
; ref= reflexDLL (ener, angle, dSpacing, rough,/unload) 
;
; MODIFICATION HISTORY:
;   Written by: Vincenzo Cotroneo (released 16 June 2010).
;   INAF/Brera Astronomical Observatory
;   via Bianchi 46, Merate (LC), 23807 Italy 
;   vincenzo.cotroneo@brera.inaf.it

  if n_elements(dllFile) eq 0 then begin
    ;folder=programrootdir()  ;this sets dll in same folder as this loadRI.
    ;dllFile=folder+'f_dll.dll'
    dllFile='f_dll.dll' ;use current folder
    print,"loadri: default dll at: ",dllFile
  endif

  if n_elements(symbolname) eq 0 then symbolname='readindex'
  
	nener=n_elements(ener)
	reflex=fltarr(nener)
	nl=n_elements(dSpacing)
	if (nl ne fix(nl/2)*2) then dSpacing=[dSpacing,0.0]
	dd=reverse(dspacing)
	nbil=n_elements(dd)
	if n_elements(dllFile) eq 0 then begin
	  folder=ProgramRootDir()
	  dllFile=folder+path_sep()+'f_dll.dll'
  endif
	;r=call_external(dllFile,'readindex',ener,nener,/cdecl)
	r=call_external(dllFile,symbolname,$
		dd,nbil,reflex,nener,angle,rough,/cdecl,unload=unload)
	return,reflex

end