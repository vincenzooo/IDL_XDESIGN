;TODO: support for nested sections
;TODO: define custom type that can be set putting in xml file the index of info to plot (if there is not already an option for that).

function getText,oElement
    otext=oElement->getfirstChild()  
    return,oText->GetNodeValue()
end

function stringvector,string
;from a textual description of a vector of strings return a vector of strings
;e.g.:    'A01_00F_L'  'A01_00F_C'  'A01_00F_R'  ->['A01_00F_L','A01_00F_C','A01_00F_R']
  vec=strsplit(string,'''""',/extract)
  vec=vec[where(strtrim(vec,2) ne newline())]
  vec=vec[where(strtrim(vec,2) ne '')]
  return, vec
end

function sectionTypes,type
    ;0 general information
    ;1 raw data and scan settings
    ;2 leveling and stats
    ;3 psd average with fit
    ;4 differences between raw profiles and stats   
    ;5 differences between leveled profiles and stats
    ;6 psd analysis and fit  
    
s=size(type,/tname)
if s eq 'STRING' then begin
  case strlowcase(type) of
    'debug':includeSections=[-1]
    'profile':includeSections=[0,1,2]
    'differences':includeSections=[0,1,2,4,5,6]
    'psdaverage':includeSections=[0,1,3,6]
    'psdgroups':includeSections=[0,3]
    else: includeSections=fix(type)
  endcase
endif else includeSections=fix(type)

return,includeSections

end

pro processSection,oSection,lR,outfolder=outfolder,level=level
  tmp=oSection->getFirstChild()
  while(OBJ_valid(tmp)) do begin
    class=obj_class(tmp)
    if (class ne 'IDLFFXMLDOMTEXT') and (class ne 'IDLFFXMLDOMCOMMENT') then begin  ;skip white spaces
      name=strlowcase(tmp->getTagName())
      if name eq 'section' then processSection,tmp,lR,outfolder=outfolder,level=level+1 $
        ;the level settings are overriden in procedure by xml value if present.
        ;it makes mess, because the output is generated at the end.
        ;avoid to use nested sections for now!
      else begin
        if name eq 'text' then text=(n_elements(text)eq 0?'':text)+getText(tmp) $
        else if name eq 'filelist' then filelist= stringvector(getText(tmp)) $
          else if name eq 'labels' then labels= stringvector(getText(tmp)) $
          else if name eq 'idlcode' then begin
            result= execute(strRemoveQuotes(getText(tmp)))
          endif else begin       
            result=execute(name+'='+getText(tmp))
            ;print,name+'='+getText(tmp)
            if result ne 1 then begin
                message,'error in parsing variable '+name
                stop
            endif
          endelse
      endelse
    endif
    tmp=tmp->getNextSibling()
  endwhile 
  if strlowcase(type) eq 'text' then begin
      lR->section,level,title,newpage=newpage,clearpage=clearpage
      if n_elements(text) ne 0 then lR->append,text
  endif else begin
    multipsd,filelist,roi_um=roi_um,nbins=nbins,sectionlevel=level,outname=outname,$
      text=text,report=lR,labels=labels,outfolder=outfolder,includeSections=sectionTypes(type),$
      baseIndex=baseIndex,xindex=xIndex,xoffset=xoffset,groups=groups,groupnames=groupnames
  endelse
  obj_destroy,tmp
  print
end


pro reportparser,xmlFile
; Parse an XML file describing the structure of a report document and create the report.
; STRUCTURE OF THE XML FILE
; The document structure is included between the tags <report> and </report>
; There are a number of predefined variables. Non predefined variables are assigned to a variable with
; the name included in the tag. Strings (enclosed by apostrophes) inside the tag idlcode are supposed
; to contain IDL code that is processed.
; All variables are valid at a local level (i.e. inside one section or at the higher 'report' level)
; 
; The variables describing the report are:
;   <outfile>'/home/cotroneo/Desktop/PSD/test2/report1.tex'</outfile>
;   <author>'Vincenzo Cotroneo'</author>  
;   <title>'Measurement of Different types of Glass 1: tuning of parameters and first scans'</title>
;   <date>'current'</date>
;   <toc> 1 </toc>
;   <maketitle> 1 </maketitle>
;   <version>1.0</version>  
; N.B.: the couple OUTFOLDER and OUTNAME must be unique for each section.
;       For more details, see the comments in multi_psd. 
; 
; Permitted types of section:
; text: simply create a new section using the text (without delimiters)
; complete:
; average:
; differences:
; N.B.: these are defined inside the function sectionTypes, according to the subset of information
; to be displayed. Up today 2/25/2011, the possible subsets are:
;
;    0 general information
;    1 raw data and scan settings
;    2 leveling and stats
;    3 psd average with fit
;    4 differences between raw profiles and stats   
;    5 differences between leveled profiles and stats
;    6 psd analysis and fit
;      
;resulting in preset tipes:
;    'debug':all info
;    'profile':[0,1,2]
;    'differences':[0,1,2,4,5,6]
;    'psdaverage':[0,1,3,6]
;    'psdgroups':[0,3]
;

oDocument = OBJ_NEW('IDLffXMLDOMDocument', FILENAME=xmlfile,/Exclude_ignorable_whitespace )  
oMain=oDocument->getfirstChild()

tmp=oMain->getFirstChild()
while(OBJ_valid(tmp)) do begin
  class=obj_class(tmp)
  if class ne 'IDLFFXMLDOMTEXT'  then begin  ;skip white spaces
    if class eq 'IDLFFXMLDOMCOMMENT' then begin
       ;if obj_valid(lR) eq 1 then lR->comment,tmp->getdata()
       goto, readNext
    endif
    name=strlowcase(tmp->getTagName())
    if name eq 'section' then begin
      if obj_valid(lR) eq 0 then begin
        lR=obj_new('lr',outfile,title=title,author=author,header=header,$
                    footer=footer,toc=toc,maketitle=maketitle,level=level) ;if this is the first section create the report
        if file_test(file_dirname(outfile),/directory) eq 0 then file_mkdir,file_dirname(outfile) ;automatically create also outfolder            
        FILE_COPY, xmlfile,file_dirname(outfile)+path_sep()+file_basename(xmlfile),/overwrite,/allow_same
      endif 
      if n_elements(text) ne 0 then lR->append,text   ;if there is text before the section add it before processing the section
      if n_elements(level) eq 0 then level=0          ;if the section level is not defined assumes the highest level
      processSection,tmp,lR,outfolder=file_dirname(outfile),level=level ;the routine will recover all the variables internal to the
      ;section and will process them after having read all the internal tags.
    endif else begin
      if name eq 'text' then text=(n_elements(text)eq 0?'':text)+getText(tmp) $
      else if name eq 'filelist' then filelist= stringvector(getText(tmp)) $
        else if name eq 'labels' then labels= stringvector(getText(tmp)) $
        else if name eq 'idlcode' then begin
          result= execute(strRemoveQuotes(getText(tmp)))
        endif else begin       
          result=execute(name+'='+getText(tmp))
          if result ne 1 then begin
              message,'error in parsing variable '+name
              stop
          endif
        endelse
    endelse
  endif
  readnext: tmp=tmp->getNextSibling()
endwhile 

lR->compile,3,/pdf,/clean
obj_destroy,lR
obj_destroy,oMain
obj_destroy,oDocument
help,/heap

end

pro DektatParser,xmlFile
;Launch the analysis of a file or a list of file. 
;A list of files or a single file can be passed as argument, if called without arguments, 
; the user is prompted for selection. 
; The two ways are equivalent, in the following we will refer to these file or list
;of files as 'passed as arguments'.
;
;File can be either of two types (but they are assumed to be all of the same kind):
;* XML files, describing the structure of the output report
;* data file, containing data from Dektat scans.
;If data files are passed as argument, a generic complete report with default
;settings, will be generated.
;This file will contain many information, probably not all of them are useful, 
;to generate a file with a custom structure and custom settings, please use a XML file
;(see related documentation in reportparser procedure).

;If XML files (with extension .xml) are used, the description and position where to generate the report file 
;is expected to be contained in the XML file. When data files are selected, 
;the report will be generated in the directory of the first file passed as argument.
;If the folder already exist the user is prompted for overwriting or choosing a new name.
;
;e.g. if the first file, located in 'FOLDER' is named 'FILE1' 
;a folder with name 'FILE1' will be generated in 'FOLDER'. 
;The folder will contain all the information and figures generated by the program,
;and a latex file for the report, named 'FILE1_report.tex' will be created.
;If a working version of latex and dvipdfm are installed on the machine, the latex file
;will be compilated, resulting in a file 'FILE1_report.pdf'.
;
;N.B.: a complete set of information and plots is generated, including the plots that will
;not appear in the report. 
   
if n_elements(xmlfile) eq 0 then begin
  filelist = DIALOG_PICKFILE( title='Select csv file (data) or XML (report description) file.', $
  /MULTIPLE_FILES,/MUST_EXIST, /READ) 
  ;if XML file(s) call report_parser, if data file call directly multipsd
  if filelist eq '' then exit
  if file_extension(filelist[0]) eq 'xml' then begin
    for i =0,n_elements(filelist)-1 do begin
      file=filelist[i]
      report_parser,file
    endfor
  endif else begin
     wait,2
     multipsd,filelist,nbins=100,sectionlevel=1,outname=outname,$
     title=title,outfolder=outfolder,nonum=1,$
     includeSections=-1
  endelse     
end

end

;xmlfile='/home/cotroneo/Desktop/PSD/testNaN.xml'
xmlfile='/home/cotroneo/Desktop/work_metrology/report1.xml'
;xmlfile='/home/cotroneo/Desktop/PSD/testPlots.xml'
xmlfile='/home/cotroneo/Desktop/work_metrology/testAvgPSD.xml'
xmlfile='/home/cotroneo/Desktop/work_metrology/PSD/Vincenzo_glass4/Vincenzo_glass4_complete.xml'
reportparser,xmlfile
end