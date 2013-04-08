;+
;It is a table of data that with caption, headers and formatting options
;   can be printed on different output or extracted as /DATA. 
;The code needs some reorganization, it was born as a latex only
; object, it became a general table object but some behaviors are still
; centered on latex.
;-
;
;2011/3/29 modified nrows and ncols to keep into account only data
;return empty string for colheader or rowheader if they are not set

;the format of the table object is internally a matrix of fortran format strings.
; it is a pointer to deal with changes in number of rows and column.
;can be initialized with a single value or a 1-dim array

;ISSUE 2012/01/11:
;N.B.:
;IDL> help,s
;S               OBJREF    = <ObjHeapVar7611(CMMDATAFILE)>
;IDL> ss=s->rmstrend(/noplot)
;IDL> help,ss
;SS              OBJREF    = <ObjHeapVar12085(TABLE)>
;IDL> help, ss->write()
;<PtrHeapVar12086>
;                DOUBLE    = Array[3, 1]
;IDL> help, (s->rmstrend(/noplot))->write()
;<No name>       UNDEFINED = <Undefined>

function table::getproperty,data=data,caption=caption,$
        nrows=nrows,ncols=ncols,colheader=colheader,$
        rowheader=rowheader,format=format
        
        if keyword_set(data) ne 0 then return,*self.data
        if keyword_set(caption) ne 0 then return,self.caption
        if keyword_set(nrows) ne 0 then return,self.nrows
        if keyword_set(ncols) ne 0 then return,self.ncols
        if keyword_set(format) ne 0 then return,*self.format
        if keyword_set(colheader) ne 0 then return,n_elements(*self.colheader) ne 0?*self.colheader:replicate('',self.ncols+1)
        if keyword_set(rowheader) ne 0 then return,n_elements(*self.rowheader) ne 0?*self.rowheader:replicate('',self.nrows)
end

pro table::getproperty,data=data,caption=caption,$
        nrows=nrows,ncols=ncols,colheader=colheader,$
        rowheader=rowheader,format=format
        
        if arg_present(data) then data=*self->getproperty(/data)
        if arg_present(caption) then caption=self->getproperty(/caption)
        if arg_present(nrows) then nrows=self->getproperty(/nrows)
        if arg_present(ncols) then ncols=self->getproperty(/ncols)
        if arg_present(colheader) then colheader=self->getproperty(/colheader)
        if arg_present(rowheader) then rowheader=self->getproperty(/rowheader)
        if arg_present(format) then format=self->getproperty(/format)
end

pro table::__setformat,format,default=default
;internal routine called only by setproperty to set the print format for the output of single fields (number of digits, etc.). 

;create here a procedure that sets a matrix of format strings for the output of the table.
;for now, I set a single way with a unique format for all fields
if n_elements(format) eq 1 then begin
  if ptr_valid(self.format) then begin
    ptr_free,self.format
    ncols=self->getproperty(/ncols)
    nrows=self->getproperty(/nrows)
    self.format=ptr_new(strarr(ncols,nrows))
    *self.format=replicate(format,ncols,nrows)
  endif
endif

end

