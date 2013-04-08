function  copynamelistfile,file, outfile,varname,newvalue
;read a variable from a file containing a namelist.
;if a outfile is given copy the file, replacing the variable with
;rimpiazzare varname e varlist con la possibilita' di cambiare piu' valori

get_lun,nf
openr,nf,file
line =strarr(1)
l=strarr(1)
READF,nf , line
while ~ EOF(nf) do begin
	READF,nf , l
	line=[line,l]
endwhile
free_lun,nf

openw,nf,outfile
for i =0,n_elements(line)-1 do begin
	l=strsplit (line[i],"=",/extract)
	l0=strtrim(l[0],2)
	if strlowcase(l0) eq strlowcase(varname) then begin
		line[i]=strjoin([l0,"=",string(newvalue)])
	endif
	printF,nf,line[i]
endfor
free_lun,nf

;if n_elements(silent) eq 0 then silent=0
;mes="variable <"+varname+"> not found in file: "+file
;
;if silent ne 0 then begin
;	message,mes
;endif else begin
;	print,mes
;	return,mes
;endelse


end