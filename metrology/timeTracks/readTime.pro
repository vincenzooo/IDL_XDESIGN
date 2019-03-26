function stringToJD,ts,format,seconds=seconds,date=date,nomono=nomono

 ;  Convert a string with time in a suitable format to julian date 
 ;  (fractional number of days from 4713b.C./01/01 12:00:00) as a double.
 ;  If no info are provided on date, return the time in days relative
 ;  to noon of the same day (can go from -0.5 to 0.5 for '00:00:00', '24:00:00',
 ;  with format 'h:m:s').
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
  for i=0,n_elements(ts)-1 do begin
    timestamp=ts[i]
    separators=strsplit(format,'[YMDhmsA]',count=cs,/extract,/regex)
    fields=strsplit(format,strjoin(separators),/extract,count=cf)
    ;extract values from timestamp
    values=strsplit(timestamp,strjoin(separators),count=cv,/extract)
    timeDic=hash() ;this dic will store the number of column for each named field
    
    ;set default values
    caldat,0,month,day,year,hour,minute,second
    timeDic['M']=month
    timeDic['D']=day
    timeDic['Y']=year
    timeDic['h']=hour
    timeDic['m']=minute
    timeDic['s']=second
    timeDic['A']=''
    
    ;print,'Defaults: M D Y h m s' 
    ;print ,month,day,year,hour,minute,second
    ;
    ; 12 am (midnight) must be converted to 0, 12 pm (noon) is 0+0.5
    ; but if ampm is not specified, 12 is 12 and 0 is 0. the default on ampm is AM for all hours but 12...
    ; I believe (hope) nobody will ever use 24, but according to wikipedia, it is not impossible,
    ; anyway it should work without modifications.
    
    for j =0, n_elements(fields)-1 do begin
      timeDic[fields[j]]=values[j]
      ;print,fields[j],'=',values[j]
    endfor
    
    if timeDic['A'] ne '' then begin
      ampm=strmid((strtrim(strlowcase(timeDic['A']))),0,1)
      if (ampm ne 'p' and ampm ne 'a') then message, 'Unrecognized format for AM/PM'
      if (fix(timedic['h']) eq 12) then timedic['h']=timedic['h']-12
      if (ampm eq 'p') then timedic['h']=timedic['h']+12
    endif
    ;print,'set values: MDY h m s'
    ;print,timeDic['M'],timeDic['D'],timeDic['Y'],$
    ;               timeDic['h'],timeDic['m'],timeDic['s']
    ;print,'JULDAY:',jultime
    
    ;v are all values, we know the meaning of each 
    jultime[i]=julday(timeDic['M'],timeDic['D'],timeDic['Y'],$
               timeDic['h'],timeDic['m'],timeDic['s'])
    if keyword_set(nomono) eq 0 and i ge 1 then $
      if jultime[i] lt jultime[i-1] then dayoffset=dayoffset+24l*3600 ;check monotonic for midnight
    jultime[i]=jultime[i]+dayoffset
                      
  endfor
  if n_elements(jultime) eq 1 then jultime=jultime[0]
  if keyword_set(seconds) then jultime=jultime*3600.*24.
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
  
function convert,timeStamp_matrix,format,timeCols=timeCols
  
  nrows=n_elements(timeStamp_matrix)
  ;timestamp='2011:12:21'
  tmp=strsplit(format," ",/extract)
  ncols=n_elements(tmp)
  colFormats=strsplit(format,/extract)
  
  if n_elements(timeCols) ge 1 then begin
    if n_elements(timeCols) ne ncols then message, $
      'Number of columns not corresponding in FORMAT and timeCols'
    colSet=timeCols
  endif else begin
    if n_elements(timeCols) eq 0 then startCol=0 else $
      if n_elements(timeCols) eq 1 then startCol= timeCols
    colSet=indgen(ncols)+startCol
  endelse 
  
  JD=fltarr(nrows)
  for i =0,ncols-1 do begin
    JD=JD+stringToJD(timeStamp_matrix[i,*],ColFormats[i])
  endfor
  
  return, JD
end  


 
function readTime,file,format,timeColIndices=timeCols
 ;read time from a file given the format and (optional)
 ;  the indices of the column containing the time.
 ;  returns the number of seconds (julian date).
 
  ;"Y/M/D h:m:s A"
  ;"Y/M/D h:m:s"
  ;"h:m:s"
  
  file='E:\work\work_pzt\measure_data\17\data\2011_12_07\TIME_11_12_07_23_02_39.TXT'
  format='h:m:s'
  timeStamp_matrix=read_datamatrix(file)
  seconds=convert(timeStamp_matrix,format,timeCols=timeCols)
  return,seconds
end

;function extractSensor,tag, date,time,sensor,temp, outtime=time1,outtemp=temp1
;;TAG is a string containing the sensor identifier (the column header for the data column to be extracted).
;;
;;isens1=extractSensor("ISO AIR Temp 1",date,time,sensor,temp, outtime=time1,outtemp=temp1)
;  isens1=where(sensor eq tag,c1)
;  if c1 eq 0 then begin
;    message,'sensor '+tag+' not found!',/info
;    beep
;  endif
;  
;  time1=[]
;  for i=0,c1-1 do begin
;    time1=[time1,stringtojd(date[isens1[i]]+' '+time[isens1[i]],'M/D/Y h:m:s A')]
;  endfor
;
;  temp1=double(temp[isens1])
;  return, isens1
;end

;pro readCleanroomLog,file
;  readcol,file,date,time,sensor,temp,delimiter=',',format='A,A,A,A',skip=1
;  date=(strsplit(date,'"',/extract)).toarray()
;  time=(strsplit(time,'"',/extract)).toarray()
;  sensor=(strsplit(sensor,'"',/extract)).toarray()
;  temp=(strsplit(temp,'"',/extract)).toarray()
;  labels=["ISO AIR Temp 1","ISO AIR Temp 2","ISO AIR RH 1","ISO AIR RH 2","ISOAIR + 2"]
; isens1=extractSensor(labels[0],date,time,sensor,temp, outtime=time1,outtemp=temp1)
; isens2=extractSensor(labels[1],date,time,sensor,temp, outtime=time2,outtemp=temp2)
; isens3=extractSensor(labels[2],date,time,sensor,temp, outtime=time3,outtemp=temp3)
; isens4=extractSensor(labels[3],date,time,sensor,temp, outtime=time4,outtemp=temp4) 
; isens5=extractSensor(labels[4],date,time,sensor,temp, outtime=time5,outtemp=temp5)
; 
; date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I', '%D %M %Y'])
;
; multi_plot,time1,[[temp1],[temp2],[temp3],[temp4]],legpos=10,legend=labels[0:3], $
;   XTITLE = 'Time (h:m)', $
;   YTITLE = 'Temperature (C)', $
;   ; applying date/time formats to X-axis labels.
;   POSITION = [0.2, 0.25, 0.9, 0.9], $
;   XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
;   XTICKUNITS = ['Time', 'Day'], $
;   XTICKINTERVAL = 0.5
; maketif,'cleanroomlog'
;end

;function read_labjackdata, filename
;  ; read a labjack data file with an arbitrary number of column, 
;  ; return a list of xydatafile
;  return,0
;end

  cd, programrootdir()
  file='examples\cleanroomlog.txt'
  ;file='examples\LabTemps-09-26-2012.csv'
  readcleanroomlog,file
  end