function wherein, array, targetValues, count, COMPLEMENT=complement, $
	NCOMPLEMENT=ncomplement,which=which,silent=silent
;Check if any of the elements of <array> is in <targetValues>.
;The function uses the function "in".
;RETURN VALUES:
;Return an array with the indexes of the elements of <array>
; that are in <targetValues>, return -1 if none of the elements is in <targetValues>
; (this case should be tested by checking count, in the same way as with the where
; command.
;Return in <which> an array of the same length than <array>,
;	with the index of the corresponding element in <targetValues> or -1
;	(if the element is not in <targetValues>).
;If <silent> is set, ignore the case in which <value> is not provided (return
; the whole <array> indexes without error).
;--------
;OPTIONS (as in the where funtion)
;Count: A named variable that will receive the number of nonzero
;elements found in Array_Expression.
;COMPLEMENT:a named variable that receives the subscripts of the elements of <array>
;not found in <targetValues>, gives -1 if empty
;NCOMPLEMENT: number of elements of <array> not found in <targetValues>

;example (code at the end, run for test)
;tmp=wherein([1,2,3,4,5,6,7,3],[3,5,7],count,COMPLEMENT=complement, $
;	NCOMPLEMENT=ncomplement,which=which)
;count:          4
;complement: 	 0 1 3 5
;ncomplement:    4
;which:         -1 -1 0 -1 1 -1 2 0
;return value:   2 4 6 7


if n_elements(silent) ne 0 then begin
	if n_elements(targetValues) eq 0 then begin
		count=n_elements(array)
		complement=-1
		ncomplement=0
		which=lonarr(count)
		which=which-1
		return,indgen(count)
	endif
endif

n=n_elements(array)

;create the result array returned if <which> is set
which=lonarr(n)
for i= 0L,n-1 do begin
 which[i]=in(array[i],targetValues,/which)
endfor

inarr=where (which ne -1,Count, COMPLEMENT=complement,NCOMPLEMENT=ncomplement)

;if (which eq 0) then
return, inarr
;return,whicharray

end

;test
print,"function wherein, array, targetValues, count, COMPLEMENT=complement,"+ $
  "NCOMPLEMENT=ncomplement,which=which,silent=silent"
print,"----------------------------------------------------"
print,"array=[1,2,3,4,5,6,7,3],targetValues=[3,5,7]" 
tmp=wherein([1,2,3,4,5,6,7,3],[3,5,7],count,COMPLEMENT=complement, $
	NCOMPLEMENT=ncomplement,which=which)
	print,'count: ',count
	print,'complement: ',complement
	print,'ncomplement: ',ncomplement
 	print,'which: ', which
	print,'return value:',tmp
	print,"----------------------------------------------------"
print,"array=[1,2,3,4,5,6,7,3],targetValues=[9,8,71]" 
tmp=wherein([1,2,3,4,5,6,7,3],[9,8,71],count,COMPLEMENT=complement, $
  NCOMPLEMENT=ncomplement,which=which)
  print,'count: ',count
  print,'complement: ',complement
  print,'ncomplement: ',ncomplement
  print,'which: ', which
  print,'return value:',tmp
print,"----------------------------------------------------"
print,"array=[1,2,3,4,5,6,7,3],targetValues=undefined,/silent" 
tmp=wherein([1,2,3,4,5,6,7,3],empty,count,COMPLEMENT=complement, $
  NCOMPLEMENT=ncomplement,which=which,/silent)
  print,'count: ',count
  print,'complement: ',complement
  print,'ncomplement: ',ncomplement
  print,'which: ', which
  print,'return value:',tmp
print,"----------------------------------------------------"
print,"array=[1,2,3,4,5,6,7,3],targetValues=undefined (/silent flag not set)" 
tmp=wherein([1,2,3,4,5,6,7,3],empty,count,COMPLEMENT=complement, $
  NCOMPLEMENT=ncomplement,which=which)
  print,'count: ',count
  print,'complement: ',complement
  print,'ncomplement: ',ncomplement
  print,'which: ', which
  print,'return value:',tmp

end