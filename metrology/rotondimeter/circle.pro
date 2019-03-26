function circle,pars,th ;pars=[xc,yc,r]
  ;restituisce le coordinate polari misurare del cerchio con parametri xc,yc,r
  ;rispetto all'origine per un vettore di angoli theta (in radianti)
  if n_elements (nptheta) eq 0 then nptheta=360
  if n_elements(th) eq 0 then th=2*!PI*findgen(nptheta)/(nptheta-1)
  a=pars[0]
  b=pars[1]
  r=pars[2]
  phi=atan(b,a)
  return, a*cos(th)+b*sin(th)+sqrt(r^2-(a^2+b^2)*sin(th-phi))
  ;la deviazione dal limaison e' quindi il secondo termine -r
end