pro createDateTimefile,outfile,infile,startdate=startdate
  folder=file_dirname(infile)
  readcol, timefile, time,format='A'
  
  ;if startdate is not provided, use the file creation date.
  ;startdate must be provided as julian number of seconds
  if n_elements(startdate) eq 0 then $
    startDateSec=systime((file_info(infile)).ctime,/julian) $
  else startDateSec=startDate
  
  caldat,startDateSec,m,d,y
end


function stringToSeconds,ts,format

 ;  Convert a string with time in a suitable format to julian date 
 ;  (fractional number of days from 4713b.C./01/01 12:00:00) as a double.
 ;  If no info are provided on date, return the time in days relative
 ;  to noon of the same day (can go from -0.5 to 0.5 for '00:00:00', '24:00:00',
 ;  with format 'h:m:s').

  ;all non recognized characters in format are considered separators.
  ;valid values are Y,M,D,h,m,s,A
  ;extract list of separators and fields from format.
  ;e.g.:
  ;format='Y:M:D'
  ;timestamp='2011:12:21'
  ;print,stringToSeconds(timeStamp,format)
  ;       2455917.0
  ;print,julday(12,21,2011,12,00,00)
  ;     2455917.0
  timesec=fltarr(n_elements(ts))
  for i=0,n_elements(ts)-1 do begin
    timestamp=ts[i]
    separators=strsplit(format,'^[YMDhmsA]',count=cs,/extract)
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
    ;print,'Defaults: M D Y h m s' 
    ;print ,month,day,year,hour,minute,second
    
    for j =0, n_elements(fields)-1 do begin
      timeDic[fields[j]]=values[j]
      ;print,fields[j],'=',values[j]
    endfor
    
    ;v are all values, we know the meaning of each 
    timesec[i]=julday(timeDic['M'],timeDic['D'],timeDic['Y'],$
                   timeDic['h'],timeDic['m'],timeDic['s'])
    ;print,'set values: MDY h m s'
    ;print,timeDic['M'],timeDic['D'],timeDic['Y'],$
    ;               timeDic['h'],timeDic['m'],timeDic['s']
    ;print,'JULDAY:',timesec
  endfor
  if n_elements(timesec) eq 1 then timesec=timesec[0]
  
  return,timesec
end

;function arrayToSeconds,timeArr,format
;  np=n_elements(timeArr)
;  timeSec=lonarr(np)
;  for i =0,np-1 do begin
;    timeSec[i]=stringToSeconds(timeArr[i],format)
;  endfor
;  return, timeSec
;end

pro __test_arrayToSeconds,timestamp,format
    
    print,'###'
    print,'fmt: ',format,' timestamp: ',timestamp
    print,'RESULT: ',stringToSeconds([timeStamp,timeStamp],format)
    print,'--'
end

pro test_arrayToSeconds
  format='M/D/Y'
  timestamp='12/21/2011'
  __test_arrayToSeconds,timestamp,format
  format='Y:M:D'
  timestamp='2011:12:21'
  __test_arrayToSeconds,timestamp,format
    ;       2455917.0
  print,'julday(12,21,2011,12,00,00): ',julday(12,21,2011,12,00,00)
end
  
function convert,timeStamp_matrix,format,timeCols=timeCols
  
  ;timestamp='2011:12:21'
  cols=strsplit(format," ",/extract)
  ncols=n_elements(cols)
  if n_elements(timeCols) ge 1 then begin
    if n_elements(timeCols) ne ncols then message, $
      'Number of columns not corresponding in FORMAT and timeCols'
    colSet=timeCols
  endif else begin
    if n_elements(timeCols) eq 0 then startCol=0 else $
      if n_elements(timeCols) eq 1 then startCol= timeCols
    colSet=indgen(ncols)+startCol
  endelse 
  
  colFormats=strsplit(format,/extract)
  
  nrows=n_elements(m)
  seconds=fltarr(nrows)
  for i =0,ncols-1 do begin
    seconds=seconds+stringToSeconds(m[i,*],ColFormats[i])
  endfor
  return, seconds
end  
 
 
function readTime,file,format,timeColIndices=timeCols
 ;read time from a file given the format and (optional)
 ;  the indices of the column containing the time.
 ;  returns the number of seconds (julian date).
 
  ;"Y/M/D h:m:s A"
  ;"Y/M/D h:m:s"
  ;"h:m:s"
  
  ;file='E:\work\work_pzt\measure_data\17\data\2011_12_07\TIME_11_12_07_23_02_39.TXT'
  format='h:m:s'
  timeStamp_matrix=read_datamatrix(file)
  seconds=convert(timeStamp_matrix,format,timeCols=timeCols)
  return,seconds
end