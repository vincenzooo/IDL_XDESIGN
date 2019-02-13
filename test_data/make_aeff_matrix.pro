function make_aeff_matrix,areafile, outfile, header=header
;+
;read a file of effective area as calculated by old fortran ray tracing
;  programs. Convert to a matrix of area vs offaxis angle.
;-
;

readcol,areafile,en,ea,ea1,ea2

l=len_blocks(en,nblocks=n)
en=en[0:l-1]
aeff=reform(ea,l,n)

if n_elements(header) eq 0 then header='Energy'+strjoin(' Effective_area_'+string(indgen((size(aeff))[2]),format='(I02)'),'    ')

if n_elements(outfile) ne 0 then $
  write_datamatrix,outfile,aeff,header=header
  
return, [[en],[aeff]]
end


;getoaangle(file=fn('..\test_data\F10D394ff010_thsx\imp_offaxis.txt')) ;can be used for a more detailed header
areafile=fn('..\test_data\F10D394ff010_thsx\aree.txt')
a=make_aeff_matrix(areafile,'areamatrix.dat')



end