pro CMMdatafile::__setgrid,xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy
  
  points=self->getproperty(/points,/all)
  if n_elements(xgrid) eq 0 then begin 
    if n_elements(npx) ne 0 then begin
      xrange=range(points[*,0])
      xgrid=creategrid(x0=xrange[0],x1=xrange[1],np=npx+2)
      xgrid=xgrid[1:npx]
    endif else begin
      beep
      message,'neither xgrid or npx are set, cannot set grid',/informational
      return
    endelse
  endif else begin
      if n_elements(npx) ne 0 then begin
        beep
        message,' xgrid and npx are both set, npx will be ignored',/informational
      endif
  endelse
  
  if n_elements(ygrid) eq 0 then begin 
    if n_elements(npx) ne 0 then begin
       yrange=range(points[*,1])
       ygrid=creategrid(x0=yrange[0],x1=yrange[1],np=npy+2) 
       ygrid=ygrid[1:npy]
    endif else begin
      beep
      message,' neither ygrid or npy are set, cannot set grid',/informational
      return
    endelse
  endif else begin
      if n_elements(npy) ne 0 then begin
        beep
        message,' ygrid and npy are both set, npy will be ignored',/informational
      endif
  endelse

  (*self.average)->setproperty,xgrid=xgrid,ygrid=ygrid
  (*self.errormap)->setproperty,xgrid=xgrid,ygrid=ygrid
  
  for i=0,self.nscans-1 do begin
    (*self.scanlist)[i]->setproperty,xgrid=xgrid,ygrid=ygrid
  endfor
  self._changed=1

end

function CMMdatafile::__addAvgPlane,plane
  ;add a first plane with the average.
  
  if size(plane,/n_dimensions) lt 2 then p0=[[plane],[plane]] else begin
    pAvg=total(plane,2)/self.nscans
    p0=[[pAvg],[plane]]
  endelse
  return,p0
end

pro CMMdatafile::__setplane,plane
    ;this internal routine sets the subscan planes, according to
    ; the format of the PLANE argoment, which can be 0, a 3-elements 
    ; vector, or a matrix [3,nscans+1].
    ;modified 2012/01/18 matrix optimal format is [3,nscans], if
    ;[3,nscans+1] is provided, the elements [*,0] (the plane of average
    ; scan) will be overwritten. The plane of the average cannot be set,
    ;it is a read-only value and it is derived from the other planes.
    ;If you really want to do insane things, like setting the plane of the average
    ; independently from the other components, you are forced to extract the average
    ; scan with extract (return a CMMdatafile object) or getScan(return a CMMsurface object).
    
    ;FIXME: overwrite plane 0 (average) and show a warnign
    ;FIXME: la media del piano e' sbagliata
    
    if n_elements(plane) eq 0 then begin
      beep
      message,'Plane argument not provided, plane will not be set',/informational 
      return
    endif
    
    ;TODO: better dimensional check, e.g. a 2-elements vector is accepted
    ;even if worng.
    ;if scalar must be 0.
    if n_elements(plane) eq 1 then begin
      if plane eq 0 then p0=(*self.average)->getproperty(/plane)*0 else message,'scalar, non-null value provided for plane, cannot set! Plane:'+string(plane)
    endif else p0=plane
    
    if size(p0,/n_dimensions) eq 1 then begin    ;vector
        ndim=n_elements(p0)
        if ndim ne n_elements((*self.average)->getproperty(/plane)) then message,'non-matching number of dimension for plane (vector), plane:'+string(p0)
        p0=rebin(p0,ndim,self.nscans+1)
    endif else if size(p0,/n_dimensions) eq 2 then begin
        s=size(p0,/dimensions)
        if s[0] ne n_elements((*self.average)->getproperty(/plane)) then message,$
            'wrong numeber of columns for plane matrix:'+string(p0)
        if s[1] eq self.nscans+1 then begin
          beep
          message,"The plane for the average scan will be overwritten.",/info
          p0=p0[*,1:self.nscans] ;it will be added again below.
          s=size(p0,/dimensions)
        endif 
        if s[1] eq self.nscans then begin
          ;add the plane for the average
          p0=self->__addAvgPlane(p0)
          s=size(p0,/dimensions)
        endif else message ,'wrong number of planes:'+string(p0)
    endif else message ,'unrecognized matrix for plane:'+string(p0)
    
    (*self.average)->setproperty,plane=p0[*,0]
    for i=0,self.nscans-1 do begin
      (*self.scanlist)[i]->setProperty,plane=p0[*,i+1]
    endfor
    self._changed=1
    
end

function CMMdatafile::__getplane,all=all
            
        p0=(*self.average)->getproperty(/plane)
        if keyword_set(all) then begin
          for i=0,self.nscans-1 do begin
            p0=[[p0],[(*self.scanlist)[i]->getProperty(/plane)]]
          endfor
        endif
        return,p0
end

pro CMMdatafile::__setpoints,points
  ;divide in blocks and populate scanlist
  npoints=(size(points,/dimension))[0]
  blocklen=npoints/self.nscans
  if self.nscans*blocklen ne npoints then message,'number of points '+$
    'is not a multiple of the expected number of scans:'+newline()+$
    'file='+self.filename+$
    ', points on file='+string(npoints)+$
    ', number of scans expected='+string(self.nscans)
  for i=0,self.nscans-1 do begin
    points_i=points[(i)*blocklen:(i+1)*blocklen-1,*]
    (*self.scanlist)[i]->setProperty,points=points_i
  endfor
  self._changed=1
  
end

pro     CMMdatafile::getproperty,$
        points=points,$
        ;allpoints=allpoints,$
        filename=filename,$
        idstring=idstring,$
        nscans=nscans,$
        colorder=colorder,$
        type=type,$
        plane=plane,$
        xgrid=xgrid,$
        ygrid=ygrid,$
        scanlist=scanlist,$
        data=data,$
        errormap=errormap,$
        resolution=resolution, $ ;machine resolution in um, used for statistics computation
        zfactor=zfactor,$
        all=all
        
        if arg_present(xgrid) then xgrid=(*self.average)->getproperty(/xgrid)
        if arg_present(ygrid) then ygrid=(*self.average)->getproperty(/ygrid)
        if arg_present(data) then data=self->getproperty(/data)
        if arg_present(errormap) then errormap=self->getproperty(/errormap)
        if arg_present(points) then points=self->getproperty(/points,all=all)
        if arg_present(filename) then filename=self.filename
        if arg_present(idstring) then idstring=self.idstring
        if arg_present(nscans) then nscans=self.nscans
        if arg_present(colorder) then colorder=*self.colorder
        if arg_present(plane) then plane=self->__getplane(all=all)
        if arg_present(nscans) then nscans=self.nscans
        if arg_present(type) then type=self.type
        if arg_present(scanlist) then scanlist=*self.scanlist
        if arg_present(resolution) then resolution=(*self.average)->getproperty(/resolution)
        if arg_present(zfactor) then zfactor=self->getproperty(/zfactor)
end

