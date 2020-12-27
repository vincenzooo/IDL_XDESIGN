function READ_DATAMATRIX, file,skipline=skip,fieldwidth=fieldwidth, $
          delimiter=delimiter,numline=nl,$
          header=header,type=type,stripblank=strip,x=x,y=y,comment=comment

; Read a matrix from file to an array. 
; It must be flexible e.g. to be used in place of READCOL when the number of columns 
; is not known in advance. Number of columns is determined by last valid line read.
; return a matrix of strings (as default, it can be changed with TYPE option).

;added all options. N.B. The code for FIELDWIDTH is missing, but I don't remember
; what the option was for (this also could mean that the option is not so useful).
; It probably was for fixed width data fields? 

;HEADER is a out variable that can be used to return an array of string with the
; content of the first SKIPLINE lines.
;comment (TODO) is a string or an array of strings. A line is ignored if it starts by any
; of the characters in the vector. 
; X and Y optional return argument, if variable is passed, get from stripping first row and columns

;NUMLINE: maximum number of lines to be read after the header.
;
;If STRIPBLANK is set, blank lines are ignored (default TRUE)
;
;2020/12/27 completely rewritten and tested.
;2020/12/27 corrected bug on COMMENT (failing if not set). 
;2019/05/01 added x and y optional return argument, if present, strip from matrix first row and col. 

;2013/02/09 added keyword type. 
;If TYPE is specified, Expression is converted to the specified type. Otherwise data
;are returned as strings.
; See IDL help for a list, in IDL 8.2 is:
; 0   UNDEFINED
; 1   BYTE
; 2   INT
; 3   LONG
; 4   FLOAT
; 5   DOUBLE
; 6   COMPLEX
; 7   STRING
; 8   STRUCT
; 9   DCOMPLEX
; 10  POINTER
; 11  OBJREF
; 12  UINT
; 13  ULONG
; 14  LONG64
; 15  ULONG64

;2013/02/09 found incredible bug, the number of column is determined by the last line
; if it is white the reading is wrong. The bug could be always existing or introduced
; in last week.
; Added STRIPBLANK flag
; author: Vincenzo Cotroneo

if n_elements(skip) eq 0 then s=0 else s=skip
if n_elements(strip) eq 0 then strip = 1

;read file in array of lines
OPENR, unit0, file, /GET_LUN
ll = strarr(1) ; single line
lines = []; strarr(1)  ; all lines
i=0L
while ~ EOF(unit0) do begin
  READF,unit0 , ll
  if strlen(strtrim(ll,2)) ne 0 then lastline=ll
  lines=[[lines],[ll]]
endwhile
free_lun, unit0
;if n_elements(separator) eq  0 then separator=' ' do not work with tab

;skip and read header 
if arg_present(header) then header=lines[0:s-1]
lines=lines[s:*]

;trim final lines redefining LINES and NROWS
if n_elements(nl) ne 0 then $
  if n_elements(lines) gt nl then lines = lines[0:s-1]
nrows=n_elements(lines)

;calculate ncols from last good line
if n_elements(delimiter) eq 0 then ncols=n_elements(strsplit(lastline)) $
else ncols=n_elements(strsplit(lastline,delimiter))  ;delimiter can be updated to use regex

;create matrix and load ll in columns (the first index rotates first,
; it is first to address with * on first index)
;data=strarr(ncols,nrows)
data=[]
foreach ll, lines do begin
  ;ignore comments
  if n_elements(comment) eq 0 || in(strmid(strtrim(ll,2),0,1),comment) ne 1 then begin
    if keyword_set(strip) eq 0 or strlen(strtrim(ll,2)) ne 0 then begin
      if n_elements(delimiter) eq 0 then split=strsplit(ll,/extract) $
        else split=strsplit(ll,/extract,delimiter)
        ;data[*,i]=split
        if n_elements(split) ne ncols then split=replicate(split,ncols) ; for white lines if strip=0
        data=[[data],[split]]
    endif
  endif
endforeach

if arg_present(x) then begin
  x=data[*,0]
  data=data[*,1:*]
  if arg_present(y) then x=x[1:*] ;remove the corner element
endif
if arg_present(y) then begin
  y=data[0,*]
  data=data[1:*,*]
endif
if n_elements(type) ne 0 then data=fix(data,type=type)
return,data

end
