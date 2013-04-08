function basedir,filename
;given a file with relative or absolute path
;returns the directory in which the file is located

m="The routine is misnamed (the basename is the filename without extension)"+ $ 
  " and it already exists in IDL" + $
  " FILE_DIRNAME makes the same thing," 
message,m
stop

full=FILE_EXPAND_PATH(FINDFILE(filename))
sep=path_sep()
f=strsplit(full,sep,/extract)
f=f[0:n_elements(f)-2]
return, strjoin(f,sep)

end