function CMMdatafile::getproperty,index,$
        points=points,$
        ;allpoints=allpoints,$
        filename=filename,$
        idstring=idstring,$
        nscans=nscans,$
        colorder=colorder,$
        type=type,$
        plane=plane,$
        xgrid=xgrid,$
        ygrid=ygrid,$
        data=data,$
        errormap=errormap,$
        scanlist=scanlist,$
        resolution=resolution, $ ;machine resolution in um, used for statistics computation
        zfactor=zfactor,$
        all=all
        
        if n_params() gt 1 then message,'called with more than one keyword, '+$
          'only the first one (according to the internal program order) will be returned.'
        if keyword_set(data) then begin
          self->_update
          avg=(*self.average)->getproperty(/data)
          if not keyword_set(all) then result=avg $
          else begin
            ;create and return a datacube [index,x,y] 
            ;it should work with index, but at the moment it works only with option /all.
            result=fltarr(self.nscans+1,n_elements(self->getproperty(/xgrid)),$
                            n_elements(self->getproperty(/ygrid)))
            for i=1,self.nscans do begin
              tmp=self->getscan(i)
              result[i,*,*]=tmp->getproperty(/data)
              obj_destroy,tmp
            endfor
          endelse 
          return,result
        endif
        ;if keyword_set(allpoints) then return,*self.allpoints
        if keyword_set(points) then begin
          if keyword_Set(all) then begin
              i=0
              points=(*self.scanlist)[i]->getproperty(/points)
              for i=1,self.nscans-1 do begin
                points=[points,(*self.scanlist)[i]->getproperty(/points)]
              endfor
          endif else begin
            self->_update ;this is needed to update self.average
            points=(*self.average)->getproperty(/points)
          endelse
          return, points
        endif
        if keyword_set(errormap) then begin
          self->_update ;this is needed because errormap is a GRIDDATA object (no _update)
          return,(*self.errormap)->getproperty(/data)
        endif
        if keyword_set(filename) then return,self.filename
        if keyword_set(idstring) then return,self.idstring
        if keyword_set(nscans) then return,self.nscans
        if keyword_set(colorder) then return,*self.colorder
        if keyword_set(plane) then return,self->__getplane(all=all)
        if keyword_set(nscans) then return,self.nscans
        if keyword_set(type) then return,self.type
        if keyword_set(scanlist) then return,*self.scanlist
        if keyword_set(xgrid) then return,(*self.average)->getproperty(/xgrid)
        if keyword_set(ygrid) then return,(*self.average)->getproperty(/ygrid)
        if keyword_set(resolution) then return,((*self.scanlist)[0])->getproperty(/resolution)
        if keyword_set(zfactor) then return,(*self.average)->getproperty(/zfactor)
        return,(*self.average)->getproperty(_extra=extra)
end

pro CMMdatafile::setproperty,$
        points=points,$
        filename=filename,$
        idstring=idstring,$
        colorder=colorder,$
        nscans=nscans,$
        type=type,$
        plane=plane,$
        xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy,$
        resolution=resolution,zfactor=zfactor
        
        if n_elements(nscans) ne 0 then self.nscans=nscans
        if n_elements(idstring) ne 0 then begin
          ;add possibility to add an array of string or to set all to the same string with /all
          self.idstring=idstring
          for i=0,self.nscans-1 do (*self.scanlist)[i]->setproperty,idstring=self.idstring+'#'+string(i+1,format='(i2.2)')
          (*self.average)->setproperty,idstring=idstring+' - average'
          (*self.errormap)->setproperty,idstring=idstring+' - rms error'
        endif
        if n_elements(filename) ne 0 then begin
          self.filename=filename
          self._changed=1
        endif
        if n_elements(type) ne 0 then begin
          self.type=type
          self._changed=1
        endif
        if n_elements(points) ne 0 then self->__setpoints,points 
        if (n_elements(xgrid) ne 0 or n_elements(npx) ne 0) and $
        (n_elements(ygrid) ne 0 or n_elements(npy) ne 0) then begin
          self->__setgrid,xgrid=xgrid,npx=npx,ygrid=ygrid,npy=npy
        endif
        if n_elements(plane) ne 0 then begin
          self->__setplane,plane
        endif
        if n_elements(resolution) ne 0 then begin
          (*self.average)->setproperty,resolution=resolution/self.nscans
          (*self.errormap)->setproperty,resolution=resolution/sqrt(float(self.nscans))
          for i=0,self.nscans-1 do ((*self.scanlist)[i])->setproperty,resolution=resolution
        endif
        if n_elements(zfactor) ne 0 then begin
          (*self.average)->setproperty,zfactor=zfactor
          (*self.errormap)->setproperty,zfactor=abs(zfactor)
          for i=0,self.nscans-1 do ((*self.scanlist)[i])->setproperty,zfactor=zfactor
        endif
        ;if n_elements(zfactor) ne 0 then self.zfactor=zfactor
        (*self.average)->setproperty,_extra=extra
end
  
pro CMMdatafile::clip,index,nsigma=nsigma,min=min,max=max,toavg=toavg,clipvalue=value,_extra=extra
  ;clip the image, see clip procedure documentation. This adds the flag /TOAVG that sets the average
  ; image as reference image.
  
  if n_elements(index) eq 0 then index=indgen(self.nscans)+1 
  if n_elements(toavg) ne 0 then refImage=(*self.average)->getproperty(/data)*self->getproperty(/zfactor)
    
  for i=1,n_elements(index) do begin    
    ((*self.scanlist)[i-1])->clip,min=min,max=max,clipvalue=refimage,$
    nsigma=nsigma,refimage=refimage,torefimage=toavg,_extra=extra
  endfor
  
  self._changed=1
end

;function CMMdatafile::_calculateAverage,index   
;      
;      ;populate self.points. Since the points do not exist use the average
;      ;of scanlists to generate fake points.
;      ;Note that the leveling procedure of cmmsurface is automaticaly
;      ;called when retrieving data. To obtain correct 'raw' data, set plane to zero, 
;      ;than set it back to the original value.
;      
;      result=(*self.average)->duplicate()
;      result->setproperty,idstring=(*self.average)->getproperty(/idstring)+'('+strjoin(string(index,format='(i2.2)'),', ')+')'
;      
;      p0=self->__getplane(/all)
;      self-> setproperty,plane=[0,0,0]
;      
;      data=(*self.scanlist)[index[0]-1]->getProperty(/data) 
;      if n_elements(index) gt 1 then begin
;        for i=1,n_elements(index)-1 do begin
;          data=data+(*self.scanlist)[index[i]-1]->getProperty(/data) 
;        endfor
;      endif
;      data=data/n_elements(index)
;      result->setproperty,data=data
;      avgplane=total(p0[*,index])/n_elements(index)
;      result->setproperty,plane=avgplane
;      
;      return,result
;end

pro CMMdatafile::_calculateAverage   
      
      ;populate (*self.average).points . Since the points do not exist use the average
      ;of scanlists to generate fake points.
      ;Note that the leveling procedure of cmmsurface is automaticaly
      ;called when retrieving data. To obtain correct 'raw' data, set plane to zero, 
      ;than set it back to the original value.
      
      ;p0=self->__getplane(/all)
      ;self-> setproperty,plane=0
      
      data=(*self.scanlist)[0]->getProperty(/data) 
      for i=1,self.nscans-1 do begin
        data=data+(*self.scanlist)[i]->getProperty(/data) 
      endfor
      data=data/self.nscans
      (*self.average)->setproperty,data=data
      ;self->setproperty,plane=p0
      
      (*self.average)->getproperty,data=data ;this is needed to get update,
                                             ;changes only for rounding effects.
      error=data*0
      for i=0,self.nscans-1 do begin
        error=error+(data-(*self.scanlist)[i]->getProperty(/data))^2 
      endfor
      ;standard deviation of the mean
      (*self.errormap)->setproperty,data=sqrt(error/(self.nscans-1))/sqrt(self.nscans)
end

pro CMMdatafile::_update
  if n_elements((*self.average)->getproperty(/xgrid)) ne 0 and n_elements((*self.average)->getproperty(/ygrid)) ne 0 then begin
    if self._changed ne 0 then begin
      self->_calculateAverage ;this populate average and errormap according to the present grid
      ;single subimage data are updated when data are retrieved, according to CMMsurface 
      self._changed=0
      ;self->_flatten
      ;self->_calculateError
    endif 
  endif else begin
      if n_elements((*self.average)->getproperty(/xgrid)) eq 0 then message, 'Xgrid is not defined',/informational
      if n_elements((*self.average)->getproperty(/ygrid)) eq 0 then message, 'Ygrid is not defined',/informational
      beep  ;also print,string(7B)
      message, 'cannot calculate data!';,/informational
      self._changed=0
      return
    endelse
end

function CMMdatafile::planefit,all=all,_extra=extra
  ;find the bestfit plane for the average of all scans
  ;return the single plane or a matrix (nscans, avg is not included) 
  ;if ALL is set.


  if keyword_set(all) then begin
    i=0
    plane=[(*self.scanlist)[i]->planefit(_extra=extra)]
    for i =1,self.nscans-1 do begin
        plane=[[plane],[(*self.scanlist)[i]->planefit(_extra=extra)]]
    endfor
  endif else plane=(*self.average)->planefit(_extra=extra)
  
  return,plane
