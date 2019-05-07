function fnAddSubfix,filename,subfix,newext,pre=pre,silent=silent,basename=basename
;add SUBFIX to FILENAME (before the extension)
;if NEWEXT (including the dot) is provided use it to replace the extension.
;if PRE is added, it is used as a prefix in same way as Subfix argument is used as subfix.
;if SILENT is set an empty variable is returned if FILENAME is not defined
;  (useful for managing optional arguments inside procedures).
;if BASENAME is set, then return only the basename (path removed).
; 2011/03/21 added SILENT keyword 
  
  if keyword_set(silent) then begin
    if n_elements(filename) eq 0 then return,filename
  endif
  
  if n_elements(filename) gt 1 then begin
    n=n_elements(filename)
    newnames=strarr(n)
    for i=0,n-1 do begin
      newnames[i]=fnaddsubfix(filename[i],subfix,newext,silent=silent,basename=basename)
    endfor
    return,newnames
  endif
  ;name=fsc_base_filename(filename,directory=folder,extension=extension) ;this doesn't work because return the extension without dot
  folder=file_dirname(filename)
  extension=file_extension(filename)
  if folder eq '.' then folder='' else folder=folder+path_sep()
  name=file_basename(filename,extension)
  if n_elements(newext) ne 0 then extension=newext
  if n_elements(pre) eq 0 then pre=""
  result=n_elements(extension) eq 0?folder+pre+name+subfix:(folder+pre+name+subfix+extension)
  if keyword_set(basename) then result=file_basename(result)
  return,result
  
  
;  if keyword_set(silent) then begin
;    if n_elements(filename) eq 0 then return,filename
;  endif
;  folder=file_dirname(filename)
;  extension=file_extension(filename)
;  if folder eq '.' then folder='' else folder=folder+path_sep()
;  name=file_basename(filename,extension)
;  if n_elements(newext) ne 0 then extension=newext
;  return, folder+name+subfix+extension
end


print,"-----------------"
filename=fn('prova.txt')
subfix='xxx'
print,"name: ",filename," subfix:",subfix
print,fnAddSubfix(filename,subfix)
print,"-----------------"
filename=fn('cartella\incartella\prova.txt')
subfix='xxx'
print,"name: ",filename," subfix:",subfix
print,fnAddSubfix(filename,subfix)
print,"-----------------"
filename=fn('carte.lla\incar..tella\prova.txt')
subfix='xxx'
print,"name: ",filename," subfix:",subfix
print,fnAddSubfix(filename,subfix)
print,"-----------------"
filename=fn('prova.txt')
subfix=' xxx'
print,"name: ",filename," subfix: '",subfix,"'"
print,fnAddSubfix(filename,subfix)
print,"-----------------"
filename=fn('carte.lla\incar..tella\prova')
subfix='xxx'
print,"name: ",filename," subfix:",subfix
print,fnAddSubfix(filename,subfix)
print,"-----------------"
filename=fn('carte.lla\incar..tella\prova.txt')
subfix='xxx'
newext='.dat'
print,"name: ",filename," subfix:",subfix," newext:",newext
print,fnAddSubfix(filename,subfix,newext)
print,"-----------------"

end
