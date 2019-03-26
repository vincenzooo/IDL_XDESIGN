pro CMMextractFromActual,fn,outfile,fromloc=fromloc,startstring=startstring

  openr, lun, fn, /get_lun
  nlines = FILE_LINES( fn, COMPRESS=compress )
  content=strarr(nlines)
  READF,lun,content
  free_lun,lun
  
  if n_elements(outfile) eq 0 then outfile=fnaddsubfix(fn,'_extracted')
  ;determine where alignment finish and measure start by looking for the point header 
  startline=(where(strmatch(content,'*'+startstring+'*',/fold_case)))[0]
  content=content[startline:n_elements(content)-1] ;cut content to contain only measured values
  ;extract point names
  for i=0,n_elements(content)-1 do begin
    if strmatch(content[i],startstring+'*') ne 0 then begin
      tmp=strsplit(content[i],'=',/extract)
      if n_elements(pnames) eq 0 then pnames=tmp[0] else pnames=[pnames,tmp[0]]
    endif
  endfor
  
  measlines=content[where(strcmp(strtrim(content,2),'ACTL/',5,/fold_case))] ;filter only lines containing measured values
  startpos=strpos(measlines,'<')
  l=strpos(measlines,'>')-startpos-1
  npoints=n_elements(measlines)
  ;if n_elements(pnames) ne npoints then message, 'the number of points from point names is not the same than the one from coordinates.'
  pnames=pnames[0:npoints-1]
  plines=strarr(npoints)
  for i=0,npoints-1 do begin
    tmp=strmid(measlines[i],startpos[i]+1,l[i])
    if i eq 0 then cols=float(strsplit(tmp,',',/extract)) else cols=[[cols],[float(strsplit(tmp,',',/extract))]]
  endfor
  
  ;loclines=content[where(strcmp(strtrim(content,2),'x',1,/fold_case))]
  cols=transpose(cols)
  writecol,outfile,pnames,cols[*,0],cols[*,1],cols[*,2]
;cols=[[col0],[col1],[col2]]
  
end

fn='/home/cotroneo/Desktop/work_ratf/run03/2011_05_06/surface-4x_552pt_00V_01.txt'
outf='/home/cotroneo/Desktop/work_ratf/run03/2011_05_05/surface-4x_552pt_00V_01.dat'
CMMextractFromActual,fn,outf,startstr='SCN-'

end