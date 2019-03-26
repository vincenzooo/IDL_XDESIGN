pro reflexDLLexample

  dllFile='f_dll.so'
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

	loadRI,ener,mat1,mat2,mat3,dllFile
	ref= reflexDLL (ener, angle, dSpacing, rough, dll=dllFile ,/unload)
	plot, ener,ref

	writecol,'exampleRef.txt',ener,ref
	writecol,'exampleDspac.txt',dSpacing[indgen(nbil)*2],dSpacing[indgen(nbil)*2+1]

end