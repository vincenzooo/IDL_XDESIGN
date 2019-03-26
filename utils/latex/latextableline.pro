function latexTableLine,array,format=format,tiddly=tiddly
;given an array of strings, each one corresponding to a value
;in a column, return the latex string for the table line.
;it is possible to provide a format string that describes how to
;print each column. The format string must not use repeater (one
;format for each column)
;e.g. format='(2f5.3)' does not work, use '(f5.3,f5.3)' instead.
;e.g.
;if TIDDLY is set the output is in tiddlywiki format 

if keyword_set(tiddly) then begin
    columnSep=' | ' 
    columnEnd=' |'
    columnStart='| '
endif else begin 
    columnSep=" &"
    columnEnd="\\"
    columnStart=""
endelse  

	if n_elements(format) ne 0 then begin
		;format='(a,f0.2,a,f3.1)'
		;array = ['1','2','prova','3']
		formarr=STRMID(format,1,strlen(format)-2)
		formarr=strsplit(formarr,',',/extract)
		;formarr is ['a','f0.2','a','f3.1']

		for i =0, n_elements(array)-1 do begin
			array[i]=strjoin(strsplit(string(array[i],format='('+formarr[i]+')'),'_',/extract),'\_')
		endfor

	endif

	line=strjoin(array,columnSep)
	line=columnStart+line+columnEnd
	return, line

end

testarr= ['1','2','prova','3']
a=latexTableLine(testarr,format='(a,f0.2,a,f3.1)')
print,a


end