
;+
;2019/04/05 from readnamelistVar with changed interface, oriented to read namelists
;  not individual variables.
;  
;  It assumes each namelist start with a namelist name marked with initial symbol &
;  followed by a set of variable definitions each one on a different line
;  and a terminating character / indicating the end of the namelist.
;  An example is
;  
;  &function_variables
;  variable1=5
;  variable2= 'a'
;  variable3 = 'notes about this function'
;  /
;  
;  namelist blocks start and end don't need to be consistent. Meaning that 
;  the variable reading normally stop at first ending. If override is set,
;  variables after the terminator are still read and used to override previously 
;  listed values.
;
;old readNameListVar
;read a namelist variable from file if found.
;if not found and silent is set, return a string with an error message,
;if silent is not set, raise an error.
;2019/02/07 if launched without varname, returns all variables as structure.
;2019/04/05 add namelist parameter, if passed read only the namelist,
;  otherwise search directly for variable, independently on namelist.
;
;-

function block_to_struct,block,lines,separator=separator
    ;remove terminations from a single input block and return a structure.
    ;
    ; In this simple version, just remove first and last lines without any check.
    ; Everything after 1st character \goes in name
    ;first line is expected to contain the namelist name,
    ;  last line an empty terminator and is discarded.
    
    name = strmid(strtrim(block[0],2),1)
    
    ;varlist=list()
    h=hash() ;tried at first with struct, but was unsuccessful in creating it. hash can be converted to struct.
    foreach l, block[1:-2] do begin
      val=strsplit(l,separator,/extract)
      if n_elements(val) ne 2 then message, "wrong number of elements per line: "+l
      h=h + hash(val[0],val[1])  ;hash concatenation
      ;varlist.add,val,/extract
    endforeach
    
    return, h.tostruct()
end


function  readNamelist,file,namelist,silent=silent,separator=sep,$
          stringdelimiter=sd

  if n_elements(sd) eq 0 then stringdelimiter="'"+'"' else stringdelimiter=sd
  if n_elements(sep) eq 0 then sep="="
  get_lun,nf
  openr,nf,file
  line =strarr(1)
  
  ;create hash with all possible variables
  lines=[]
  while ~ EOF(nf) do begin
  	READF,nf , line
  	if strlen(strtrim(line,2)) ne 0 then lines=[lines,strtrim(line,2)]
  endwhile
  
  if n_elements(namelist) ne 0 then message,"option `Namelist` not implemented yet"
  
  ;divide in namelists
  blockstart=where(lines.startswith('&'),c)
  
  nls=list()
  for i=0, n_elements(blockstart)-2 do begin
    nls.add,block_to_struct(lines[blockstart[i]:blockstart[i+1]-1],separator=sep)
  endfor
  
  
  
  ; filter required variables
  if snlstrlowcase(l0) eq strlowcase(varname) then begin
    free_lun,nf
    ;if string variable into apostrophes, remove them.
    val=strtrim(l[1],2)
    val=strsplit(val,stringDelimiter,/extract)
    return,val[0]
  endif
  
  ;it gets here only if something went wrong.
  free_lun,nf
  if n_elements(silent) eq 0 then silent=0
  mes="variable <"+varname+"> not found in file: "+file
  
  if silent ne 0 then begin
    return,mes
  endif else begin
    message,mes
  endelse
  
  foreach line,lines do begin
    l=strsplit (line,sep,/extract)
    l0=strtrim(l[0],2)
    print, l0
  endforeach
  
  
  ;return h_vars




end


;test

cd, programrootdir()

datadir='../../test/test_data/F10D394ff010_thsx'
testfile =datadir+path_sep()+'imp_offaxis.txt'

print,readNamelist(testfile)


end
