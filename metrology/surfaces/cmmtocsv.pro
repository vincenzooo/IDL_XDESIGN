pro CMMtoCSV, file,outfile=ouf,colorder=co,VB=VB,header=header,skip=sk
;convert a CMM dat file to a 3 column file  


;this routine reads data processed after perl script, data are expected to be
;on 4 columns with Point name, X, Y, Z.
;COLORDER is a 3 elements vector indicating the order that an input 
; column assume in the output in base 1 
;(e.g. [3,1,2] read data as Z,X,Y, with Z being the surface height).
    
colorder=(n_elements(co) ne 0)?co:[3,1,2]
if keyword_Set(VB) then begin
  ;message,"Procedure for reading a CMM Visual-Basic-generated file is not implemented. You can write it now."
  if n_elements(sk) ne 0 then message,'VB and skip are both set.' else skip=11
endif else begin 
  if n_elements(sk) ne 0 then skip=sk
endelse
  
;if FILE is an array and OUTFILE is provided, they should be arraysd of the same size.
;An option for generate numbered files could also be implemented.
if n_elements(ouf) ne 0 then begin
  if n_elements(ouf) ne n_elements(file) then message,'non matching number of elements. Option not implemented.'
endif
for i =0,n_elements(file)-1 do begin
  outfile=(n_elements(ouf) ne 0)?((strlen(ouf[i]) ne 0)?ouf:fnAddSubfix(file[i],'_points')):fnAddSubfix(file[i],'_points')
   
  ;read data from file and set it in points
  readcol,file[i],label,col0,col1,col2,format='A,F,F,F',_strict_extra=extra,skip=skip
  print, 'first label read from file '+file[i]+': ',label[0]
  cols=[[col0],[col1],[col2]]
  
  xdata=cols[*,(colorder)[0]-1]
  ydata=cols[*,(colorder)[1]-1]
  zdata=cols[*,(colorder)[2]-1]
  

  writecol,outfile,xdata,ydata,zdata,header=header
endfor
    

end