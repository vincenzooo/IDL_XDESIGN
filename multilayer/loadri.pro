pro loadRI, ener, substrate,bottom,top, dllFile,unload=unload
	;load the multilayer refraction index for a mulatilayer
	;don't set unload to keep in memory.
	; substrate,bottom,top -> filenames
	
	;folder=''
	if n_elements(dllFile) eq 0 then begin
    folder=file_dirname((routine_info('loadRI',/SOURCE)).PATH)+path_sep()
    dllFile=folder+'f_dll.dll'
  endif
  
  b_mat1=byte(substrate)
	b_mat2=byte(bottom)
	b_mat3=byte(top)
	l1=n_elements(b_mat1)
	l2=n_elements(b_mat2)
	l3=n_elements(b_mat3)
	nener=n_elements(ener)

	r=call_external(dllFile,'readindex',ener,nener,$
		b_mat1,l1,b_mat2,l2,b_mat3,l3,/cdecl,unload=unload)

end