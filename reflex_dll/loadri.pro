;2019/03/25 moved from multilayer (probably used for off axis analytical effective area)
pro loadRI, ener, substrate,bottom,top, dllFile, symbolname, unload=unload
	;+
	;load the multilayer refraction index for a mulatilayer
	;don't set unload to keep in memory.
	; substrate,bottom,top -> filenames
	; Symbolname: (added 2019/02/15, allow to change the name of the function
	;   called in the dll. In particular can be used to test or compensate for
	;   name mangling of compiler. 
	;   e.g. gfortran uses __<module_name_all_small_fonts>__MOD_<functionname>
	;-
	
	
	if n_elements(dllFile) eq 0 then begin
        folder=programrootdir()
        dllFile=folder+'f_dll.dll'
    endif
    
    if n_elements(symbolname) eq 0 then symbolname='readindex'
  
    b_mat1=byte(substrate)
	b_mat2=byte(bottom)
	b_mat3=byte(top)
	l1=n_elements(b_mat1)
	l2=n_elements(b_mat2)
	l3=n_elements(b_mat3)
	nener=n_elements(ener)

	r=call_external(dllFile,symbolname,ener,nener,$
		b_mat1,l1,b_mat2,l2,b_mat3,l3,/cdecl,unload=unload)

end
