
function extractSensor,tag, date,time,sensor,temp, outtime=time1,outtemp=temp1
;TAG is a string containing the sensor identifier (the column header for the data column to be extracted).
;
;isens1=extractSensor("ISO AIR Temp 1",date,time,sensor,temp, outtime=time1,outtemp=temp1)
  isens1=where(sensor eq tag,c1)
  if c1 eq 0 then begin
    message,'sensor '+tag+' not found!',/info
    beep
  endif
  
  time1=[]
  for i=0,c1-1 do begin
    time1=[time1,stringtojd(date[isens1[i]]+' '+time[isens1[i]],'M/D/Y h:m:s A')]
  endfor

  temp1=double(temp[isens1])
  return, isens1
end

pro readCleanroomLog,file
  readcol,file,date,time,sensor,temp,delimiter=',',format='A,A,A,A',skip=1
  date=(strsplit(date,'"',/extract)).toarray()
  time=(strsplit(time,'"',/extract)).toarray()
  sensor=(strsplit(sensor,'"',/extract)).toarray()
  temp=(strsplit(temp,'"',/extract)).toarray()
  labels=["ISO AIR Temp 1","ISO AIR Temp 2","ISO AIR RH 1","ISO AIR RH 2","ISOAIR + 2"]
 isens1=extractSensor(labels[0],date,time,sensor,temp, outtime=time1,outtemp=temp1)
 isens2=extractSensor(labels[1],date,time,sensor,temp, outtime=time2,outtemp=temp2)
 isens3=extractSensor(labels[2],date,time,sensor,temp, outtime=time3,outtemp=temp3)
 isens4=extractSensor(labels[3],date,time,sensor,temp, outtime=time4,outtemp=temp4) 
 isens5=extractSensor(labels[4],date,time,sensor,temp, outtime=time5,outtemp=temp5)
 
 date_label = LABEL_DATE(DATE_FORMAT = ['%H:%I', '%D %M %Y'])

 multi_plot,time1,[[temp1],[temp2],[temp3],[temp4]],legpos=10,legend=labels[0:3], $
   XTITLE = 'Time (h:m)', $
   YTITLE = 'Temperature (C)', $
   ; applying date/time formats to X-axis labels.
   POSITION = [0.2, 0.25, 0.9, 0.9], $
   XTICKFORMAT = ['LABEL_DATE', 'LABEL_DATE'], $
   XTICKUNITS = ['Time', 'Day'], $
   XTICKINTERVAL = 0.5
 maketif,'cleanroomlog'
end

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