pro table::setproperty,data=d,caption=caption,$
        nrows=nrows,ncols=ncols,colheader=colheader,$
        rowheader=rowheader,format=format,_extra=extra
        
        if n_elements(colheader) ne 0 then *self.colheader=colheader
        if n_elements(rowheader) ne 0 then *self.rowheader=rowheader
        if n_elements(d) ne 0 then begin
          data=d
          rank=size(data,/n_dimensions)
          case rank of
            0: begin
                  self.ncols=1 ;+1
                  self.nrows=1; +1
               end
            1: begin
                 if n_elements(rowheader) ne 0 or n_elements(colheader) ne 0 then begin
                   if n_elements(rowheader) eq 1 or n_elements(rowheader) eq 0 then begin
                     ;matrix with 1 row 
                     if n_elements(colheader) ne 0 and n_elements(colheader) ne n_elements(data) then $
                       message,'wrong number of elements in table initialization'
                     self.ncols=n_elements(data) ;+1
                     self.nrows=1; +1
                     data=transpose(data)
                   endif else if n_elements(colheader) eq 1 or n_elements(colheader) eq 0 then begin
                     ;matrix with 1 col 
                      if n_elements(rowheader) ne 0 and n_elements(rowheader) ne n_elements(data) then $
                        message,'wrong number of elements in table initialization'
                      self.ncols=1 ;+1
                      self.nrows=n_elements(data); +1
                   endif else begin
                      message,'rank of data eq 1, but headers do not correspond'
                   endelse
                 endif else begin
                     ;if no headers are defined, assume 1 col
                     self.ncols=1 ;+1
                     self.nrows=n_elements(data); +1
                 endelse
              end
            2: begin
              s=size(data,/dim)
              self.ncols=s[0] ;+1
              self.nrows=s[1] ;+1
            end 
          else: message,'not recognized rank for matrix'
          endcase
          *self.data=reform(data,self.ncols,self.nrows)
        endif  
        if n_elements(caption) ne 0 then self.caption=caption

        if n_elements(format) ne 0 then self->__setformat,format,_extra=extra
end

function table::write,format=format,$ ;colwidth=colwidth,$
  string=string,latex=latex,info=info,table=table
  
  ;return the output related to the table.
  ;if string is set, return a printable string (why one should want to do that? e.g. for a legend or file output)
  ;TODO: 
  ;   set a nicer formatting (e.g. number of digits). 
  ;   Critical example: generate string for resampling stats:
  ;       s=a->getstats(/resampling,/all,/table)
  ;       print,s->write(/string)
  ;
  ;if LATEX is set return a string with latex code
  ;if TABLE is set, return the table object (self). This is 
  ;   done to make the option usable from
  ;   routines that can return the table e.g.:
  ;     result=valuetable->write(list of flags)
  ;otherwise return only the data
  ;
  ;COLWIDTH is a string defining the widths in latex format.
    
    self->setproperty,format=format
    
    ;CHECK NO MORE THAN ONE OUTPUT STYLE IS SELECTED
    dummy=where([keyword_Set(latex),keyword_set(string),keyword_set(info),keyword_set(table)] ne 0,c)
    if c gt 1 then message,'only one among /LATEX, /STRING, /INFO, /TABLE can be selected to determine the format of the output.' 
    
    
    if keyword_set(latex) then begin                          ;LATEX OUTPUT
      ;try to determine the better orientation (ncol<nrow)
      if self.ncols gt self.nrows then begin 
        table=self->transpose()
        string=table->write(format=format,/latex)
        obj_destroy,table
        return,string
      endif
      
      if n_elements(*self.colheader) ne 0 then begin
        if n_elements(*self.colheader) eq self.ncols then ch=latextableline(['',*self.colheader]) $
        else if n_elements(*self.colheader) eq self.ncols+1 then ch=latextableline(*self.colheader) else $
        message,'Non matching number of elements for colheader:'+newline()+$
          'N COLS:'+string(self.ncols)+newline()+$
          'COLHEADER:'+strjoin(*self.colheader,'|')+newline()
      endif
      string=makelatextable(*self.data,rowheader=*self.rowheader,colheader=ch)
      return,string
    endif else if keyword_set(string) then begin            ;STRING OUTPUT
      ;TODO better formatting
      result=strjoin(self->getproperty(/colheader),'    ')
      data=self->getproperty(/data)
      for i=0,self.nrows-1 do begin
        if n_elements(self->getproperty(/format)) ne 0 then formatstring='('+strjoin(((self->getproperty(/format))[*,i]),',')+')'
        result=[[result],(self->getproperty(/rowheader))[i]+'= '+string(strjoin(data[*,i],'   '),format=formatstring)]
      endfor
      if result[0] eq '' then result=result[1:n_elements(result)-1]
      return,result
    endif else if keyword_set(info) ne 0 then begin         ;INFO OUTPUT: Properties and latex parameters
      result='CAPTION:'+newline()+self.caption
      result=[result,'Nrows= '+string(self->getproperty(/nrows))+'Ncols= '+string(self->getproperty(/ncols))]
      result=[result,'HEADER: '+string(n_elements(*self.colheader) eq 0?'-NO HEADER-':strjoin(*self.colheader))]
      result=[result,'TABLE:'+self->write(/latex)]
      return,result
    endif else if keyword_set(table) ne 0 then return,self else return, *self.data  ;TABLE OUTPUT
    
