pro write_datamatrix,file,d,header=header,x=x,y=y,padding=padding,$
    separator=separator
;write a matrix on file. If FILE is an integer, 
; assume that a file is already open use FILE as the unit number.
; If header is provided print it at the beginning. 
; If x and/or y is provided, use them for first row and column. 
; If both of them are provided the string PADDING (default='0.0' 
; is used to fill the first row-first column element).

if size(file,/type) ge 1 and size(file,/type) le 5 then filenum=file 

if n_elements(d) eq 0 then message,'you must provide data to write'
data=d

size=size(data)
if size[0] gt 2 then begin
  print,"data dimensions larger than 2 not yet implemented!"
  stop
endif else if size[0] eq 1 then begin
  nrow=1
  ncol=size(1)
endif else begin
  nrow=size[2]
  ncol=size[1]
endelse

if n_elements(separator) eq 0 then sep='  ' else sep=separator 

if n_elements (filenum) ne 0 then $
  nfile=filenum $
else begin 
  get_lun,nfile
  openw,nfile,file
endelse

;write header if present
if n_elements(header) ne 0 then begin 
;  printf,nfile,strjoin(string(header),'    ')
    ;the condition is needed if you call write_datamatrix from a routine
    ; that builds a default header and you want sometimes write without header.
    ; in that case you can pass an empty string to the calling routine.
    if strlen(header[0]) ne 0 then printf,nfile,header[0]
   for i =1, n_elements(header)-1 do begin
    printf,nfile,header[i]
   endfor
endif

if n_elements(X) ne 0 then begin
  if n_elements(X) ne ncol then message,'non matching number of columns,'+$
        newline()+'data: '+string(ncol)+newline()+$
        'X:'+string(n_elements(X))
  data=[[string(x)],[data]]
endif
if n_elements(Y) ne 0 then begin
  if n_elements(x) ne 0 then yy=[n_elements(padding) eq 0?'0.0':padding,string(y)]
  if n_elements(Y) ne nrow then message,'non matching number of rows,'+$
        newline()+'data: '+string(nrow)+newline()+$
        'Y:'+string(n_elements(Y))
  data=[transpose(yy),data]
endif

for j=0,nrow-1 do begin
  printf,nfile,strjoin(data[*,j],sep)
endfor
if n_elements(filenum) eq 0 then free_lun,nfile

end