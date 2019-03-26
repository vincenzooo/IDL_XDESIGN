;+
;
;TODO:
;Verify the setting of nbins and binsize.

; :Description:
;    Plot histograms and stats. Return a vector with the calculated values for selected
;    statistical functions.
;
; :Params:
;    data
;
; :Keywords:
;    min
;    max
;    binsize
;    normalize
;    locations
;    hist
;    position
;    nan
;    outVars: it is a vector of indexes for the variables to include in output. The
;        order of indexes determine the order of output.
;    /HEADER: if this flag is set, just return an array of strings with the stats descriptions
;    (useful to create table headers).
;    statString
;    yscale
;    TABLE: if set return stats as a TABLE object.
;    _extra
;    legend
;    NOPLOT: only return stats, without plotting.
;    bTitle
;    COLOR: can be scalar or array (in that case one color per line).
;
; :Author: cotroneo
; 2012/08/29
; if binsize is calculated from nbins, the calculation is performed converting min and max
;   to double. This avoid errors (binsize=0) if parameters are provided as integer (e.g. min=3).
; 
; 2011/03/25
; *Improved the print help string (now return without error)
; *Improved the header mechanism: return the header string if called without data, otherwise returns the 
;   string in HEADER
; *added the keyword TABLE 
; *changed the calculation mechanism for binsize and nbins: binsize is used as internal variable and has priority
;   if both are defined. nbins =100 is used if none is defined.
; 
; 2011/01/13 
; *replaced: 
;   IF (KEYWORD_SET(NBINS) AND KEYWORD_SET(BINSIZE)) THEN BEGIN
; with:
;   IF ((N_ELEMENTS(NBINS) NE 0) AND (N_ELEMENTS(BINSIZE) NE 0)) THEN BEGIN
; *added visulization of help if launched without data.
; *added BINSIZE in histogram arguments
;-
function histoStats_single,data,min=min,max=max,binsize=binsize,nbins=nbins,$
         normalize=normalize,locations=locations,hist=hist,$
         _extra=e

;internal function for a single dataset

hist=float(histogram(data,min=min,max=max,binsize=binsize,locations=locations))
if keyword_set(normalize) then hist=hist/total(hist)
;if (~keyword_set(noplot) and ~keyword_set(legend)) then $
;    plot,locations,hist,yrange=[0,max(hist)*yscale],_extra=e,psym=10,color=color[0]
result=moment(data,mdev=avgdev,sdev=stddev,nan=nan)
npoints=n_elements(data)
       
statsval=[result[0],$                ;0:avg
       max(data)-min(data),$      ;1:PV
       min(data),$                ;2:min
       max(data),$                ;3:max
       stddev,$                   ;4:standard deviation (rms)
       avgdev,$                   ;5:mean of absolute deviation (Ra)
       stddev/sqrt(npoints),$  ;6:standard deviation of the mean
       result[1],$                ;7:variance
       result[2],$                ;8:skewness
       result[3],$                ;9:kurtosis (residual with respect to 3 (gaussian))
       npoints]                   ;10:npoints (residual with respect to 3 (gaussian))

return,statsval    
end