end

pro CMMdatafile::planefit,all=all,_extra=extra
  self->setproperty,plane=self->planefit(all=all,_extra=extra)
end


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

pro CMMdatafile::readfromFile,file_reader,_extra=extra
;this routine replaces the previous one, that was specific of the CMM
; data format. file_reader is a routine provided by the user as a string.

  
end


pro read_CMMdata,filename=fn,colorder=co,checkLabel=checkLabel,_extra=extra
;old read_data routine, 2012/12/26 try to replace it with a reader routine
; to manage different data formats.
; 
;this routine reads data processed after perl script, data are expected to be
;on 4 columns with Point name, X, Y, Z.
;COLORDER is a 3 elements vector indicating the order of the column (in base 1, e.g. [3,1,2]
; read data as Z,X,Y, with Z being the surface height.
;In case of wrongly written (or saved) CMM programs (.PRG), the value in locations (used by the perl script)
; can be wrong. In that case the points coordinates can be extracted by the ACTL/ value recorded in the
; CMM program file .PRG. The IDL script cmmreadprg can be used to this aim.
    
    self->setproperty,filename=fn,colorder=co
    self->getproperty,filename=filename,colorder=colorder
    if not testString(filename) then begin 
      beep
      wait,2
      message,"Filename is not defined, cannot load data.",/info
    endif
    
;    ;determine the type of data file
;    if keyword_set(prg) and keyword_set(text) then message, ('PRG and TEXT cannot be both set')
;    if keyword_set(prg) then type='prg' else begin
;      dummy=fsc_base_filename(filename,ext=ext)
;      if keyword_set(text) eq 0 or ext eq '.txt' then type='prg' else type='text'
;    endelse
    
    ;read data from file and set it in points
    readcol,filename,label,col0,col1,col2,format='A,F,F,F',_extra=extra
    message,"Colorder: "+strjoin(string(colorder)),/info
    cols=[[col0],[col1],[col2]]
    
    if n_elements(checklabel) ne 0 then begin
      if label[0] ne checklabel then message, "label not corresponding: "+label[0]
    endif else begin
      ;beep
      message, "first label read from "+filename+":"+label[0],/info
    endelse
    
    xdata=cols[*,(colorder)[0]-1]
    ydata=cols[*,(colorder)[1]-1]
    zdata=cols[*,(colorder)[2]-1]

    points=[[xdata],[ydata],[zdata]]
    self->setproperty,points=points
end

function CMMdatafile::getScan,index,average=average,error=error,idstring=idstring,destroy=destroy ;,errormap=errormap
  ;+
  ;Return a CMMsurface object if possible (e.g. average data or single scan),
  ; otherwise return a GRIDDATA object (e.g. for errormap).
  ;-
  
  self->_update
  
;  average and error can be called by number or by keyword (the call by numebr is needed for 
;making it simpler the call by inside a routine (e.g. getstats). 
  
  ;check parameters consistency. initialize i to index (/average or /error set i=0). 
  if keyword_set(average) then begin
     if keyword_set(error) then message,'Errormap and average keyword cannot be both set'
     i=0
  endif else $
    if n_elements(index) ne 0 then i=index $
    else if not keyword_set(error) then $
        message,'No index provided for extracting image scan, and /ERROR and /AVERAGE keywords are not set!'  else i=0
  ;check pars
  if n_elements(excludeIndex) ne 0 then begin
    if i ne 0 and not(keyword_set(error)) then message,'EXCLUDEINDEX can be used only if ERROR or AVERAGE is set' 
  endif  
  
  ;if INDEX (scalar and in the allowed range) is set to 0 get average or error maps, otherwise get the scan   
  if n_elements(i) gt 1 then message,'the image index must be a scalar, use EXTRACT method if you '+$
          'want to get a CMMdatafile object with multiple scans in it.'$
  else if i eq 0 then begin
     ;in this case the result is a griddata object
     ;self->_update  ;needed to recalculate errormap or average.
     if keyword_set(error) then begin
        result=(*self.errormap)->duplicate() 
     endif else result=(*self.average)->duplicate()
  endif else begin 
    if (i gt self.nscans) or (i lt 0) then message,'Index is larger than the number of scans, cannot get scan.'+string(i)
    result=(*self.scanlist)[i-1]->duplicate()
    ;FIXME: duplicated code, error is calculated also in _calculate average, with a different process.
    if n_elements(idstring) ne 0 then result->setproperty,idstring=idstring
    if keyword_set(error) then begin
      idstring=n_elements(idstring) eq 0?(result->getproperty(/idstring)+': error'):idstring
      result=result->subtract(self->getscan(/average),/destroy)
      result->setproperty,idstring=idstring
    endif
  endelse
  
  if  keyword_set(destroy) then obj_destroy,self
  return,result

end

function runningRms,vector
  s0=indgen(n_elements(vector))+1
  s1=total(vector,/cumulative)
  s2=total(vector^2,/cumulative)
  rms=sqrt((s0*s2-s1^2)/(s0*(s0-1)))
  return,rms
end

;function CMMdatafile::rmsTrend,index,outfile=outfile,singleScanRms=singleScanRms,$
;  _extra=extra,level=level
;;return as a table the total rms as a function of included data sets.
;;INDEX is the (sorted) array of indices of the scans to consider for
;; the calculation.
;;Return a vector of rms.
;;If OUTFILE is indicated, write results on file. 
;
;;TODO:
;;eliminate the loop by using realtime formula runningRms
;  if keyword_set(level) ne 0 then begin
;    ;if called with level keyword, calculate rmstrend for 
;    ;unleveled and leveled data.
;    p0=self->getproperty(/plane)
;    self->setproperty,plane=0
;    nscans=self->getproperty(/nscans)
;    rtm3=self->rmsTrend(colheader='unleveled',/noplot,singleScanRms=rmsScans_unlev)
;    rtm3=rtm3->transpose(/destroy)
;    ;outvars=4,/error,/all: 
;    ; is the rms of the difference with the average value. 
;    rmsScans_unlev=self->getstats(/error,/all,/noplot,outvar=[4])
;    rmsScans_unlev=rmsScans_unlev[1:nscans]
;    ;flatten 
;    self->planefit,/all ;flatten subscan individually
;    tmp=self->rmsTrend(colheader='leveled',/noplot,singleScanRms=rmsScans_levall)
;    rmsScans_levall=self->getstats(/error,/all,/noplot,outvar=[4])
;    rmsScans_levall=rmsScans_levall[1:nscans]
;    tmp=tmp->transpose(/destroy)
;    tmp=tmp->join(rtm3,/horizontal,/destroy)
;    result=tmp->write()
;    result=[[total(rmsScans_levall)/nscans,total(rmsScans_unlev)/nscans],[result]]
;    self->setproperty,plane=p0
;    singleScanRms=[[rmsScans_unlev],[rmsScans_levall]]
;    
;    obj_destroy,tmp
;    if n_elements(outfile) ne 0 then $
;      write_datamatrix,outfile,result,$
;      ;writecol,outfile,transpose(rmsTrend[0,*]),transpose(rmsTrend[1,*]),rmsScans_unlev,rmsScans_levall,$
;      header='nr_of_scans Leveled_cumulative_rms Unleveled_cumulative_rms Leveled_rms Unleveled_rms  '
;    return,result
;  endif
;   
;;  if not keyword_Set(noplot) then begin
;;    nscans=self->getproperty(/nscans)
;;    multi_plot,transpose(result),back=cgcolor('white'),psym=[4,5],$
;;      legend=['leveled','unleveled'],yrange=[0,1.2],xtitle='Number of scans'
;;    oplot,indgen(nscans)+1,rmsScans_unlev
;;    oplot,indgen(nscans)+1,rmsScans_levall,linestyle=2
;;  endif
;  
;  ind=(n_elements(index) eq 0)?indgen(self->getproperty(/nscans))+1:index
;  for i=1,n_elements(ind)-1 do begin
;    tmp=self->extract(ind[0:i])
;    if i eq 1 then tab=tmp->getstats(/error,/table,outvars=[0],_extra=extra,/noplot) $
;      else tab=tab->join(tmp->getstats(/error,/table,outvars=[0],_extra=extra,/noplot),/destroy,/horizontal)  
;    obj_destroy,tmp
;  endfor  
;  return,tab
;
;end

function CMMdatafile::rmsTrend,index,outfile=outfile,singleScanRms=singleScanRms,$
  _extra=extra,level=level,pointrms=pointrms
;return as a table the total rms as a function of included data sets.
;INDEX is the (sorted) array of indices of the scans to consider for
; the calculation.
;Return a vector of rms.
;If OUTFILE is indicated, write results on file. 
;point is the rms on the single point, theoretical expectation pointrms/sqrt(N) is plotted if passed

;TODO:
;eliminate the loop by using realtime formula runningRms
;migliorare le opzioni. Use current plane, use best fit plane, use list of planes passed.
  if keyword_set(level) ne 0 then begin
    ;if called with level keyword, calculate rmstrend for 
    ;unleveled and leveled data.
    p0=self->getproperty(/plane,/all)
    self->setproperty,plane=0
    nscans=self->getproperty(/nscans)
    rtm3=self->rmsTrend(colheader='unleveled',/noplot,singleScanRms=rmsScans_unlev)
    rtm3=rtm3->transpose(/destroy)
    ;outvars=4,/error,/all: 
    ; is the rms of the difference with the average value. 
    rmsScans_unlev=self->getstats(/error,/all,/noplot,outvar=[4])
    rmsScans_unlev=rmsScans_unlev[1:nscans]
    ;flatten 
    self->planefit,/all ;flatten subscan individually
    tmp=self->rmsTrend(colheader='leveled',/noplot,singleScanRms=rmsScans_levall)
    rmsScans_levall=self->getstats(/error,/all,/noplot,outvar=[4])
    rmsScans_levall=rmsScans_levall[1:nscans]
    tmp=tmp->transpose(/destroy)
    tmp=tmp->join(rtm3,/horizontal,/destroy)
    result=tmp->write()
    result=[[total(rmsScans_levall)/nscans,total(rmsScans_unlev)/nscans],[result]]
    self->setproperty,plane=p0
    singleScanRms=[[rmsScans_unlev],[rmsScans_levall]]
    
    obj_destroy,tmp
    if n_elements(outfile) ne 0 then $
      write_datamatrix,outfile,result,$
      ;writecol,outfile,transpose(rmsTrend[0,*]),transpose(rmsTrend[1,*]),rmsScans_unlev,rmsScans_levall,$
      header='nr_of_scans Leveled_cumulative_rms Unleveled_cumulative_rms Leveled_rms Unleveled_rms  '
      if not keyword_Set(noplot) then begin
        yrange=[0,max([max(result),max(rmsScans_unlev),max(rmsScans_levall)])]
        col=plotcolors(5)
        nscans=self->getproperty(/nscans)
        multi_plot,indgen(nscans)+1,transpose(result),back=cgcolor('white'),psym=[4,5],$
          xtitle='Number of scans',colors=col[0:1],yrange=yrange,/noleg,xrange=[0,nscans],$
          _extra=extra
        oplot,indgen(nscans)+1,rmsScans_unlev,color=col[2]
        oplot,indgen(nscans)+1,rmsScans_levall,linestyle=2,color=col[3]
        leg=['leveled','unleveled','single unleveled','single leveled']
        psym=[4,5,-0,-0]
        if n_elements(pointrms) ne 0 then begin
          oplot,indgen(nscans)+1,pointrms/sqrt((indgen(nscans)+1)),linestyle=3,color=col[4]
          leg=[leg,'Theoretical']
          psym=[psym,-0]
        endif
        legend,leg,color=col,linestyle=[1,1,0,2,3],psym=[4,5,-0,-0,-0],position=4,_extra=extra
      endif
    return,result
  endif
  
  
  ind=(n_elements(index) eq 0)?indgen(self->getproperty(/nscans))+1:index
  for i=1,n_elements(ind)-1 do begin
    tmp=self->extract(ind[0:i])
    if i eq 1 then tab=tmp->getstats(/error,/table,outvars=[0],_extra=extra,/noplot) $
      else tab=tab->join(tmp->getstats(/error,/table,outvars=[0],_extra=extra,/noplot),/destroy,/horizontal)  
    obj_destroy,tmp
  endfor  
  return,tab

end

pro CMMdatafile::rmstrend,_extra=extra
  a=self->rmstrend(_extra=extra)
  if n_elements(a) eq 1 then if obj_valid(a) then obj_destroy,a
end

function CMMdatafile::getStats,j,string=string,table=table,$
                resampling=resampling,surface=surface,plane=plane,error=error,$
                outvars=outvars,locations=locations,psfile=psfile,$
                hist=hist,all=all,noplot=noplot,_extra=extra,window=w,outfile=outfile

  if keyword_set(all) then index=indgen(self.nscans+1) else $
    if n_elements(j) ne 0 then index=j else index=0
  
;TODO add index, making it possible to retrieve the statistics for only one scan.
;index=0 means average (or rms), scans are numbered from 1 to self.nscans
;adapted:
;  surface
;  errors
;  plane
;  resampling

;FIXME st=g1->getstats(/surface,/all,/noplot,format='f23.8') do not return a result if /string or /table is not set
;FIXME format in string doesn't work print,g1->getstats(/surface,/all,/noplot,/string,format='f23.8')

  ;self->_update 
    if n_elements(outvars) eq 0 then outvars=[10,0,1,2,3,4]
    if keyword_set(resampling)+keyword_set(surface)+keyword_set(error)+keyword_set(plane) gt 1 then $
      message,'Only one keyword among /RESAMPLING, /SURFACE, /ERROR and /PLANE can be set.'
    if (keyword_set(resampling)+keyword_set(surface)+keyword_set(plane)+$
       keyword_set(error)) eq 0 then begin
      ;called without keywords return the surface and plane statistics (e.g. it is 
      ;used for the plot)
      statssurface=self->getstats(index,/table,$
                  outvars=outvars,/surface,noplot=noplot,_extra=extra,psfile=psfile)
      statsplane=self->getstats(index=index,/table,$
                  outvars=outvars,/plane,/noplot,all=all)       
      stats=statssurface->join(statsplane->transpose(),/destroy)
    endif  
  
  if keyword_set(surface) or keyword_set(error) then begin
      i=0
      tmp=self-> getscan(index[i],error=error)
      if  n_elements(psfile) ne 0  then $
        psf=psfile
      stats=tmp->getStats(/table,noplot=noplot,$
            outvars=outvars,locations=locations,hist=hist,resampling=resampling,$
            /surface,psfile=psf,_extra=extra)
      obj_destroy,tmp
      for i =1,n_elements(index)-1 do begin
          tmp=self-> getscan(index[i],error=error)
          if  n_elements(psfile) ne 0 then $
                psf=fnaddsubfix(psfile,'_'+string(index[i],format='(i3.3)'))
          stats=stats->join(tmp->getStats(/table,noplot=noplot,$
              outvars=outvars,locations=locations,hist=hist,resampling=resampling,$
              /surface,psfile=psf,_extra=extra),$
              /destroy,/horizontal)
          obj_destroy,tmp
      endfor
  endif

  if keyword_set(plane) then begin
      plane=self->getproperty(/plane,/all)
      i=0
      tmp=self-> getscan(index[i])
      rh=tmp->getproperty(/idstring)
      obj_destroy,tmp
      for i =1,n_elements(index)-1 do begin
          tmp=self-> getscan(index[i])
          rh=[rh,tmp->getproperty(/idstring)]
          obj_destroy,tmp
      endfor
      stats=obj_new('table',caption='Plane for '+self.idstring+', z=Ax+By+C',data=plane[*,index],$
                      rowheader=rh,colheader=['A','B','C'])
  endif
  
  if keyword_set(resampling) then begin
    i=0
    tmp=self-> getscan(index[i])
    if  n_elements(psfile) ne 0 then $
        psf=fnaddsubfix(psfile,'_'+string(index[i],format='(i3.3)'))
    stats=tmp->getstats(/resampling,/table,noplot=noplot,$
            window=n_elements(w) eq 0?w:w+i,_extra=extra,psfile=psf)
    obj_destroy,tmp        
    for i =1,n_elements(index)-1 do begin
      tmp=self-> getscan(index[i])
      if n_elements(psfile) ne 0 then $
        psf=fnaddsubfix(psfile,'_'+string(index[i],format='(i3.3)'))
      stats=stats->join(tmp->getstats(/resampling,/table,$
          noplot=noplot,window=n_elements(w) eq 0?w:w+i,_extra=extra,$
          psfile=psf),/destroy,/horizontal)
      obj_destroy,tmp 
    endfor
  endif
  
  if n_elements(outfile) ne 0 then stats->write,imgdir+path_sep()+'testtrable.txt'
  result=stats->write(string=string,table=table,_extra=extra)
  return,result
  
end

pro CMMdatafile::__plotRms,zrange=zrange,_ref_extra=extra
    
    stats=(*self.errormap)->getstats(/string,/noplot)
    plane=self->getProperty(/plane,/all)
    ndimst=string(n_elements(plane[*,0]),format='(i1)')
    leg=[stats,'','Planes removed:','  A    B    C',string(plane,format='('+ndimst+'e0.2E1)'),'z=Ax+By+C'] 
    (*self.errormap)->draw,zrange=zrange,_extra=extra,legend=leg
end

;pro CMMdatafile:: plotError,index,_extra=extra
;    
;    self->draw,index,/error,_extra=extra
;
;end

;pro CMMdatafile:: plotError,index,all=all,commonbar=commonbar,zrange=zrange,$
;    nodefault=nodefault,psfile=psfile,_extra=extra,window=w
;    
;;TODO unire ploterror and draw (call draw with flag /error)
;  self->_update
;  if n_elements(self->getproperty(/xgrid)) eq 0 or n_elements(self->getproperty(/ygrid)) eq 0 then begin
;      if n_elements(self->getproperty(/xgrid)) eq 0 then message, 'Xgrid is not defined',/informational
;      if n_elements(self->getproperty(/xgrid)) eq 0 then message, 'Ygrid is not defined',/informational
;      message, 'cannot draw!',/informational
;      return
;  endif
;   
;  if self.nscans eq 1 then message,'Cannot plot error maps with only one file!',/informational
;    
; if keyword_set(nodefault) eq 0 then setstandarddisplay,/notek
;  
;  ;load data if needed
;  if keyword_set(all) then begin
;    data=(*self.errormap)->getproperty(/data)
;    for i=0,self.nscans-1 do begin
;      data=[[[data]],[[(*self.scanlist)[i]->getProperty(/data)-self->getProperty(/data)]]]
;    endfor
;    
;    ;;draw all images
;    ;set zrange
;    if n_elements(zrange) ne 0 then begin
;      if keyword_set(commonbar) ne 0 then message,'zrange is set, commonbar will be ignored (but images are plotted on the common zrange'
;    endif else if keyword_set(commonbar) ne 0 then begin
;      zrange=range(data[*,2]*self->getproperty(/zfactor))
;    endif
;    ;plot single images
;    plane=self->getstats(/plane,/string,/all)
;    for i=0,self.nscans-1 do begin
;;       tmp=obj_new('griddata',data[*,*,i],self.idstring+' #'+string(i,format='(i2.2)')+' - error',$
;;                   resolution=self->getproperty(/resolution),zfactor=self->getproperty(/zfactor),$ ;machine resolution in um, used for statistics computation
;;                   xgrid=self->getproperty(/xgrid),ygrid=self->getproperty(/ygrid))
;       tmp=self->getscan(i,/error)
;       if keyword_set(nodefault) eq 0 then setstandarddisplay,/notek
;       if n_elements(title) eq 0 then tit=self.idstring else tit=title
;       tmp->draw,zrange=zrange,nodefault=nodefault,title=title,window=n_Elements(w) eq 0?i:(w+i),$
;            charsize=charsize,_extra=extra,psfile=fnaddsubfix(psfile,((i eq 0)?'':'_'+string(i,format='(i3.3)')),/silent)       
;       obj_destroy,tmp
;    endfor
;  endif 
;  
;  if n_elements(index) ne 0 and keyword_set(all) eq 0 then begin 
;     tmp=self->getscan(index,/error)
;  endif else self->__plotRms,zrange=zrange,_extra=extra,psfile=psfile,window=self.nscans+1 
;  
;end

pro CMMdatafile::crop,x,y
  xgrid=(self->getproperty(/xgrid))
  ygrid=(self->getproperty(/ygrid))
  if n_elements(x) eq 1 then begin
    if x ne 0 then message,'scalar value not recognized for x'
    x=range(xgrid)
  endif else if n_elements(x) ne 2 then message,'wrong number of elements for x'
  if n_elements(y) eq 1 then begin
    if y ne 0 then message,'scalar value not recognized for x'
    y=range(ygrid)
  endif else if n_elements(y) ne 2 then message,'wrong number of elements for x'
  
  xsel=where(xgrid le x[1] and xgrid ge x[0],c)
  if c ne 0 then xgrid=xgrid[xsel]
  ysel=where(ygrid le y[1] and xgrid ge y[0],c)
  if c ne 0 then ygrid=ygrid[ysel]
  self->setproperty,xgrid=xgrid,ygrid=ygrid

end

function __errorlegend,errormap
;errormap is a griddata type. Return a legend with suitable statistics
;for the case of standard deviation of the mean case.
data=errormap->getproperty(/data)*errormap->getproperty(/zfactor)
result=moment(data,nan=nan)
npoints=n_elements(data)
       
statsval=[result[0],$                ;0:avg
          sqrt(total(data^2)/(npoints-1)),$ ;6:standard deviation of the mean 
       max(data)-min(data),$      ;1:PV
       min(data),$                ;2:min
       max(data),$                ;3:max
       npoints]                   ;10:npoints

legend=["avg. pixel rms","rms of error","PV","min","max","Npoints"]+":"+string(statsval)
return,legend


end

pro CMMdatafile::draw,index,all=all,commonbar=commonbar,window=w,destroy=destroy,tif=tif,$
        zrange=zrange,nodefault=nodefault,_ref_extra=extra,psfile=psfile,error=error,idstring=idstring
  ;nodefault prevent from setting the standard palette and graphics mode
  ;if commonbar is set the same zrange is used for all images and the range is returned in zrange.
  ;if zrange is set, that range is used and commonbar is ignored.
  ;otherwise the colorbar range is set to fit each image independently (zrange remain unset).
  ;if all is set all images are plotted, otherwise only average is plotted
  
  if n_elements(self->getproperty(/xgrid)) eq 0 or n_elements(self->getproperty(/ygrid)) eq 0 then begin
      if n_elements(self->getproperty(/xgrid)) eq 0 then message, 'Xgrid is not defined',/informational
      if n_elements(self->getproperty(/ygrid)) eq 0 then message, 'Ygrid is not defined',/informational
      beep
      message, 'cannot draw!',/informational
      return
  endif
  self->_update
  
  if keyword_set(nodefault) eq 0 then setstandarddisplay,/notek,_extra=extra
  if keyword_set(all) then index=indgen(self.nscans+1) else if n_elements(index) eq 0 then index=0
  if n_elements(idstring) ne 0 then self->setproperty,idstring=idstring
  
  ;set zrange
  if n_elements(zrange) ne 0 then begin
    if keyword_set(commonbar) ne 0 then message,'zrange is set, commonbar will be ignored (but images are plotted on the common zrange).'
  endif else if keyword_set(commonbar) ne 0 then begin
    zrange=range(self->getstats(index,/noplot,outvars=[2,3],error=error,/surface))
  endif
  
  ;draw all images
  for i=0,n_elements(index)-1 do begin
    tmp=self->getscan(index[i],error=error)
    ;set legend and plot 
    if index[i] eq 0 and keyword_set(error) ne 0 then begin ;average
      leg=__errorlegend(tmp)
      plotTitle=(self->getproperty(/filename))+"Avg of"+string(self.nscans,format='(i3)')+" files"
    endif else begin
      undefine,leg
      plotTitle=(self->getproperty(/filename))+"scan #"+string(index[i],format='(i3)')
    endelse
    
    if keyword_set(error) then begin
       if index[i] eq 0 then label=greek('sigma') $  ;,ps=(keyword_set(psfile) or keyword_set(tif))
           else label=greek('delta',ps=(keyword_set(psfile) or keyword_set(tif)))+'z'
       bartitle=label+' ('+greek('mu')+'m)' ;,ps=(keyword_set(psfile) or keyword_set(tif))
    endif else undefine, bartitle ;use default
    tmp->draw,zrange=zrange,bartitle=bartitle,window=n_elements(w) eq 0?i:w+i,nodefault=nodefault,$
        psfile=fnaddsubfix(psfile,((index[i] eq 0)?'':'_'+string(i,format='(i3.3)')),/silent),$
        /destroy,_extra=extra,leg=leg,tif=tif
  endfor
end


pro CMMdatafile::plotResampling,all=all,stats=stats,psfile=psfile,window=w,_extra=extra
    
    nscans=self->getproperty(/nscans)
    symbols=[3,4,replicate_vector([1,4,5,6,7,2],nscans+1)]
    colors=plotcolors(nscans+1)
    
    ;self->_update
    stats=self->getstats(/resampling,/table,/noplot,$
                          outvars=outvars,all=all,_extra=extra)
   
    xr=range([(self->getproperty(/points,/all))[*,0],self->getproperty(/xgrid)])
    yr=range([(self->getproperty(/points,/all))[*,1],self->getproperty(/ygrid)])
    rr=squarerange(xr,yr,expansion=1.05)         

    if keyword_set(all) then begin
        if n_elements(psfile) ne 0 then PS_Start, filename=psfile+'.eps',/nomatch $
           else if keyword_set (noplot) eq 0 then begin   
              if n_elements(w) eq 0 then window,/free else window,w
        endif     
          plot,[0],[0],/nodata,xrange=rr[0:1],yrange=rr[2:3],/isotropic,title=self.idstring,$
              background=cgcolor('white'),color=cgcolor('black'),_extra=extra
          (*self.scanlist)[0]->plotGrid,window=w,psfile=psfile,/oplot,$
                color=colors[0],psym=symbols[0],_extra=extra
          for i=0,nscans-1 do (*self.scanlist)[i]->plotpoints,$
            psfile=psfile,/oplot,_extra=extra,psym=symbols[i+1],color=colors[i+1] 
          legstr=['resampled',(replicate('raw data #',nscans))+string(indgen(nscans),format='(i3)')]
          legend,legstr,position=13,color=colors,/sym_only,_extra=extra,psym=symbols
          diststats=self->getstats(/resampling,/string,/noplot)
          legend,diststats,position=14,/nolines,color=cgcolor('black'),_extra=extra         
        if n_elements(psfile) ne 0 then ps_end 
    endif else begin
        for i=0,nscans-1 do (*self.scanlist)[i]->plotResampling,window=n_elements(w) eq 0?i:w+i,$
          xrange=rr[0:1],yrange=rr[2:3],psfile=psfile,noplot=noplot,_extra=extra,$
          color=colors[0:1],psym=symbols[0:1]
    endelse
end

function CMMdatafile::_datatype
  if n_elements(self.type) eq 0 then message, 'self.type not defined, cannot determine the type of data'
  
  if self.type eq 'Surf' then return,'CMMsurface'
  
  message, 'type of datafile not recognized:'+self.type

end

pro CMMdatafile::report,document,resultsfolder=resultsfolder,destroy=destroy
  ;obsolete
  outname=cgRootname(self.filename,directory=datafolder,extension=ext)
  ;datafolder=file_dirname(self.filename)
  outfolder=fn(datafolder)+path_sep()+(n_elements(resultsfolder)eq 0?(outname+'_results'):resultsfolder)
  img_dir=fn('img')
  file_mkdir,outfolder+path_sep()+img_dir
  set_plot_default

  title='Analysis of datafile '+fn(self.filename,/u)
  if n_elements(report) eq 0 then begin
    toc=0
    report=obj_new('lr',outfolder+path_sep()+'report.tex',title=title,$
                  author=author,level=sectionlevel,toc=toc)
  endif
  
  res=self->getproperty(/resolution)*20
  report->section,0,title
  report->append,'Results folder: \emph{'+fn(outfolder,/u)+'}',/nl
  report->append,'Data file: \emph{'+fn(self.filename,/u)+'}',/nl
  report->append,'Number of scan: '+string(self.nscans)+'',/nl
  report->section,1,'Resampling'
  !P.charsize=1.0
  self->plotResampling,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'resampling',/all
  report->figure,img_dir+path_sep()+outname+'resampling',parameters='width=0.75\textwidth',$
          caption='Raw and resampled points.'  
  resstats=self->getstats(1,/resampling,binsize=res,/table,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'resStats')
  ;TODO aggiungere all e prendere solo statistica complessiva
  report->figure,img_dir+path_sep()+outname+'resStats_001',parameters='width=0.75\textwidth',$
          caption='Distributions of points coordinate variations in resampling (first scan).'  
  report->table,resstats,parameters='width=0.75\textwidth',$
          caption='Statistics about points coordinate variations in resampling.',resize=0.9
  obj_destroy,resstats
  
report->section,1,'Measured surface'  
  self->draw,/all,charsize=1.0,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'_scan_avg'
  report->figure,img_dir+path_sep()+outname+'_scan_avg',parameters='width=0.75\textwidth',$
          caption='Measured surface (raw data).' 
  surfstats=self->getstats(/table,/all,binsize=res,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'scanStats')
  report->figure,img_dir+path_sep()+outname+'scanStats',parameters='width=0.75\textwidth',$
          caption='Measured surface distribution (raw data).' 
  report->table,surfstats,resize=0.8,caption='Statistics for raw surface data'
  obj_destroy,surfstats

  report->section,1,'Errors (unflattened)'
  self->plotError,/all,charsize=1.0,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'_err'
  report->figure,img_dir+path_sep()+outname+'_err',parameters='width=0.75\textwidth',$
            caption='Rms error for surface (raw data).'
  for i=1,self->getproperty(/nscans)-1 do begin
    report->figure,img_dir+path_sep()+outname+'_err_'+string(i,format='(i3.3)'),parameters='width=0.75\textwidth',$
            caption='Error for surface (raw data), for scan #'+string(i,format='(i3.3)')+'.'
  endfor
  errstats=self->getstats(/table,/all,/error,binsize=res,psfile=outfolder+path_sep()+$
              img_dir+path_sep()+outname+'errStats')
  report->figure,img_dir+path_sep()+outname+'errStats',parameters='width=0.75\textwidth',$
          caption='Distribution of deviations from average (raw data).' 
  report->table,errstats,resize=0.8,caption='Deviation from average for raw surface data'
  obj_destroy,surfstats
  
  self->planefit
  self->draw,charsize=1.0,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'_scan_flatavg'
  report->figure,img_dir+path_sep()+outname+'_scan_flatavg',parameters='width=0.75\textwidth',$
          caption='Measured surface (flattened on average plane).' 
  surfstats=self->getstats(/table,binsize=res,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'_scanStats_flatavg')
  report->figure,img_dir+path_sep()+outname+'_scanStats_flatavg',parameters='width=0.75\textwidth',$
          caption='Measured surface distribution (flattened on average plane).' 
  report->table,surfstats,resize=0.8,caption='Statistics for flattened surface data on average'
  obj_destroy,surfstats        

  self->planefit,/all
  surfstats=self->getstats(/table,binsize=res,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'_Stats_fltall')
  report->figure,img_dir+path_sep()+outname+'_Stats_fltall',parameters='width=0.75\textwidth',$
          caption='Measured surface distribution (individually flattened).' 
  report->table,surfstats,resize=0.8,caption='Statistics for individually flattened surface'
  obj_destroy,surfstats              
  
  report->section,1,'Errors (after individual flattening)'
  self->plotError,/all,charsize=1.0,psfile=outfolder+path_sep()+img_dir+path_sep()+outname+'_f_err'
  report->figure,img_dir+path_sep()+outname+'_f_err',parameters='width=0.75\textwidth',$
            caption='Rms error for surface (leveled data).'
  for i=1,self->getproperty(/nscans)-1 do begin
    report->figure,img_dir+path_sep()+outname+'_f_err_'+string(i,format='(i3.3)'),parameters='width=0.75\textwidth',$
            caption='Error for surface (leveled data), for scan #'+string(i,format='(i2.2)')+'.'
    errstats=self->getstats(/table,/error,binsize=res,psfile=outfolder+path_sep()+$
              img_dir+path_sep()+outname+'errStats_f')
  endfor
  report->figure,img_dir+path_sep()+outname+'errStats_f',parameters='width=0.75\textwidth',$
          caption='Distribution of deviations from average after removal of best fit plane for each single image.' 
  report->table,errstats,resize=0.8,caption='Statistics for deviation from average for independently flattened scans'
  obj_destroy,surfstats
  
  report->Compile,3,/pdf,/clean
  obj_destroy,report

if keyword_set (destroy) then obj_destroy,self

end

function CMMdatafile::subtract,scan2,destroy=destroy,idstring=idstring
;TODO replace with a function that returns a CMMdatafile object,
; containing the difference between each scan and scan2 average
; (or if scan2 is a CMMsurface).
;TODO: Put a flag for scan-by-scan difference, but I don't see
; a reason for wanting to do that. 

  tmp=self->getscan(/average)
  diff=tmp->subtract(Scan2->getscan(/average),idstring=idstring)
  obj_destroy,tmp
  if keyword_set(destroy) then begin
    obj_destroy,scan2
    obj_destroy,self
  endif
  return,diff
end

function CMMdatafile::extract,index,destroy=destroy,idstring=idstring
  ;it works like GETSCAN, but returns a CMMdatafile object instead than CMMsurface,
  ; so it can contain more than one scans.
  ;It uses GETSCAN.
  
  nscans=n_elements(index)
  a=where((index lt 1) or (index gt self->getproperty(/nscans)),c)
  if c ne 0 then message,'Invalid value for index in EXTRACT'
  if n_elements(idstring) eq 0 then $
    idstring=self->getproperty(/idstring)+' ('+strjoin(string(index,format='(i2.2)'),',')+')'
  resolution=self->getproperty(/resolution) 
  zfactor=self->getproperty(/zfactor)
  plane=(self->getproperty(/plane,/all))[*,index]
  
  xg1=self->getproperty(/xgrid)
  yg1=self->getproperty(/ygrid)
  
  result=obj_new('CMMdatafile',type='Surf',nscans=nscans,$
                 idstring=idstring, zfactor=zfactor)
  result->setproperty,plane=plane
  i=0
  tmp=self->getscan(index[i])
  points=tmp->getproperty(/points)
  obj_destroy,tmp
  if nscans gt 1 then begin
    for i =1,n_elements(index)-1 do begin
      tmp=self->getscan(index[i])
      points=[points,tmp->getproperty(/points)]
      obj_destroy,tmp
    endfor
  endif
  result->setproperty,xgrid=xg1,ygrid=yg1,points=points
  
  if keyword_set(destroy) then obj_destroy,self
  
  return,result
end

;function CMMdatafile::subtract,data2,average=average
;  scan1=self->getscan(/average)
;  scan2=data2->getscan(/average)
;  return,scan1->subtract(scan2,/destroy)
;end

function CMMdatafile::merge,scan2,destroy=destroy,idstring=idstring
  nscans=self->getproperty(/nscans)+scan2->getproperty(/nscans)
  if n_elements(idstring) eq 0 then begin
    idstring='['+self->getproperty(/idstring)+','+scan2->getproperty(/idstring)+']'
  endif
  
  if (self->getproperty(/resolution) ne scan2->getproperty(/resolution)) then begin
      beep
      message,'You are trying to merge 2 scans with different resolution'+$
          'the worse one will be kept:',/informational
  endif
  resolution=self->getproperty(/resolution) > scan2->getproperty(/resolution)
  if (self->getproperty(/zfactor) ne scan2->getproperty(/zfactor)) then begin
      beep
      message,'Different ZFACTOR in merging, not implemented yet'
  endif
  zfactor=self->getproperty(/zfactor)
  
  plane=[[self->getproperty(/plane,/all)],[scan2->getproperty(/plane,/all)]]
  
  xg1=self->getproperty(/xgrid)
  xg2=scan2->getproperty(/xgrid)
  npx=n_elements(xg1)
  if  npx ne n_elements(xg2) then begin 
      message,'different xgrid in merging scans'+$
      newline()+self.idstring+' and '+scan2.idstring+'.'+newline()+$
      'Resampling on grid 1.',/informational 
      beep
  endif
  
  yg1=self->getproperty(/ygrid)
  yg2=scan2->getproperty(/ygrid)
  npy=n_elements(yg1)
  if  n_elements(yg2) ne npy then begin
      message,'different ygrid in merging scans'+$
      newline()+self.idstring+' and '+scan2.idstring+'.'+newline()+$
      'Resampling on grid 1.',/informational
      beep 
  endif
  
  merged=obj_new('CMMdatafile',type='Surf',nscans=nscans,$
                 idstring=idstring, zfactor=zfactor,$
                 plane=plane)
  merged->setproperty,points=[self->getproperty(/points,/all),scan2->getproperty(/points,/all)]
  merged->setproperty,npx=npx,npy=npy
  
  if keyword_set(destroy) then begin
    obj_destroy,scan2
    obj_destroy,self
  endif
  return,merged
end

function CMMdatafile::duplicate
  result=obj_new('CMMdatafile',self->getproperty(/file),$
                  nscans=self->getproperty(/nscans),$
                  colorder=self->getproperty(/colorder),type='Surf')
  result->setproperty,idstring=self->getproperty(/idstring),$
                      points=self->getproperty(/points,/all),$
                      xgrid=self->getproperty(/xgrid),$
                      ygrid=self->getproperty(/ygrid),$
                      plane=self->getproperty(/plane,/all),$
                      resolution=self->getproperty(/resolution),$
                      zfactor=self->getproperty(/zfactor)
  return,result
end

function CMMdatafile::Init,filename,idstring=idstring,xgrid=xgrid,ygrid=ygrid,$
         colorder=colorder,nscans=nscans,npx=npx,npy=npy,type=type,plane=plane,$
         zfactor=zfactor,resolution=resolution,_extra=extra,reader=reader
    
    ;COLORDER is a vector of column positions (base-1) to be assigned to
    ; data columns. e.g. [3,1,2] read a file as z,x,y. The default is [1,2,3]
    ; (read as X, Y, Z). 
    
    if n_elements(nscans) ne 0 then self.nscans=nscans else begin
      self.nscans=1 
      beep
      filemsg=(n_elements(filename) ne 0)? filename:'<No File>'
      message,'nscans not provided at initialization, 1 scan assumed in file '+filemsg,/info
    endelse 
    if n_elements(reader) eq 0 then self.reader=self.defaultReader()
    self.colorder=ptr_new(/allocate_heap)
    if n_elements(colorder) eq 0 then *self.colorder=[1,2,3] else *self.colorder=colorder
    ;self.type=type
    scanlist=objarr(self.nscans)
    self.scanlist=ptr_new(scanlist)
    self.average=ptr_new(/allocate_heap)
    self.errormap=ptr_new(/allocate_heap)
    *self.average=obj_new('CMMsurface')
    *self.errormap=obj_new('griddata')
    for i=0,self.nscans-1 do begin
      (*self.scanlist)[i]=obj_new('CMMsurface')
    endfor
    if n_elements(resolution) eq 0 then resolution=0.1d 
    if n_elements(zfactor) eq 0 then zfactor=1000.d 
    if n_elements(filename) ne 0 then begin 
      if not (filename eq "") then begin
            if file_test(filename,/read) then begin
              self.filename=filename
              self->read_data,checkLabel=checkLabel,_extra=extra
            endif else begin
              message,'FILE: '+filename,/info
              message,"not found, create an empty CMMdatafile object!",/info
              self.filename=""
              beep
            endelse
      endif
    endif
    self->setproperty,xgrid=xgrid,ygrid=ygrid,npx=npx,npy=npy,resolution=resolution,zfactor=zfactor,$
      idstring=n_elements(idstring) eq 0? (n_elements(filename) eq 0 ?'CMMdatafile':file_basename(filename)):idstring
    return,1
end

pro CMMdatafile::Cleanup
  for i=0,self.nscans-1 do begin
    obj_destroy,(*self.scanlist)[i]
  endfor
  obj_destroy,*self.scanlist
  ptr_free,self.scanlist
  obj_destroy,*self.average
  ptr_free,self.average
  obj_destroy,*self.errormap
  ptr_free,self.errormap
  ptr_free,self.colorder
end


pro CMMdatafile__define
struct={CMMdatafile,$
        filename:"",$
        idstring:'',$
        nscans:0l,$
        colorder:ptr_new(),$
        type:"",$
        scanlist:ptr_new(),$
        average:ptr_new(),$
        errormap:ptr_new(),$
        _changed:0, $
        reader:ptr_new(),$
        inherits IDLobject $
        }
end

pro test_duplicate, a
    a->planefit,/all
    help,a
    b=a->duplicate()
    print,"plane"
    print,a->getproperty(/plane)
   ;0.00099569374    -0.015016124      0.19320532
    print,b->getproperty(/plane)
   ;0.00099569374    -0.015016124      0.19320532
end    
    
pro test_planefit,a    
    ;shows properties of the best fit planes.
    ;the average plane is the same for individual (/ALL) or 
    ; collective planefit. The avg plane is obtained from the
    ; average of the planes of each scan. 
    ;If the single scan planes are set by individual or collective bestfit, 
    ; the avg plane is also the bestfit plane for the average. 
       
    a->setproperty,plane=0
    a->draw,2,/err
    a->planefit
    a->draw,2,/err
    a->setproperty,plane=0
    a->draw,2,/err
    a->planefit
    a->draw,2,/err,w=1
    a->planefit,/all
    a->draw,2,/err,w=2
    print,a->getproperty(/plane)
   ;0.00099569374    -0.015016124      0.19320532
    a->planefit
    print,a->getproperty(/plane)
   ;0.00099569374    -0.015016124      0.19320532
    avg=a->getscan(0)
    avg->draw
    print,avg->getproperty(/plane)
   ;0.00099569374    -0.015016124      0.19320532
    print,avg->planefit()
   ;0.00099569374    -0.015016124      0.19320532
end

pro test_getscan,a
  ;;test getscan
    k=a->getscan(/average)
    k->draw,/destroy
    help,k ;object was destroyed, but it still appear in the heap
    k=a->getscan(2)
    k->draw,/destroy
    k=a->getscan(0)
    k->draw,/destroy
    k=a->getscan(0,/error)
    k->draw,/destroy
    k=a->getscan(/error)
    k->draw,/destroy
    k=a->getscan(3,/error)
    k->draw,/destroy
end

pro test_error,a
  a->setproperty,plane=0
  a->draw,title='surface unleveled',w=1
  a->draw,/error,title='error unleveled',w=4
  a->planefit
  a->draw,title='surface leveled',w=2
  a->draw,/error,title='error leveled',w=5
  a->planefit,/all
  a->draw,title='surface individually leveled',w=3
  a->draw,/error,title='error individually leveled',w=6
end 

pro test1,a 
  a->planefit
  a->draw,/all,/noint
  a->plotResampling
  ;obj_destroy,a
  help,/heap
end

pro test_plane,a

    print,'Is grid set?'
    help,a->getproperty(/xgrid),a->getproperty(/ygrid)
    
    print,'Are points set?'
    help,a->getproperty(/points)
    print,'Are data set?'
    help,a->getproperty(/data)
    
    print,'plane is:'
    print,a->getproperty(/plane)
    print,'/ALL'
    print,a->getproperty(/plane,/ALL)
    ;--
    p0=[1,2,3]
    print,'set plane to ',p0
    a->setproperty,plane=p0
    ;---
    print,'plane is:'
    print,a->getproperty(/plane,/ALL)
    ;--
    p0=0
    print,'set plane to ',p0
    a->setproperty,plane=p0
    ;---
    print,'plane is:'
    print,a->getproperty(/plane,/ALL)
    ;--  
    print,'planefit,/ALL'
    a->planefit,/ALL
    ;---
    print,'plane is:'
    print,a->getproperty(/plane,/ALL)
    ;-- 
  
end

pro test_error_plane,a
  a->setproperty,plane=0
  b=a->getscan(2,/error)
  help,b
  b->draw,title='Error for unleveled scan 3'
  b->planefit
  b->draw,title='Leveled error from Scan 3'
  a->planefit
  obj_destroy,b
  b=a->getscan(2,/error)
  b->draw,title='Error from leveled Scan 3'
  a->planefit,/all
  obj_destroy,b
  b=a->getscan(2,/error)
  b->draw,title='Error from individually leveled Scan 3'
end

pro test_extraction,a
  print,"plane for test object A:"
  print,a->getproperty(/plane,/all)
  b=a->extract([1,2])
  b->draw,/all,/error
  print,"plane for A->extract([1,2])"
  print,b->getproperty(/plane,/all)
  b=a->getScan(2)
  print,"plane for A->getscan(2)"
  print,b->getproperty(/plane)
  b=a->duplicate()
  print,"plane for a->duplicate:"
  print,b->getproperty(/plane,/all)
  
end

pro CMMdatafile::test,test1=test1,getscan=getscan,error=error,plane=plane
  ;TODO: if 0 arguments print possible options
  
  print,'-----------'
  print,'Start Tests'
  a=self->duplicate()
  print, 'OBJECT created'
  help,a
  print
  if keyword_set(test1) then begin
    ;res=dialog_message("Start test1.",/info)
    test1,self
  endif
  
  ;res=dialog_message("Start test_getscan.",/info)
  if keyword_Set(getscan) then test_getscan,self

  ;res=dialog_message("Start test_error.",/info)
  if keyword_Set(error) then test_error,self
  
  if keyword_Set(plane) then test_plane,self
  obj_destroy,a
end

file='/home/cotroneo/Desktop/work_ratf/run2b/2011_03_04/Moore-Scan-Vert-surface-0V.dat'
;file=fn('E:/work/work_ratf/run2b/2011_03_04/Moore-Scan-Vert-surface-0V.dat')

file='/home/cotroneo/Desktop/work_PZT/Circular Optic/2011_03_31/RHW124_surf_taped_01.dat'
file='/export/cotroneo/work/work_PZT/measure_data/03_RHW124_shape/2011_03_31/RHW124_surf_taped90_01.dat'
file='E:\work\work_pzt\Circular Optic\2011_03_31\RHW124_surf_taped90_01.dat'
file='E:\work\work_pzt\Circular Optic\2011_04_07\if\surface_4x_grounded_01.dat'
set_plot_default
a=obj_new('CMMdatafile',file,$
           nscans=4,colorder=[2,3,1],npx=19,npy=19,type='Surf')

;test_getscan,a
;test1,a
a->draw,/error

;a=obj_new('CMMdatafile')
;a->setproperty,filename=file,nscans=4,colorder=[3,1,2]
;a->read_data
;a->setproperty,npx=19,npy=19
;a->draw

end
