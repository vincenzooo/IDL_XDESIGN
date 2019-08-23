;VC 2019/03/22 this was plotgain, that was merged with routine in plot, leaving here the part with analysis.

pro oc_analisys ,mat_struct,th_range,En_range,c_mat,c_thick,perc_gain=perc_gain,$
  area_gain=area_gain,optimize=optimize,theta=th,ener=en,r_bare=r_bare,$
  r_coated=r_coated,besttvec=besttvec
  
  ;+
  ; plotta statistiche riguardanti il vantaggio dell'uso del carbonio
  ; se optimize = 1 lo spessore viene ottimizzato per ogni angolo fissato
  ; per ottenere guadagno sul range energetico Erange.
  ;-----------------------------------
  ; -init-
  ; 
  ; ;density  (pro memoria):
  ; C: 1.9/2.3(graph)
  ; Ni: 8.9
  ; Au: 19.3
  ; Ir: 22.4
  ; W: 19.3
  ; Pt: 21.4
  ; Si: 2.33
  ;
  ;-
  ;
  ;common ind_vars, th, lam
  
  mat=mat_struct.material
  density=mat_struct.density
  filename=mat_struct.filename
  if n_elements(optimize) eq 0 then optimize=0
  if n_elements(filename) eq 0 then psplot=0
  if n_elements(c_mat) eq 0 then c_mat='a-C'
  ;indipendent variables

  th_points=200
  th_step=(th_range[1]-th_range[0])/(th_points-1)
  th_deg=th_range[0]+th_step*indgen(th_points)
  th=90.-th_deg

  en_points=200
  en_step=(en_range[1]-en_range[0])/(en_points-1)
  en=en_range[0]+en_step*indgen(en_points)
  lam=12.398425/en  ;entrano le energie in keV, le devo converire in A

  ;sample structure without carbon
  z=[300.]
  materials=[mat,'Ni']
  sigma=0.
  plotTif=1

  nc_bare=load_nc(lam,materials)
  nc_coated=load_nc(lam,materials,c_mat)
  loadct,12
  fresnel,th, lam, nc_bare,z,sigma,ra=r_bare

  if optimize eq 0 then fresnel,th, lam, nc_coated,[c_thick,z],sigma,ra=R_coated $
  else begin
    if optimize eq 1 then t_points=100. else t_points=optimize
    if n_elements(t_range) eq 0 then t_range=[20.,270.]
    t_step=(t_range[1]-t_range[0])/(t_points-1)
    t_vec=t_range[0]+t_step*indgen(t_points)
    if n_elements(e_range) eq 0 then begin
      minind=0
      maxind=n_elements(en)-1
    endif else begin
      minind=fix(total(en lt E_range[0])-1)
      maxind=fix(total(en lt E_range[1]))
    endelse
    ;inizia il ciclo e ottimizza la fom per ogni angInd
    bestTVec=fltarr(n_elements(th))
    R_coated=fltarr(n_elements(th),n_elements(en))
    for angInd=0,n_elements(th)-1 do begin
      best_fom=0
      best_t=100.
      for i=0,t_points-1 do begin
        fresnel,th[angInd], lam[minind:maxind], nc_coated[*,minind:maxind],[t_vec[i],z],sigma,ra=r_test
        fom=total((R_test^2-R_bare[angInd,*]^2)/R_bare[angInd,*]^2)
        if fom gt best_fom then begin
          best_fom=fom
          best_t=t_vec[i]
        endif
        fresnel,th[angInd], lam, nc_coated,[t_vec[i],z],sigma,ra=r_fullEn
        R_coated[angInd,*]=r_fullEn
      end
      bestTVec[angInd]=best_t
    end

  endelse


end



  ;example:
  
  print,"test"
  
  Pt={sample,material:'Pt',density:21.4,filename:'PtC',octhickness:80.}
  hxmt={name:"PolariX/HXMT", angles:[0.61,0.88],energy:[2.,8.],$
    color:4,labeloffset:[0.95,6.2],linestyle:0}  ;labeloffset:[0.07,2.80]

  ;-------------------------------------
  ;generate the 3d plot of angle-energy gain
  mat=Pt     ;mat
  
  extracol=[[0,0,0,0],[255,255,255,255]]
        
  oc_analisys ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
   ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated,optimize=1,besttvec=besttvec
   
  plot_gain,theta,ener,R_coated,R_bare,density,filename=mat.filename,$
     perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,window=5
  print,bestTVec
  window,2
  plot,bestTVec
  maketif,mat.filename+'_thick'
  
;  oc_analisys ,mat,[0,2.0],[0.1,10.],'a-C',80.,perc_gain=perc_gain,area_gain=area_gain,$
;    ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated
  ;oc_analisys ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
    ;ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated
;  
;  plot_gain,theta,ener,R_coated,R_bare,mat.density,filename=mat.filename,$
;      perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,$
;      window=3,extracolors=extracol
 
end

