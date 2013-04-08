function convertToSeconds,timeStr,dateStr,noMono=nomono
  ;default behaviour is assumed monotonic, a smaller time
  ;means it changed day. Set noMono if this is not the
  ;desired behavior.
  message,"Obsolete, use stringToJD(timestr, format='h:m:s'). N.B.: dateStr was not used here."
  
  npoints=n_elements(timeStr)
  timesec=lonarr(npoints)
  dayoffset=0l
  for i =0,npoints-1 do begin
    hms=fix(strsplit(timeStr[i],':',/extract),type=3)
    if keyword_set(nomono) eq 0 then $
      if dayoffset+hms[0]*3600l+hms[1]*60l+hms[2] lt timesec[i-1] then dayoffset=dayoffset+24l*3600 ;check monotonic for midnight
    timesec[i]=dayoffset+hms[0]*3600l+hms[1]*60l+hms[2]
  endfor
  
  return,timesec

end