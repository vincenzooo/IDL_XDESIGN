pro fixbadpoints,y
;replace values of points with value 0 with the value of the previous point.
  for i=n_elements(y)-1,1,-1 do begin
    if abs(y[i]-y[i-1]) gt 15 then y[i-1]=y[i]
    
  endfor
end

pro fixlistoffiles
  ;2013/06/24 from previous program
  folder='2013_01_23\09_rnr278_yscan'
  filelist=['01_yscan_act09_Height.txt',$
            '02_yscan_act09_Height.txt',$
            '03_yscan_act09_Height.txt',$
            '04_yscan_act09_Height.txt',$
            '05_yscan_act09_Height.txt',$
            '06_yscan_act09_Height.txt',$
            '07_yscan_act09_Height.txt',$
            '08_yscan_act09_Height.txt',$
            '09_yscan_act09_Height.txt',$
            '10_yscan_act09_Height.txt']
          
for i=0,n_elements(filelist)-1 do begin
   f=folder+path_sep()+filelist[i]
   file_copy,f,fnaddsubfix(f,'_orig'),/overwrite
   readcol,f,x,y,delimiter=','
   fixbadpoints,y
   writecol,f,x,y,fmt='(f12.5,",",f12.5)'
endfor
end


pro scantimes,filename,starttime=starttime,endtime=endtime,t0=t0,files=files
;read a file with columns starttime, endtime, scanname
; and convert it in seconds from start of thermal logging.
; The first line is assumed to be the start time of the thermal logging.
; Rewrite the times in seconds on a file with same name and _sec happended. 

;2013/01/21 used for: 
; file='20121209\0117_ifprofiles\times.txt'
; scantimes,file
; file='20121209\0117_ifprofiles\times.txt'
; scantimes,file
  readcol, filename, startstr,endstr,scanname, format='A,A,A',comment='#'
  startsec=stringtojd(startstr,'h:m:s',/sec)
  t0=startsec[0]
  endsec=stringtojd(endstr,'h:m:s',/sec)
  startsec=(startsec-t0)[1:*]
  endsec=(endsec-t0)[1:*]
  writecol,fnaddsubfix(filename,'_sec'),startsec,endsec,scanname[1:*],$
    fmt='(2f22.6,tr3,a)'
end

function extractif,avg00v,avg04v,x0,x1,smoothwidth
  ;calculate the Influence function
  
  if04v=avg04v-avg00V
  if04v.extractxrange,xs=x0,xe=x1
  ;if04v.level ;,degree=0
  if04v.smooth,smoothwidth,/edge_truncate
  return,if04v
end

function getoffset,xydatalist,x0,x1
  ;get a vector of offset for leveling, considering only data between x0 and x1,
  ; then level the entire profiles
  tmp=xydatalist.extractxrange(xs=x0,xe=x1)
  tmp.level,degree=0,coeff=coeff
  obj_destroy,tmp
  offsets=coeff.toarray()
  for i =0,xydatalist.nscans-1 do begin
    xydatalist[i]=xydatalist[i]-(offsets[i]) 
    ;xydatalist[i]=xydatalist[i]-(offsets[i,0])-(offsets[i,1])*((xydatalist[i]).x)
  endfor
  return,offsets    ;[*,0]
end

pro analyze_drift,outfol,workdir,fl,xroi,nsm
  ;read from filelisttxt and create an array of groupnames and a list of filegroups, each filegroup
  ; is an array of strings containing filenames. Groups are listed in filelisttxt as blocks
  ; separated by an empty line. Each block containts the group name in the first line and the 
  ; filenames following.
  ;the file position is referred to the executable.
  outbase=outfol
  outfolder=outbase+path_sep()+workdir
  filelisttxt=outbase+path_sep()+fl ;first filelist of analysis
  lines=read_datamatrix(filelisttxt)
  sep=where(strtrim(lines,2) eq "",c)
  if c eq 0 then message, 'No Separators',/info
  start=0
  groupnames=[]
  filegroups=list()
  for i=0,c-1 do begin
    groupnames=[groupnames,lines[start]]
    filegroups.add,lines[start+1:sep[i]-1]
    start=sep[i]+1
  endfor
  groupnames=[groupnames,lines[start]]
  filegroups.add,lines[start+1:-1]
  
  ;create a dictionary with groupnames as a key and a corresponding xydatalist as value.
  profdict=hash()
  for i=0,n_elements(groupnames)-1 do begin
    profdict[groupnames[i]]=xydatalist(filegroups[i],delimiter=',')
  endfor
  
  offsets=list()  ;collect offsets
  ;these are lists of xydata elements and are written by
  ; write_datamatrix. They may be xydatalist.
  avgall=list() ;collect the average profile smoothed of each group
  avgall_sh=list()  ;same, but after removal of roi piston
  for i=0,n_elements(groupnames)-1 do begin
    groupname=groupnames[i]
    a=profdict[groupname]
    a.write,$  ;all scans in a group together
      outfolder+path_sep()+groupname+'_rep.dat',/together 
    (a.smooth(nsm))->write,$  ;same, but smoothed
        outfolder+path_sep()+groupname+'_rep_sm.dat',/together
    avgall.add,((a.smooth(nsm))->average()).y 
    offsets.add,getoffset(a,xroi[0],xroi[1])
    a.write,$ ; removed piston calculated in the roi
      outfolder+path_sep()+groupname+'_shift.dat',/together
    (a.smooth(nsm))->write,/together,$  ;same, but smoothed
      outfolder+path_sep()+groupname+'_shift_sm.dat'
    avgall_sh.add,((a.smooth(nsm))->average()).y
  endfor
  write_datamatrix,outfolder+path_sep()+'all_sm_avg.dat',$
    transpose([[(a.x)[0]],[transpose(avgall.toarray())]]),$
    header='#X    '+strjoin(groupnames,'  ')
  write_datamatrix,outfolder+path_sep()+'all_shift_sm_avg.dat',$
    transpose([[(a.x)[0]],[transpose(avgall_sh.toarray())]]),$
    header='#X    '+strjoin(groupnames,'  ')
  
  ; the MISSING keyword of the toarray function sucks (the entire column is set 
  ;   to MISSING if the column is not complete). 
  ; 2013/07/16
  ; Also: lists suck! It is undocumented, but it seems that if a list contains
  ;   arrays with different numbers of elements, the first one (not the longest) 
  ;   is used to determine the dimensions.
  ;   Do it manually:
  
  len_m=[]
  nsets=n_elements(offsets)
  for i=0,nsets-1 do len_m=[len_m,n_elements(offsets[i])]
  offmat=dblarr(nsets,max(len_m))+!VALUES.F_NAN
  for i = 0,nsets-1 do begin
    n=len_m[i]
    offmat[i,0:n-1]=(offsets[i])[0:n-1]
  endfor
  
  ;get differences from first point
  offmat_diff=offmat-rebin(offmat[*,0],size(offmat,/dimensions))
  write_datamatrix,outfolder+path_sep()+'offset.dat',[offmat,offmat_diff],$
    header='#'+strjoin(groupnames,'  ')+'   '+strjoin(groupnames,'_diff  ')+$
    '   '+strjoin(string(xroi),":")
  
  openw,u,outfolder+path_sep()+'groupnames.txt',/get
  printf,u,groupnames
  free_lun,u
  
end

