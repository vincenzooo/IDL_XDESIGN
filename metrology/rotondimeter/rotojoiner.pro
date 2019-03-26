
function graphAlign,data1,data2,range,yShiftVec=yshift,tolerance=toll,x=x
  ;shifta il secondo array per farlo coincidere con il primo nel
  ;punto di indice joinIndex. L'entita' (media) dello shift puo' essere restituito
  ;in yshift. Scale is a 2 elements vector containing the range of data
  ;(supposed equal for the two arrays) serve solo per evidenziare i punti vicini al 
  ;limite sul grafico. In tal caso viene usato anche toll.
  ;x puo' essere passato per il plot.
  
  windnum=4
  
  ;il range viene usato solo per evidenziare i punti che sforano
  if n_elements (toll) eq 0 then toll=0.01
  if n_elements (x) eq 0 then x=indgen(n_elements(data2))
  if n_elements (range) ne 0 then begin
    fullrange=range[1]-range[0]
    minrange=range[0]+toll*fullrange
    maxrange=range[1]-toll*fullrange
  endif
  
  confirm='Cancel'
  while confirm ne 'Yes' do begin
    window,windnum
    plot,x,data1,yrange=[min([data1,data2]),max([data1,data2])]
    oplot,x,data2,color=100
    legend,['data1','data2'],color=[255,100]
    
    risposta=dialog_message("Use two points joining for copying data2 to data1 ('No'"+$
            " for single point joining, 'Cancel' to finish)?",/cancel,/question)
    yshift=[1.] ;in idl non si possono creare array vuoti.
    correctedData=data1
    while risposta ne 'Cancel' do begin
      ;scegli le regioni del secondo set di dati da rimpiazzare
      badpoints2=GET_ROI(X,data1,h_color=150,h_thick=2)
      wait,1
      nbad=n_elements(badpoints2)
      badstart=badpoints2[0]
      badend=badpoints2[nbad-1]
      ;calcola yshift a seconda del caso
      if risposta eq 'Yes' then begin ;two points joint
        shiftVec=(correctedData[badstart]-data2[badstart])+indgen(nbad)*$
        ((correctedData[badend]-data2[badend])-(correctedData[badstart]-data2[badstart]))/(nbad-1)
      endif else begin
         if risposta eq 'No' then begin ;one point
                ;scegli con il mouse il punto di unione dei due grafici, calcola lo shift
            print,"select a point for joining the graphs nr"
            cursor, xCursor,yCursor
            wait,1
            jIndex=round(findex(x,xCursor)) ;nearest integer 
            shiftVec=fltarr(nbad)+(correctedData[jIndex]-data2[jIndex])
         endif else begin ;impossibile che succeda
            print,"Answer: ",risposta
            message, 'Unexpected Answer:',risposta
         endelse
      endelse
      ;if c eq 0 then return,correctedData
      correctedData[badpoints2]=data2[badpoints2]+shiftVec
      yshift=[yshift,total(shiftVec)/nbad]
      plot,x,data1,yrange=[min([data1,data2,correctedData]),max([data1,data2,correctedData])]
      oplot,x,data2,color=100
      oplot,x,correctedData,color=150,linestyle=3
      legend,['data1','data2','corrected'],color=[255,100,150]
      risposta=dialog_message("Another region ('No'"+$
            " for single point joining, 'Cancel' to finish)?",/cancel,/question)
    endwhile
    if n_elements(yshift) le 1 then yshift=[0] else begin
      yshift=yshift[1:*]
      ;yshift=total(yshift)/n_elements(yshift)
    endelse
     print,"yshift delle regioni rimpiazzate: ",yshift 
    confirm=dialog_message("Continue (cancel for redoing)?",/question,/cancel)
    if confirm eq 'No' then stop
  endwhile
  return,correctedData
  
end

function listJoiner, filelist,yshift=yshift,x=angdeg
;unisce tutti i file della lista, ritorna i dati giuntati
;opzionalmente il vettore degli shift
;mettere qualcosa per gestire internal-external
;marcare i punti dove esce dal range
;metter opzione autoselect per fargli selezionare i punti in cui giuntare
windnum=2

nfiles=n_elements(filelist)
colorstep=250/(nfiles-1)
colorVec=indgen(nfiles)*colorstep+1

;legge i file e li carica nella matrice data
readcol,filelist[0],angChk,data,skipline=8
massimo=max(data)
minimo=min(data)
for i =1,nfiles-1 do begin
  readcol,filelist[i],angdeg,dummy,format='F,F'
  data=[[data],[dummy]]
  if not(array_equal(angdeg,angchk)) then begin
      message, "x data are not the same for the different files:"+$
            filelist[i-1],filelist[i]
  endif
  massimo=max([massimo,data[*,i]])
  minimo=min([minimo,data[*,i]])
endfor

;plotta i dati
window,windnum
for i =0,nfiles-1 do begin
  if i eq 0 then plot,angdeg,data[*,i], yrange=[minimo-0.1*abs(minimo),$
       massimo+0.1*abs(massimo)],ystyle=(!y.style && 1) $
  else oplot, angdeg,data[*,i],color=colorVec[i]
endfor

legend,string(indgen(nfiles)+1),color=colorVec,position=12
yshift=[-1]
for i = 0, nfiles-2 do begin
  shiftedData=graphAlign(data[*,0],data[*,1],yshiftvec=ys)
  yshift=[yshift,total(ys)/n_elements(ys)]
  data[*,1]=shiftedData
  ;plot,angdeg,shiftedData
  newdata=data[*,1:*]
  data=newdata
endfor
yshift=yshift[1:*]
print,"shift medi per ogni file:",yshift
return,data
end

pro serialJoiner
  ;unisce una serie di gruppi di file letti da file, crea l'output in
  ;automatico
  
  ;per ora funziona con un singolo gruppo di file e chiede il nome del file di output
end

cd, programrootdir()

device, decomposed =0
tek_color
loadct, 39

;fl=['d:\work\work_wfxt\rotondimetro\misure\8_wfend\WFEND09_13_joined.dat',$
;    'd:\work\work_wfxt\rotondimetro\misure\8_wfend\WFEND13']
fl=['test\rotojoiner\WFEND09_13_joined.dat',$
    'test\rotojoiner\WFEND13']

newlist=dialog_pickfile(/read,path=wd,get_path=wd,/multiple_files)
if n_elements(newlist) ne 1 || newlist ne '' then fl =newlist

joinedData=listJoiner(fl,x=x)
plot,x,joinedData,xstyle=1
outfile=dialog_pickfile(file=file_basename(fl[0])+"_joined.dat",/write,$
         /overwrite_prompt,path=wd,get_path=wd)
if outfile ne '' then begin
  if n_elements(x) ne 0 then writecol,outfile,x,joineddata $
  else writecol,outfile,joineddata  
endif
print,"done!"
end