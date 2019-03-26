function map,operator,array,_extra=e

l=n_elements(array)

if l lt 1 then begin
	print,'the argument passed to map is not an array!'
endif

testval=call_function(operator,array[0])
type=size(testval,/type)
rv=make_array(l,type=type)
for i =0,l-1 do begin
	rv[i]=call_function(operator,array[i])
endfor
 return,rv

end

print,map('string',[1,2.,5])
end