function histoStats,indata,matrix=matrix,min=min,max=max,binsize=binsize,nbins=nbins,normalize=normalize,$
         locations=locations_m,hist=hist_m,position=position,table=table,vecnames=vecnames,$
         nan=nan,outVars=outVars,string=string,latex=latex,yscale=yscale,$
         legend=legend,noplot=noplot,boxTitle=bTitle,color=color,header=header,window=window,$
         format=format,_extra=extra,fieldwidth=fieldwidth,psfile=psfile,excludeouter=excludeouter

  headerstring=['Mean','PV','Min','Max','Rms','Ra','Stndrd dev of mean',$
                'Variance','Skewness','Residual kurtosis','N points'] ;complete list of names for the fields              
  formatstring=['g0.3','g0.3','g0.3','g0.3','g0.3','g0.3','g0.3','g0.3','g0.3','g0.3','i']
  ;formatstring=replicate('f0.3',11)
  if n_elements(fieldwidth) eq 0 then fieldwidth=8
  
  if n_elements(outvars) ne 0 then headerstring=headerstring[outvars]       
  if keyword_Set(header) then begin  
    if n_elements(indata) eq 0 then return, headerstring else header=headerstring
  endif       
  
  
  if (n_elements(indata) eq 0) then begin
      if arg_present(indata) then message,"the input data variable is empty." else begin
        PRINT,"function HISTOSTATS"
        print,"Plot histograms and stats. Return a vector with the calculated values for selected"
        print,"statistical functions."
        print,"USAGE:"
        print,"result=histoStats(indata,min=min,max=max,binsize=binsize,nbins=nbins,normalize=normalize,$"
        print,"locations=locations,hist=hist,stats=stats,position=position,$"
        print,"nan=nan,outVars=outVars,statString=statString,yscale=yscale,_extra=e,$"
        print,"legend=legend,noplot=noplot,boxTitle=bTitle,color=color,header=header"
        print
        print,"outVars: it is a vector of indexes for the variables to include in output."
        print,"possible variables:"
        print,strtrim(sindgen(n_elements(headerstring)),2)+" "+headerstring+newline()
        print,"/HEADER: if this flag is set, just return an array of strings with the stats descriptions."
        print
        print
        return,0
      endelse
  endif

  if keyword_set(matrix) then begin
    naxis=size(indata,/n_dimensions)
    case naxis of 
      0: message,"Single value data. Cannot calculate statistics"
      1: begin
          message,"Vector data, but MATRIX keyword is set. It will be ignored.",/informational
          data=indata
        end
      2: data=reform(indata,n_elements(indata))
      3: begin
           s=size(indata,/dimensions)
           data=reform(indata,s[2])
           Result = DIALOG_MESSAGE("Multiple 2d data, beware, option is not tested.",/information)
         end
      else: message,"I don't konw how to handle data with more than three axis."
    endcase
  endif else data=indata
  
  nvectors=nvectors(data)
  if n_elements(yscale) eq 0 then yscale=1.1
  if n_elements(min) eq 0 then min=min(data,/nan)
  if n_elements(max) eq 0 then max=max(data,/nan)
  if n_elements(position) eq 0 then position=10
  
  if keyword_set(noplot) and keyword_set(legend) then message,$
    "histostat function: Only one can be set between noplot and legend:"+newline+$
    "legend: plot the legend only over an existing graph"+newlinw+$
    "noplot: do not plot anything, just return the string and the results from analysis"

  ;only one between binsize and nbins can be set. If this was the case
  ;histogram is called with the corresponding parameter.
  ;if both are set binsize is changed according to nbins.
  ;if none of them is set histogram is called with undefined values.
  ;however what happens is not always clear.
  if ((n_elements(nbins) ne 0) and (n_elements(binsize) ne 0)) then begin
      message,'Both NBINS (='+string(nbins)+') and BINSIZE (='+string(binsize)+$
      ') have been set. BINSIZE will be ignored.',/informational
      BINSIZE=(double(MAX)-double(MIN))/NBINS
  endif else if ((n_elements(nbins) eq 0) and (n_elements(binsize) eq 0)) then begin
      message,'Neither NBINS and BINSIZE '+$
      'have been set. NBINS=100 will be used as default value.',/informational
      nbins=100 
      BINSIZE=(double(MAX)-double(MIN))/NBINS
  endif else if ((n_elements(nbins) ne 0) and (n_elements(binsize) eq 0)) then begin
      BINSIZE=(double(MAX)-double(MIN))/NBINS
  endif
  
  i=0
  if keyword_set(excludeouter) then begin
    selindex=where(data[*,i] gt min and data[*,i] lt max,c)
    if c eq 0 then begin
      message,'No elements in range for dataset'+(nvectors gt 1?(" "+string(i)):"")+', all dataset will be included in statistics.',/informational
      selindex=lindgen(n_elements(data[*,i]))
    endif
  endif else selindex=lindgen(n_elements(data[*,i]))
  stats_m=histostats_single(data[selindex,i],min=min,max=max,binsize=binsize,$
      normalize=normalize,locations=zlocations,hist=zhist,_extra=extra,window=window)
  locations_m=zlocations
  hist_m=zhist
    for i=1,nvectors-1 do begin
    if keyword_set(excludeouter) then begin
      selindex=where(data[*,i] gt min and data[*,i] lt max,c)
      if c eq 0 then begin
        message,'No elements in range for dataset'+(nvectors gt 1?(" "+string(i)):"")+', all dataset will be included in statistics.',/informational
        selindex=lindgen(n_elements(data[*,i]))
      endif
    endif else selindex=lindgen(n_elements(data[*,i]))
    tmp=histostats_single(data[selindex,i],min=min,max=max,binsize=binsize,$
        normalize=normalize,locations=zlocations,hist=zhist,table=table,$
        nan=nan,outVars=outVars,statString=statString,/noplot)
    stats_m=concatenate(stats_m,tmp,2)
    locations_m=concatenate(locations_m,zlocations,2)
    hist_m=concatenate(hist_m,zhist,2)
  endfor
  
  if n_elements(outVars) ne 0 then stats_m=stats_m[outvars,*]
  if n_elements(outVars) ne 0 then formatstring=formatstring[outvars]
  if n_elements(format) eq 0 then format=formatstring
  
  gettagvalue,extra,'TITLE',title      
  if n_elements(title) ne 0 then caption='Statistics for '
  stats=obj_new('table',caption=caption,data=transpose(stats_m),$
           rowheader=histostats(outvars=outvars,/header))
  if n_elements(vecnames) ne 0 then stats->setproperty,colheader=vecnames
  
  if n_elements(bTitle) eq 0 then begin
    statBox=stats->write(/string)
    if n_elements(vecnames) ne 0 then statBox=['Stats for '+strjoin(vecnames,'  '),statbox]
  endif else statBox=[bTitle,legStr]
   
    ;; plot data. The plot needs to be done in a different step to account for the vertical range.
  if (~keyword_set(noplot) and n_elements(legend) eq 0) then $
    multi_plot,locations_m,hist_m,colors=color,oplot=oplot,psfile=psfile,background=cgcolor('white'),$
    nolegend=(nvectors eq 1),legend=vecnames,legpos=12,linestyles=linestyles,psym=10,$
    yrange=[0,yscale*max(hist_m)],_extra=extra,/nocloseps
  if ~keyword_set(noplot) then PLOT_TEXT,statbox,POSITION=position,color=color
  if n_elements(psfile) ne 0 then ps_end
  result=stats->write(string=string,latex=latex,table=table) ;for some strange reason this cannot be joined with the following
  return, result
end

pro histostats_test

  data=randomu(1,1000)
  stats=histostats(/header)
  print,stats
  help,stats
  stats=histostats(data)
  print,stats
  help,stats
  outvars=[10,0,1,4]
  stats=histostats(data,outvars=outvars,/string)
  print,stats
  help,stats
  data2=randomu(1,1000)+0.5
stats=histostats([[data],[data2]],outvars=outvars,/string)
print,stats
help,stats
stats=histostats([[data],[data2]],outvars=outvars,/table,vecname=['data1','data2'])
help,stats
stats->write
obj_destroy,stats
end

histostats_test

end
 