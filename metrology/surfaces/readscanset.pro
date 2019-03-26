function readScanSet,filelist,nskip=skip,_extra=extra,idstring=idstring,$
  folder=folder
;read the set of files listed in the vector of strings FILELIST.
;If FILELIST is a single element, it is interpreted as the name of
; a text file containing a list of different data files, the file is read
; and the routine is launched recursively. 
; extra keywords are passed to the initialization routine of CMMdatafile.
; The value of nscans is the number of scans in each data file.
; FOLDER is the base folder where to look for the files to read.
; If not provided, the position of the filelist (if a filename is passed)
;   or the current directory (if filelist is passed as array of filenames) 
;   are used.


  if n_elements(filelist) eq 0 then message,'Argument filelist not provided'
  if n_elements(filelist) eq 1 then begin 
    ;transform in a list and calls itself
    listOfFiles=readFileList(filelist)
    dir=file_dirname(filelist)
    return,readScanSet(listOfFiles,_extra=extra,folder=dir)
  endif
 
  idstring= n_elements(idstring) ne 0?idstring:(string(n_elements(filelist))+' files (in '+$
        file_basename(file_dirname(filelist[0]))+')')

  ;read all data from files and return the merged object.
  ;the first nskip lines are ignored.
  ;nskip=11
  ;cd,current=current
  dir= n_elements(folder) eq 0? '':folder+path_sep()
  file=filelist[0]
  scan=obj_new('CMMdatafile',dir+file,_strict_extra=extra, skip=skip)
  for i=1l,n_elements(filelist)-1 do begin
    file=filelist[i]
    tmp=obj_new('CMMdatafile',dir+file,_extra=extra, skip=skip)
    scan=scan->merge(tmp,/destroy,idstring=idstring)
  endfor

  return,scan
end

filelist00b=fn('D:\transfer_spie\work_ratf\Optics#4\2011_06_22/listfile_00Vb.txt')
act13_00Vb=readScanSet(filelist00b,skip=11,$
           nscans=1,colorder=[2,3,1],npx=21,npy=22,type='Surf',zfactor=-1000)
act13_00Vb->draw
obj_destroy,act13_00Vb

folder='E:\work\work_pzt\measure_data\17b\data\2012_02_03'
file1='surface1x_1089p_10refpoints_2012_02_03_153742.dat'
file2='surface1x_1089p_10refpoints_2012_02_03_175752.dat'
a=readscanset([file1,file2],folder=folder,skip=102,$
    nscans=1,colorder=[2,3,1],npx=31,npy=31,$
    type='Surf',zfactor=-1000,numline=1089,_extra=extra)

end