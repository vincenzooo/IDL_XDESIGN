function obstructions, folder, energy, angles=ang,qaTarget=qaT
; Calcola le statistiche per le ostruzioni di una determinata cartella
; contenente dati per una sola shell.
; Restituisce una matrice con una riga per ogni angolo colonna per ogni 
; valore di qa (tipo di riflessione) in qatarget.
; Ogni cella contiene il numero di fotoni per quel qa a quell'angolo.
; L'ultima colonna e' il numero totale di fotoni per quell'angolo.  

  ang=getOAangle(folder,/arcmin)
  nangles=n_elements(ang)
  if n_elements(qat) eq 0 then qaTarget=indgen(14)+1 else qatarget=qat
  h=lonarr(n_elements(qatarget)+1,nangles)
  
  for j =0,nangles-1 do begin
    readfp,folder+path_sep()+'psf_data_'+string(j+1,format='(i2.2)')+'.txt',$
    qa=qa,qtarget=qatarget,nselected=nsel
    for i =0L, n_elements(qa)-1 do begin
      xx=in(qa[i],qatarget,/which)
      h[xx,j]=h[xx,j]+1
    endfor
    h[n_elements(qatarget),j]=nsel
  endfor
  return,h
end
;
;;per un singolo file crea il vignetting in funzione dell'angolo polare.
;;legge i punti di impatto ed estrae gli angoli 
;  readImpact,impactfile,shtarget=1,qtarget=qatarget,$
;  x1=ximp1,y1=yimp1,z1=zimp1,qa=qa
;  phi1=atan(ximp1,yimp1)
;  histogram

function obstrByPhi, folder, angles=ang,qaTarget=qaTarget
; calcola le statistiche per le ostruzioni in funzione dell'angolo polare

  ang=getOAangle(folder,/arcmin)
  nangles=n_elements(ang)
  if n_elements(qatarget) eq 0 then qaTarget=indgen(14)+1
  h=lonarr(n_elements(qatarget)+1,nangles)
  
  for j =0,nangles-1 do begin
    readfp,folder+path_sep()+'psf_data_'+string(j+1,format='(i2.2)')+'.txt',$
    qa=qa,qtarget=qatarget,nselected=nsel
    for i =0L, n_elements(qa)-1 do begin
      xx=in(qa[i],qatarget,/which)
      h[xx,j]=h[xx,j]+1
    endfor
    h[n_elements(qatarget),j]=nsel
  endfor
  return,h
end

pro plotVignetting,obsMatrix,folders,windnum
;plot vignetting functions for double reflection.
;se windnum=0 lo usa come numero della finestra.
;puo' essere chiamata direttamente o da plot device
  nfolders=n_elements(folders)
  colstep=250/(nfolders+1)
  col=0
  leg=file_basename(folders[0])
  angles=getOAangle(folders[0],/arcmin)
  if n_elements(windnum) ne 0 then window,windnum
  plot,obsMatrix[7,*,0],title='Vignetting function',xtitle='Off axis (arcmin)',$
        ytitle='Fraction of on-axis area',background=255,color=0
  for i=1,nfolders-1 do begin
    leg=[leg,file_basename(folders[i])]
    ccol=(i+1)*colstep
    col=[col,ccol]
    oplot,obsMatrix[7,*,i],color=ccol
  endfor
  legend,leg,color=col,position=12
end


pro plotQA,obsMatrix,folder,windnum
;plotta i diversi tipi di ostruzione
;per un singolo folder
;folder e' usato come titolo del plot 
;obsmatrix sono i dati relativi al singolo folder (obsMatrix[*,*,i])

  leg=file_basename(folder)
  if n_elements(windnum) ne 0 then window,windnum
  
  plot,obsMatrix[7,*], xtitle='',background=255, color=0,title='Type of trajectory - '+file_basename(folder)
  oplot,obsMatrix[3,*],color=100 
  oplot,obsMatrix[0,*]+obsMatrix[1,*]+obsMatrix[4,*]+obsMatrix[5,*],color=200
  
  legend,['Focused','Obstructed at ','Missing hyp'],color=[0,100,200],position=11
end


qatarget=[1,3,5,7,9,11,13,15]
folders=['E:\work\workOA\traie8\studioVignetting\F20D295ff000cc_thsx',$
          'E:\work\workOA\traie8\studioVignetting\F20D295ff002cc_thsx',$
          'E:\work\workOA\traie8\studioVignetting\F20D295ff004cc_thsx',$
          'E:\work\workOA\traie8\studioVignetting\F20D295ff006cc_thsx',$
          'E:\work\workOA\traie8\studioVignetting\F20D295ff008cc_thsx',$
          'E:\work\workOA\traie8\studioVignetting\F20D295ff010cc_thsx']
;tentativo non riuscito 23/6/2010
;folders=['E:\work\workOA\traie8\NHXMphB_mlArea\baseline2phB_vig']

setStandardDisplay
if n_elements(reread) eq 0 then reread=1

if reread eq 1 then begin
  nfolders=n_elements(folders)
  nqa=n_elements(qaTarget)          
  obs=obstructions(folders[0],0.0,angles=ang,qaTarget=qatarget)
  obs=float(obs)
  
  for j=0,nqa-1 do obs[j,*]=obs[j,*]/obs[nqa,*]
  obsMatrix=obs
  for i =1,nfolders-1 do begin         
    obs=obstructions(folders[i],0.0,angles=ang,qaTarget=qatarget)
    obs=float(obs)
    for j=0,nqa-1 do obs[j,*]=obs[j,*]/obs[nqa,*]
    obsMatrix=[[[obsmatrix]],[[obs]]]
  endfor
endif

plotDevice,'plotVignetting',obsMatrix,folders,0
plotDevice,'plotVignetting',obsMatrix,folders,filename=file_dirname(folders[0])+path_sep()+'vignetting.ps'
for i =0,nfolders-1 do plotDevice,'plotQA',obsMatrix[*,*,i],folders[i],$
            filename=file_dirname(folders[0])+path_sep()+'obstr_'+string(i,format='(i2.2)')+'.ps'
reread=0

end