end

pro table::write,document,format=format,colwidth=colwidth,_extra=extra
  
  ;This uses the write function. 
  ;Used mainly to print table information for debug (so it is slightly different
  ; from the function, because the default behavior is with /INFO in the function).
  ;I am not sure it can have other uses, but probably at the end it can be convenient to
  ;  append the table to a latex file with procedure, e.g. 
  ;     table->write,document=doc,/latex,colwidth='p{3cm}p{2cm}p{1.5cm}',
  ;For other outputs (e.g. report) it is still not defined when to use the method 
  ; in table__define or a method in lR__define (this can use autoresize options).
  
    
    if n_elements(document) eq 0 then begin
      message, 'Write method called without DOCUMENT argument, print table info.',/informational
      print,self->write(/info)
    endif else begin
      if obj_class(document) eq 'LR' then begin 
      ;TODO: replace default colwidth with the autoformatting commmands in lR, replicate if a single number is provided
      ;allow to pass width in cm (or other units) 
          if n_elements(colwidth) eq 0 then cw='p{3cm}'+strjoin(replicate('p{2cm}',self.ncols)) else cw=colwidth
          DOCUMENT->table,self->write(/latex),cw,caption=self.caption
      endif else begin 
        if size(document,/tname) eq 'STRING' then begin
          ;if it is a string use it as a filename for writing data
          openw,lun,document,/get_lun
          printf,lun,self->write(_extra=extra)
          free_lun,lun
        endif else message, 'Not recognized type of document for table writing.'
      endelse
    endelse
  
end
  
function table::transpose,destroy=destroy
  transposed=obj_new('table',data=transpose(*self.data),$
      caption=self.caption,colheader=*self.rowheader,$
        rowheader=*self.colheader) 
  if keyword_set(destroy) then obj_destroy,self
  return,transposed
end



function casedefined,arg1,arg2
  ;return a 2-bits value according to the arguments defined;
  ;value  arg1_defined arg2_defined
  ;0          NO          NO
  ;1          NO          YES
  ;2          YES         NO
  ;3          YES         YES
  
  result=0
  if n_elements(arg2) ne 0 then result=result+2
  if n_elements(arg1) ne 0 then result=result+1
  return, result
end

