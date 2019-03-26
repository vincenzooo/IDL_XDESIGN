function fn,filename,unix=unix,windows=windows

if keyword_set(unix) and keyword_set(windows) then $
    message,'UNIX and WINDOWS keywords cannot be both set.'

if n_elements(filename) ne 1 then begin
  newfilename=strarr(n_elements(filename))
  for i =0,n_elements(filename)-1 do begin
    newfilename[i]=fn(filename[i])
  endfor
  return,newfilename
endif

;convert a filename path to a filename suitable for the operating system

if keyword_set(windows) then newfilename=strjoin(strsplit(filename,'/',/extract),'\') else $
  if keyword_set(unix) then newfilename=strjoin(strsplit(filename,'\',/extract),'/') else $
if  (!version.os_family eq 'Windows')  then newfilename=strjoin(strsplit(filename,'/',/extract),path_sep()) $
else newfilename=strjoin(strsplit(filename,'\',/extract),path_sep())

return,newfilename

end