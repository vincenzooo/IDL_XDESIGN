function in, valuetotest,vector,which=which
;test if <valuetotest> is present in <vector>,
;return 1 if present, 0 if not, raise error if <valuetotest> is not
;a singlevalue, if <which> is set return the index of the first element
;of <vector> equal to <valuetotest>.

if n_elements(valuetotest) eq 0 then MESSAGE, 'value to be found in array is not defined (usage: in(value,array))'
if n_elements(valuetotest) ne 1 then MESSAGE, 'value to look for in array is not a scalar or single value array (usage: in(value,array))'
n=n_elements(vector)
if n eq 0 then MESSAGE, 'array to be searched for value is not defined (usage: in(value,array))'

w=where(vector eq valuetotest[0])
w=w[0]

if keyword_set(which) eq 0 then begin
	if w eq -1 then begin
		return, 0
	endif else begin
		return, 1
	endelse
endif else begin
	return,w
endelse



end