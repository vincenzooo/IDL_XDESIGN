pro cleanroomLogToseconds,filename,t0=t0,outfile=outfile

; convert a file with cleanroom log format colummns: time, ms, date, data columns 
; to a new file with formay julian time in seconds.
; the file has the same name and the subfix _sec attached. 
; T0 set the 0 time, default (julian day 0) is January 1, 4713 B.C.E., at 12pm
; 
  if n_elements(t0) eq 0 then tstart=0d else tstart=t0
  data=read_datamatrix(filename,skip=2,header=header)
  timesec=matrixtoJD(data,'h:m:s M/D/Y',timecols=[0,2],/sec)+data[1,*]/1000d
  result=[transpose(string(timesec-tstart,format='(f23.10)')),[data[3:*,*]]]
  header=header[0]
  header='JulianTime  '+strjoin((strsplit(header,/extract))[3:*],"  ")
  if n_elements(outfile) eq 0 then outf=fnaddsubfix(filename,'_sec') else outf=outfile
  write_datamatrix,outf,result,header=header
end

;print,matrixtojd(transpose([['10,28,2012','10,28,2012','10,28,2012'],['19,35,59','19,35,59','19,35,59']]),'M,D,Y h,m,s',/sec),format='(f23.10)'

cd,programrootdir()
filenames=['E:\work\work_nanovea\2012_10_28\20121028\ASCII\vince01_test.txt']
foreach name, filenames do begin
   ;19:33:59 000 10/28/2012   2.166548e+001   2.636603e+001  
   ;t0 willingly set to 1 min before
cleanRoomLogToseconds,name,t0=julday(10,28,2012,19,32,59)*3600d*24d
endforeach
;data=read_datamatrix(filename,skip=3)
end