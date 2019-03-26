function matrixToJD,timeStamp_matrix,format,timeCols=timeCols,seconds=seconds
  ; convert to julian day data in a matrix in which some columns are timestamps for time and/or date. 
  ;uses stringToJD
  
  ;what happen if I pass a single vector? If it is a 2-D matrix (i.e. [1,n] or [n,1])
  ;the routine should work. If it is a 1-dim vector, the program has no way to tell
  ; a-priori if it represents a single line or a sequence of single fields.
  ; It can be understood by the format, but this condition is missing. 
  ;
  ;
  ;timestamp='2011:12:21'
  
  If n_elements(format) eq 0 then message,"A format must be provided"
  nrows=(size(timestamp_matrix,/dimensions))[1] ;it will deliberately cause an error if it is 1-dim
  if strpos(format,'D') ne -1 then nomono=1 ; if there is an indication of the day, ignores midnight.
  tmp=strsplit(format," ",/extract)
  ncols=n_elements(tmp)
  colFormats=strsplit(format,/extract)
  ;if n_elements(colset) eq 1 then  
  
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
  for i =0l,ncols-1 do begin
    JD=JD+stringToJD(timeStamp_matrix[colset[i],*],ColFormats[i],seconds=seconds,nomono=nomono)
  endfor
  
  return, JD
end  

 ;TEST
 ;read time from a file given the format and (optional)
 ;  the indices of the column containing the time.
 ;  returns the number of seconds (julian date).
 
  ;"Y/M/D h:m:s A"
  ;"Y/M/D h:m:s"
  ;"h:m:s"
  
  cd,programrootdir()
  file='TIME_11_12_07_23_02_39.TXT'
  format='h:m:s'
  timeStamp_matrix=read_datamatrix(file)
  seconds=matrixToJD(timeStamp_matrix,format)
  print,range(seconds)
  ;print,data[[0,2],*]
  ;19:33:59 10/28/2012
  ;19:33:59 10/28/2012
  ;....
  ;...
  ;print,julday(10,28,2012,19,33,59)*3600d*24d,format='(f23.6)'
  ;  212218212839.000000
  ;print,matrixtojd(data[[0,2],*],'h:m:s M/D/Y',/sec),format='(f23.10)'
  ; 212218212839.0000600000
  ;print,matrixtojd(data[[0,2],*],'h:m:s M/D/Y',/sec),format='(f23.10)'
  ; 212218212839.0000600000
  ;print,matrixtojd([['19:33:59','10/28/2012'],['19:33:59','10/28/2012']],'h:m:s M/D/Y',/sec),format='(f23.10)'
  ; 212218212839.0000600000
  
end