function table::join,table2,horizontal=horizontal,colheader=colheader,rowheader=rowheader,destroy=destroy
  
  if keyword_set(horizontal) then begin
    
    ;join horizontally
    data=[*self.data,*table2.data]
    if n_elements(colheader) ne 0 then colheader =colheader else begin
          if n_elements(*self.colheader) ne 0 and n_elements(*table2.colheader) ne 0 then colheader=[*self.colheader,*table2.colheader]
    endelse
    
    if n_elements(rowheader) ne 0 then rowheader=rowheader else begin
      case casedefined(*self.rowheader,*table2.rowheader) of
      0:begin
          message,'none of the row headers is defined in attempt to join tables, '+$
            newline()+'row header will be left undefined',/informational
        end
      1:begin
          message,'only second row header is defined in attempt to join tables '+$
                        newline()+'table2 header:'+*table2.rowheader+newline()+$
                        'will be used',/informational
          rowheader=*table2.rowheader 
        end
      2:begin
          message,'only first row header is defined in attempt to join tables '+$
          newline()+'table1 header:'+*self.rowheader+newline()+$
          'will be used',/informational
          rowheader=*self.rowheader
        end
      3: begin
         if not (array_equal(*self.rowheader,*table2.rowheader)) then begin
                  message,'different row headers in attempt to join tables '+$
                          newline()+'table1:'+*self.rowheader+$
                          newline()+'table2:'+*table2.rowheader,/informational
         endif
         rowheader=*self.rowheader
         end
      else: message,'non recognized condition for rowheaders'
      endcase
    endelse
  endif else begin
    ;join vertically
    ;;data
    data=[[*self.data],[*table2.data]]
    ;;rowheader  
    if n_elements(rowheader) ne 0 then rowheader =rowheader else begin
          if n_elements(*self.rowheader) ne 0 and n_elements(*table2.rowheader) ne 0 then rowheader=[*self.rowheader,*table2.rowheader]
    endelse      
    ;;colheader
    if n_elements(colheader) ne 0 then colheader=colheader else begin
      case casedefined(*self.colheader,*table2.colheader) of
      0:begin
          message,'none of the col headers is defined in attempt to join tables, '+$
            newline()+'col header will be left undefined',/informational
        end
      1:begin
          message,'only second col header is defined in attempt to join tables '+$
                        newline()+'table2 header:'+*table2.colheader+newline()+$
                        'will be used',/informational
          colheader=*table2.colheader 
        end
      2:begin
          message,'only first col header is defined in attempt to join tables '+$
          newline()+'table1 header:'+*self.colheader+newline()+$
          'will be used',/informational
          colheader=*self.colheader
        end
      3: begin
         if not (array_equal(*self.colheader,*table2.colheader)) then begin
                  message,'different col headers in attempt to join tables '+$
                          newline()+'table1:'+strjoin(*self.colheader,'|')+$
                          newline()+'table2:'+strjoin(*table2.colheader,'|'),/informational
         endif
         colheader=*self.colheader
         end
      else: message,'non recognized condition for colheaders'
      endcase

    endelse
  endelse

  joined=obj_new('table',data=data,caption=self.caption,colheader=colheader,rowheader=rowheader) 
  if keyword_set(destroy) then begin
    obj_destroy,self
    obj_destroy,table2
  endif
  
  return,joined
end


function table::Init,caption=caption,data=data,nrows=nrows,$
        ncols=ncols,colheader=colheader,rowheader=rowheader,format=format
        
    ;self.idstring=idstring
    self.data=ptr_new(/allocate_heap)  ;processed data (e.g. leveled) (2d matrix)
    self.colheader=ptr_new(/allocate_heap)
    self.rowheader=ptr_new(/allocate_heap)
    self.format=ptr_new(/allocate_heap)
    self->setproperty,caption=caption,data=data,nrows=nrows,$
        ncols=ncols,colheader=colheader,rowheader=rowheader,format=format
    return,1
end

pro table::Cleanup
  ptr_free,self.data
  ptr_free,self.colheader
  ptr_free,self.rowheader
  ptr_free,self.format
end

pro table__define
struct={table,$
        caption:"",$
        data:ptr_new(),$
        nrows:0l,$
        ncols:0l,$
        colheader:ptr_new(),$
        rowheader:ptr_new(), $
        format:ptr_new() $
        }
end


pro table__test

print,'this is a table with one row and one column'
data=3
a=obj_new('table',rowheader='three',colheader='number',data=data)
a->write,/latex
obj_destroy,a
print,'---------------------------'+newline()

print,'this is a table with a three elements data and no headers,'+$
 ' it is interpreted as a column'
data=findgen(3)
a=obj_new('table',data=data)
strres=a->write(/string)
print,strjoin(strres,newline())
obj_destroy,a
print,'---------------------------'

print,'this is a table with a three elements column header and no row header,'+$
 ' it is automatically interpreted as a row'
data=findgen(3)
a=obj_new('table',data=data,colheader=['one','two','three'])
strres=a->write(/string)
print,strjoin(strres,newline())
obj_destroy,a
print,'---------------------------'
end

table__test
end
