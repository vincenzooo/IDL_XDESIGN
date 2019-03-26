pro picoLogToseconds,filename,t0=t0,outfile=outfile

; convert a file with picolog format colummns: date, time, data columns 
; to a new file with formay julian time in seconds.
; the file has the same name and the subfix _sec attached. 
; T0 set the 0 time, default (julian day 0) is January 1, 4713 B.C.E., at 12pm

  if n_elements(t0) eq 0 then tstart=0d else tstart=t0
  data=read_datamatrix(filename,skip=3,header=header)
  timesec=matrixtoJD(data,'D/M/Y  h.m.s',timecols=[0,1],/sec)
  result=[transpose(string(timesec-tstart,format='(f23.10)')),[data[2:*,*]]]
  header=header[0]
  header='JulianTime  '+strjoin((strsplit(header,/extract))[2:*])
  if n_elements(outfile) eq 0 then outf=fnaddsubfix(filename,'_sec') else outf=outfile
  write_datamatrix,outf,result,header=header
end

cd,programrootdir()
filenames=['2012_11_29_calibration.txt','2012_12_05_calibration.txt','2012_12_12.txt']
foreach name, filenames do begin
picoLogToseconds,name,t0=212220949511.0000600000d
endforeach
;data=read_datamatrix(filename,skip=3)
end