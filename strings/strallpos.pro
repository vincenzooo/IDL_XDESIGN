function strAllPos,string,pattern,c,exact=exact
;return the positions of all the occurrences of the characters in PATTERN
;found in STRING.
;if EXACT is set, look for the entire substring PATTERN,
;N.B. the results found are excluded from the next search, 
;e.g.: searching for '**' in '01***56' return [2] (not [2,3])
;while searching in '01****6' return [2,4]

if keyword_set(exact) then begin
  l=1 
  searchstr=[pattern]
endif else begin
  l=strlen(pattern)
  searchstr=strarr(l)
  for i =0,l-1 do searchstr[i]=strmid(pattern,i,1)
endelse

c=0
for i =0,l-1 do begin
  p=strpos(string,searchStr[i])
  while (p ne -1) do begin
    if c eq 0 then pVec=[p] else pVec=[pVec,p]
    c=c+1
    ;print,'search in ', strmid(string,p+1)
    tmp=strpos(strmid(string,p+strlen(searchStr[i])),searchStr[i])
    p=(tmp eq -1)?-1:tmp+p+strlen(searchStr[i])
    ;print,'p=',p
  endwhile
endfor

if n_elements(pVec) eq 0 then return, -1 else return,pVec[sort(pVec)]



end

a='test*with_several**separators***to test__'
print,'starting string:'
print,a
print,'01234567890123456789012345678901234567890'
sep='*_'
print,'substring: "',sep,'"'
print,'result:'
print,strAllPos(a,sep)

print,'------------'
sep='***'
print,'substring: "',sep,'"'
print,'result:'
print,strAllPos(a,sep,/exact)

print,'------------'
sep='**'
print,'substring: "',sep,'"'
print,'result:'
print,strAllPos(a,sep,/exact)
end