
function makestart,range
  ;build a starting simplex with random points
  common ss,ssss
  
  ndim=size(range,/dimensions)
  ndim=ndim[0]
  seed=randomu(ssss)
  starting=randomu(seed,ndim,ndim+1)
  ;print,"seed= ",seed
  for i =0,ndim do begin
    starting[*,i]=range[*,0]+(range[*,1]-range[*,0])*starting[*,i]
  endfor
  return, starting
end

function minquad,data,fit
  return,total((data-fit)^2)
end

function fomwrapper,parvector
;la funzione passata ad amoeba deve accettare come unico parametro un vettore
;nello spazio dei parametri da ottimizzare. 
;per questo creo un generico wrapper della fom, basandosi su 'funzione' e 'fom'
;ritorna la fom dei parametri. 'Parametri' e' per esempio un vertice di un simplex
  common wrapper,funzione,fom,datax,datay
  sim=call_function(funzione,parvector,datax)  ;calcola i dati simulati in base a 'funzione'
  return,call_function(fom,datay,sim)  ;usa 'fom' per calcolare la fom dai due vettori di dati
end

function fitCircleLS,th,rmeas,nsim=nsim,tol=tol,itmax=itmax,$
  funzione=funk,fom=fomer,range=range
  
  common wrapper,funzione,fom,datax,datay
  
;usa una qualche funzione numerica di ottimizzazione per
;fittare il cerchio reale ai minimi quadrati
funzione=funk
fom=fomer
datax=th
if n_elements(tol) eq 0 then tol=1.0e-10
if n_elements(nsim) eq 0 then nsim=100 ;numero di simplex sorteggiati
if n_elements(itmax) eq 0 then itmax=1000 ;numero di mosse del simplex 
if n_elements(fom) eq 0 then fom='minquad'

s=size(range,/dimensions)
ndim=s[0]
datay=rmeas

for i=1,nsim do begin
  simplex=makestart(range)
  s=amoeba(tol,function_name='fomwrapper',nmax=itmax,simplex=simplex,FUNCTION_VALUE=d)
  ;if (n_elements(s) eq 1) && (s eq -1) then continue
  if (n_elements(mindist) eq 0) then begin
    mindist=d[0]
    bestpars=simplex[*,0]
  endif else begin
    if (d[0] lt mindist) then begin
      mindist=d[0]
      bestpars=simplex[*,0]
    endif
  endelse
endfor

return,bestpars

end
