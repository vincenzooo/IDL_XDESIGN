pro gettagvalue,structure,tagname,value
  
  if (N_ELEMENTS(e) NE 0) then begin
      names=TAG_NAMES(e)
      index= in (tagname,names,which)
      if index ne -1 then value=e.(index)
  endif
  
end 