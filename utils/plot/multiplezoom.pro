function multipleZoom,x,y,window=windnum,startRegion=startregion,wtitle=wtitle,$
    msgText=msg,firstMsg=firstMsg,msgTitle=msgTitle,waitTime=waitTime,yesTerminate=yesTerminate
  ;perform a repeated zoom on data
  
  if n_elements(startRegion) eq 0 then begin
      startRegion=[0,n_elements(x)-1]
  endif else begin
      if n_elements(startRegion) ne 2 then message, $
          'Badly defined start region= '+string(startRegion)  
  endelse
  if n_elements(waitTime) eq 0 then waitTime=0.5
  if n_elements(msg) eq 0 then msg="Zoom again ('No'"+$
            " to keep, 'Cancel' to undo last)?"
  if n_elements(firstMsg) eq 0 then firstMsg="Do yo want to zoom ?"
  if n_elements (wtitle) eq 0 then wtitle='Zoom ?'
  if n_elements (msgTitle) eq 0 then msgTitle='Zoom ?'
  yT = n_elements (yesTerminate) 
            
  roistart=startRegion[0]
  roiEnd=startRegion[1]
  
  window,windnum,title=wtitle
  plot,x,y,psym=4,xrange=[x[roiStart],x[roiEnd]],/ynozero,xstyle=(!x.style or 1)
  risposta=dialog_message(firstMsg,/cancel,/question,title=msgTitle)
  oldRoiStart=roistart
  oldRoiEnd=roiend
  ;while risposta ne 'No' do begin
  while ((~yT) && risposta ne 'No') || ((yT) && risposta ne 'Yes') do begin
    if risposta eq 'Cancel' then begin
        ;CANCEL: undo last zoom
        roiStart=oldRoiStart
        roiEnd=oldRoiEnd
        plot,x,y,psym=4,xrange=[x[roiStart],x[roiEnd]],/ynozero,xstyle=(!x.style or 1)
    endif else begin
    if ((~yT) && risposta eq 'Yes') || ((yT) && risposta eq 'No') then begin
    ;if risposta eq 'Yes' then begin
        ;YES: seleziona e zooma
        oldRoiStart=roistart
        oldRoiEnd=roiend
        roi=GET_ROI(X,y,h_color=150,h_thick=2) ;scegli la regione su cui zoomare
        wait,waitTime
        nproi=n_elements(roi)
        roistart=roi[0]
        roiend=roi[nproi-1]
        plot, x,y,psym=4,xrange=[x[roiStart],x[roiEnd]],/ynozero,xstyle=(!x.style or 1)
     endif else begin ;impossibile che succeda  
        ;ALTRO: impossibile
        print,"Answer: ",risposta
        message, 'Unexpected Answer: '+string(risposta)
     endelse
    endelse
    risposta=dialog_message(msg,/cancel,/question,title=msgTitle) 
  endwhile
  return,[roistart,roiend]

end  

cd
filename='marposs06.txt'
folder='..\test_data\resample_data'
readcol,folder+path_sep()+filename,time,data
print,multipleZoom(time,data,window=2)

end

