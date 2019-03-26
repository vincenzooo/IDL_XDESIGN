function makelatextable,matrix,format=format,rowheader=rowheader,colheader=colheader
;colheader is a vector of strings.
;rowheader is a line
;
;s=size(matrix)
;if s[0] gt 2 then message,'dimension of matrix='+string(s[0])+', case not implemented' 
;nlines= s[1]
s=size(matrix,/dimension)
if n_elements(s) gt 2 then message,'dimension of matrix='+string(n_elements(s))+', case not implemented' 
nlines= s[n_elements(s)-1]

;if n_elements(rowheader) ne 0 then begin
;  if nlines ne n_elements(rowheader) then message,'number of lines in data ('+$
;    string(nlines)+'), not corresponding with number of lines in row header ('+$
;    string(n_elements(rowheader))+')'
;endif

latextable=['\toprule']
if n_elements(colheader) ne 0 then latextable=[latextable,colheader,'\midrule']

for i = 0,nlines-1 do begin
   if n_elements(rowheader) eq 0 then $
        latextable=[latextable,latextableline(transpose(matrix[*,i]),format=format)] $
   else $
        latextable=[latextable,latextableline([string(rowheader[i]),string(matrix[*,i])],format=format)]
endfor
latextable=[latextable,'\bottomrule']
return, strjoin(latextable,newline())


end