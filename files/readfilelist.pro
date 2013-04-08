
function readFileList,filename,skiplines=skip,splitgroups=splitgroups
;read a list of filenames from a text file,
;return an array of filenames
;if SPLITGROUPS is set blank lines are used to separated groups of filenames,
; and a list with groups is returned. Otherwise blank lines are ignored. 
  
;2013/02/11 added option splitgroups (white lines were ignored in previous version).
  if n_elements(skip) eq 0 then skip=0
  OPENR, unit0, filename, /GET_LUN
  ;load all lines (including blanks) in vector filelist
  line=strarr(1)
  if skip gt 0 then for j=0l,skip-1 do READF, unit0, line
  while ~ EOF(unit0) do begin
    READF,unit0 , line
    if n_elements(filelist) eq 0 then filelist=[line] else filelist=[filelist,line]
  endwhile
  free_lun, unit0
  
  if keyword_set(splitgroups) ne 0 then begin
    ;remove final blanklines
    i=1
    file=filelist[-i]
    while (strlen(strtrim(file,2)) eq 0) do begin 
      i=i+1
      file=filelist[-i]
    endwhile
    filelist=filelist[0:-i]
    ;split groups
    sep=where(strtrim(filelist,2) eq "",c, complement=nonBlank)
    if c eq 0 then message, 'No Separators',/info
    start=0
    filegroups=list()
    for i=0,c-1 do begin
      filegroups.add,filelist[start:sep[i]-1]
      start=sep[i]+1
    endfor
    filegroups.add,filelist[start:-1]
  endif else begin
    sep=where(strtrim(filelist,2) eq "",c, complement=nonBlank)
    filegroups=filelist[nonBlank]
  endelse

  
  if n_elements(filegroups) eq 0 then message,'Empty list file!'
  
  ;clean the blank line at end if present
  return,filegroups

end

