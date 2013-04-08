pro rotoAdjustScale,logU=logU
; controlla che i file di misura listati in un file di testo siano
; con la giusta scala ed il giusto modo internal/external.
; senno' corregge.

correctType='external'
correctRange=660.
filelist='E:\work\work_wfxt\rotondimetro\misure\9_wfflat\lista.txt'
correctedSubfix='_croco'

folder=file_dirname(filelist)
list=readFileList(filelist)
nfiles=n_elements(list)
if n_elements(logU) eq 0 then logU=folder+path_sep()+'rotoAdjustScale_log.txt'

log=logfile(logU)
printF,log,"Log created on "+systime(0)
printf,log,"by rotoAdjustScale"
printf,log,"Folder: "+folder
printf,log,"Final measure type: "+correctType  
printf,log,"Final measure range: "+string(correctRange)
printf,log,"---------------------------------"
printf,log  

for j=0,nfiles-1 do begin
  correctionFactor=1.
  rotofile=folder+path_sep()+list[j]
  printf,log,"Process file: "+list[j]
  measureType=readNamelistVar(rotoFile,'measure',sep=':')
  if measureType ne correctType then begin
    printf,log,"Non correct type: ",measureType
    correctionFactor=-correctionFactor
  endif
  measureRange=readNamelistVar(rotoFile,'Rodenstock scale',sep=':')
  r=strsplit(measureRange,/extract)
  measureRange=float(r[0])
  if measureRange ne correctRange then begin
    printf,log,"Non correct range: ",measureRange
    correctionFactor=correctionFactor*correctRange/measureRange
  endif
  
  if correctionFactor eq 1. then printf,log,"OK" $
  else begin
    headerlines=8
    correctedFN=fnAddSubFix(rotofile,correctedSubfix,'.dat')
    ;create corrected file
    readcol,rotofile,angle,value,skip=headerlines
    ;;read header
    OPENR, unit0, rotofile, /GET_LUN
    for i=0,headerlines-1 do begin
      linea=strarr(1)
      READF,unit0 , linea
      if i eq 0 then header=[linea] else header=[header,linea]
    endfor
    free_lun,unit0
    ;;write corrected file
    Smoothing=strsplit(header[2],':',/extract,count=c)
    Smoothing=Smoothing[c-1]
    header[2]= 'Rodenstock scale: '+string(fix(correctRange))+'  Smoothing: '+string(smoothing)
    header[4]= 'Measure: '+correctType
    OPENW, unit0, correctedFn, /GET_LUN
    for i=0,headerlines-1 do begin
      printf,unit0,header[i]
    endfor
    for i=0,n_elements(angle)-1 do begin
      printf,unit0,angle[i],value[i]*correctionFactor
    endfor
    free_lun,unit0
    printf,log,"Corrected by a factor"+string(correctionFactor)+" in "+correctedFn
  endelse
  printf,log
  

endfor 

print,logFile(log,/close)


end

