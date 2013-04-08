function strRemoveQuotes,str
l=strlen(str)
if (STRMATCH( Str, "'*'" ) eq 1) or (STRMATCH( Str, "'*'" ) eq 1) then $
  res=STRMID(str, 1 ,l-2) $
else res=str 
return, res
end