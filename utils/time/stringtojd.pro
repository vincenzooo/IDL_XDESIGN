;2013/01/25
;the old version with hashes is unbearably slow. Replacing hashes with array made it
; it quicker.
;
;Note also that the format parser was inside the loop. This could be useful if
; you want to use a different format for each line, that is not a very common case,
; also the current routine is not made for a vector format, that would mess up 
; everything. So I am bringing the format parsing out of the loop and doing it
; only once.
;Note also that the last version of IDL 8.2 (don't know the previous ones) returns
; a list if strsplit is launched on an array. The current routine is not ready for
; a vector format.


function stringToJD,ts,format,seconds=seconds,nomono=nomono

 ;  Convert a string with time in a suitable format to julian date 
 ;  (fractional number of days from 4713b.C./01/01 12:00:00) as a double.
 ;  If no info are provided on date, return the time in days relative
 ;  to noon of the same day (can go from -0.5 to 0.5 for '00:00:00', '24:00:00',
 ;  with format 'h:m:s').
 ; 
 ;  TS: scalar or vector of strings containing times in a given format.
 ;      Can be either a column ([1,n]) or row ([n,1] or [n]) vector.
 ;  FORMAT: define the format of TS, see description below. 
 ;  SECONDS: return julian time in seconds rather than in days
 ;  NOMONO: If it is set does not assume a change of date when the timestamp decreases 
 ;
 ;  Return an array (or scalar) of doubles with the same number of element as TS. 
 ;    The output is always a column ([n]) vector, no matter if TS is row or column.
 ;  
  ;all non recognized characters in format are considered separators.
  ;valid values are Y,M,D,h,m,s,A
  ;extract list of separators and fields from format.
  ;e.g.:
  ;format='Y:M:D'
  ;timestamp='2011:12:21'
  ;print,stringToJD(timeStamp,format)
  ;       2455917.0
  ;print,julday(12,21,2011,12,00,00)
  ;     2455917.0
  
  jultime=dblarr(n_elements(ts))
  dayoffset=0l
  separators=strsplit(format,'[YMDhmsA]',count=cs,/extract,/regex)
  fields=strsplit(format,strjoin(separators),/extract,count=cf)
  for i=0l,n_elements(ts)-1 do begin
    timestamp=ts[i]
    ;extract values from timestamp
    values=strsplit(timestamp,strjoin(separators),count=cv,/extract)
    
    ;set default values
    caldat,0,month,day,year,hour,minute,second
    time_month=month
    time_day=day
    time_year=year
    time_hour=hour
    time_minute=minute
    time_second=second
    time_AMPM=''
    
    ;print,'Defaults: M D Y h m s' 
    ;print ,month,day,year,hour,minute,second
    ;
    ; 12 am (midnight) must be converted to 0, 12 pm (noon) is 0+0.5
    ; but if ampm is not specified, 12 is 12 and 0 is 0. the default on ampm is AM for all hours but 12...
    ; I believe (hope) nobody will ever use 24, but according to wikipedia, it is not impossible,
    ; anyway it should work without modifications.
    
    for j =0, n_elements(fields)-1 do begin
      f=fields[j]
      if f eq 'M' then time_month=values[j] else $
        if f eq 'D' then time_day=values[j] else $
        if f eq 'Y' then time_year=values[j] else $
        if f eq 'h' then time_hour=values[j] else $
        if f eq 'm' then time_minute=values[j] else $
        if f eq 's' then time_second=values[j] else $
        if f eq 'A' then time_AMPM=values[j] 
    endfor
    
    if time_AMPM ne '' then begin
      ampm=strmid((strtrim(strlowcase(time_AMPM))),0,1)
      if (ampm ne 'p' and ampm ne 'a') then message, 'Unrecognized format for AM/PM'
      if (fix(time_hour) eq 12) then time_hour=time_hour-12
      if (ampm eq 'p') then time_hour=time_hour+12
    endif
    ;print,'set values: MDY h m s'
    ;print,timeDic['M'],timeDic['D'],timeDic['Y'],$
    ;               timeDic['h'],timeDic['m'],timeDic['s']
    ;print,'JULDAY:',jultime
    
    ;v are all values, we know the meaning of each 
    jultime[i]=julday(time_month,time_day,time_year,$
               time_hour,time_minute,time_second)
    if keyword_set(nomono) eq 0 and i ge 1 then $
      if jultime[i] lt lasttime then dayoffset=dayoffset+1l ;check monotonic for midnight
    lasttime=jultime[i]
    jultime[i]=jultime[i]+dayoffset
                      
  endfor
  if n_elements(jultime) eq 1 then jultime=jultime[0]
  if keyword_set(seconds) then jultime=jultime*3600d*24d
  return,jultime
end

pro __test_arrayToJD,timestamp,format
    ;launch the function with a wrapper which prints 
    ;output of input and output values for test.
    print,'###'
    print,'fmt: ',format,' timestamp: ',timestamp
    print,'RESULT: '
    print,stringToJD([timeStamp,timeStamp],format),format='(f)'
    print,'--'
end

pro test_arrayToJD
  format='M/D/Y'
  timestamp='12/21/2011'
  __test_arrayToJD,timestamp,format
  format='Y:M:D'
  timestamp='2011:12:21'
  __test_arrayToJD,timestamp,format
    ;       2455917.0
  print,'julday(12,21,2011,12,00,00): ',julday(12,21,2011,12,00,00)
end