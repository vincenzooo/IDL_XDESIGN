function strExtract,string,positions,splittedString=splittedString
;return as an array of characters 
;the characters in STRING corresponding to the position in 
;POSITIONS.
;the optional argument SPLITTEDSTRING can return the parts of the substring 
;between the POSITIONS values.
;N.B.:if two consecutive positions are contained in POSITIONS return the empty string
;contained between them, in the same way empty strings can be returned at the two 
;edges if POSITIONS contain the first and last position.

l=n_elements(positions)
result=strarr(l)
for i =0,l-1 do begin
  result[i]=strmid(string,positions[i],1)
endfor


if arg_present(splittedString) then begin
  splittedString=[strmid(string,0,positions[0])]
  for i =0,l-2 do begin
      splittedString=[splittedString,strmid(string,positions[i]+1,positions[i+1]-positions[i]-1)]
  endfor
  splittedString=[splittedString,strmid(string,positions[l-1]+1)]
endif

return,result

end


