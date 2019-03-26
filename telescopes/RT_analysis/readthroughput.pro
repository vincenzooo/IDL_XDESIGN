function readThroughput,filename,ener,k=k,header=header
;read a throughput file and the corresponding energy

header=strarr(1)
OPENR, unit, filename, /GET_LUN
  readf,unit,header
free_lun,unit

;process header to extract number of coulumns and energy
spheader=strsplit(header,/extract)
if strmid(header,0,13) eq 'throughput_at' then begin
  ;new version
  nener=n_elements(spheader)-3
  ener=float(spheader[1:nener])
endif else begin
  if strmid(header,0,13) eq 'throughput at' then begin
    ;first version
    nener=n_elements(spheader)-6
    ener=float(spheader[2:nener+1])
  endif else begin
  message,"Version of throughput file not recognized from the header"
  stop
  endelse
endelse 
;read data
tmpdata= float(read_datamatrix (filename,skip=1))
sizedata=size(tmpdata,/dimensions)
data=tmpdata[0:sizedata[0]-2,*]
k=fix(tmpdata[sizedata[0]-1,*]+0.5)
return, data
end

filename='E:\work\workOA\traie8\studioDistrib1\caseOfFig2\throughput02.txt'
thr=readThroughput(filename,energy,k=k,header=header)
end