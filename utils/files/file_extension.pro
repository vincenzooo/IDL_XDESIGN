function file_extension,filename,strippedname,full=full
  ;return the extension (with dot), if full is set return the name (without extenxion) with the complete path in strippedname
  ;
;  filename=file_basename(file)
;  dotposition=strsplit(filename,'.',count=c,/preserve_null)
;  strippedname=filename
;  if c le 1 then return, '' else dotposition=dotposition[c-1]
;  l=strlen(filename)
;  extension=strmid(filename,dotposition-1)
;  strippedname=file_basename(filename,extension)
;  return, extension

  file=file_basename(filename)
  strippedname=(keyword_set(full))? filename : file   ;return this if there is not extension  
  dotposition=strsplit(file,'.',count=c,/preserve_null)
  if c le 1 then return, '' else dotposition=dotposition[c-1]
  extension=strmid(file,dotposition-1)
  strippedname=file_basename(file,extension)
  if keyword_set(full) then strippedname= file_dirname(filename)+path_sep()+strippedname
  return, extension
end

full=0
print,"-----------------"
filename='prova.txt'
print,'Filename: ',filename
print,'Extension: ',file_extension(filename,strippedName,full=full)
print,'Stripped filename: ',strippedName
print,"-----------------"
filename=fn('cartella\incartella\prova.txt')
print,'Filename: ',filename
print,'Extension: ',file_extension(filename,strippedName,full=full)
print,'Stripped filename: ',strippedName
print,"-----------------"
filename=fn('carte.lla\incar..tella\prova.txt')
print,'Filename: ',filename
print,'Extension: ',file_extension(filename,strippedName,full=full)
print,'Stripped filename: ',strippedName
print,"-----------------"
filename=fn('prova.txt')
print,'Filename: ',filename
print,'Extension: ',file_extension(filename,strippedName,full=full)
print,'Stripped filename: ',strippedName
print,"-----------------"
filename=fn('carte.lla\incar..tella\prova')
print,'Filename: ',filename
print,'Extension: ',file_extension(filename,strippedName,full=full)
print,'Stripped filename: ',strippedName
print,"-----------------"
end