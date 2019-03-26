function string_to_array,string,type=tt,delimiter=dd
;convert a string representation of an array to an actual array.
;string may or may not be included in quotes.
;if type is not defined, doubles are returned
; an empty array is returned on empty input.
array=[]
if n_elements(tt) eq 0 then type=5 else type=tt
if n_elements(dd) eq 0 then delimiter=',' else delimiter=dd
if n_elements(string) ne 0 then begin
  tmp=strsplit(strtrim(strremovequotes(string),2),delimiter,/extract)
  array=fix(tmp,type=type)
endif

return, array
end