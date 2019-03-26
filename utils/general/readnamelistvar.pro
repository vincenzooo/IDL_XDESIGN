function  readNamelistVar,file,varname,silent=silent,separator=sep,$
          stringdelimiter=sd
;read a namelist variable from file if found it.
;if not found and silent is set, return a string with an error message,
;if silent is not set, raise an error.

if n_elements(sd) eq 0 then stringdelimiter="'"+'"' else stringdelimiter=sd
if n_elements(sep) eq 0 then sep="="
get_lun,nf
openr,nf,file
line =strarr(1)
while ~ EOF(nf) do begin
	READF,nf , line
	l=strsplit (line,sep,/extract)

	l0=strtrim(l[0],2)
	if strlowcase(l0) eq strlowcase(varname) then begin
		free_lun,nf
		;if string variable into apostrophes, remove them.
		val=strtrim(l[1],2)
		val=strsplit(val,stringDelimiter,/extract)
		return,val[0]
	endif
endwhile

;it gets here only if something went wrong.
free_lun,nf
if n_elements(silent) eq 0 then silent=0
mes="variable <"+varname+"> not found in file: "+file

if silent ne 0 then begin
	return,mes
endif else begin
	message,mes
endelse


end
