function stripext,filename,full=full

stripped=strarr(n_elements(filename))
for i =0,n_elements(filename)-1 do begin
  dummy=file_extension(filename[i],tmp,full=full)
  stripped[i]=tmp
endfor

return,stripped

end