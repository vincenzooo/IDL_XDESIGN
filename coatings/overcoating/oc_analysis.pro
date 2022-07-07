;+
; NAME:
; OC_ANALYSIS
;
; PURPOSE:
; Compute effective areas for overcoating on top of a reflective layer for a range of angles and energies, 
; for fixed or optimized overcoating thickness.
;
; CATEGORY:
; COATING
;
; CALLING SEQUENCE:
; OC_ANALYSIS, angle, ener, c_mat, c_thick
;
; INPUTS:
; ANGLE: vector of grazing angles (size nA) in degrees.
; ENERGY: Energy vector (size nE) in keV.
; Both ANGLE and ENERGY were provided as range (min,max) which is maintained for backwards compatibility if 2 elements,
;   in that case, 200 points are used.
; C_MAT: material overcoating as string (see ** for format)
; C_THICK: thickness to use 
;
; OPTIONAL INPUTS:
; OPTIMIZE If set to an integer, perform overcoating thickness optimization for each angle using
;    the integer as number of points for raster scan (range is set with C_THICK).
;
; KEYWORD OUTPUTS:
; R_BARE
; R_COATED
; BESTVEC
;
; RESTRICTIONS:
; Use IMD reflectivity calculation, IMD must be loaded prior to function. The interface is not optimal,
;   it can probably be updated by removing /OPTIMIZE and/or getting more control with C_THICK (e.g.
;   setting vector to have a different thickness at each angle; or min, max, step, or arrays of values for optimization). 
;
; PROCEDURE:
; Use 
;
; EXAMPLE:
; See at the end of this file.
;
; MODIFICATION HISTORY:
; VC 2022/07/07 written this help. The old plotgain (oc_optimizer.pro) was removed to obsolete.
; This is its copy where material is passed as a structure and plotting part is separated out, and can be
;   obtained by calling plot functions on results, like in the example.
;   OC_ANALYSIS now exclusively deals with calculation and optimization of the effective area with and without
;   coating, so I remove legacy arguments AREA_GAIN and PERC_GAIN which now are calculated in PLOT_GAIN. 
; VC 2019/03/22 this was plotgain, that was merged with routine in plot, leaving here the part with analysis.
; Revision from old code (probably 2010?).
;-

pro oc_analysis, mat_struct, angle, energy, c_mat, c_thick, optimize=optimize,$
  r_bare=r_bare,r_coated=r_coated,besttvec=besttvec
  
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

  if n_elements(angle) eq 2 then begin
    th_points=200
    th_range = angle
    th_step=(th_range[1]-th_range[0])/(th_points-1)
    th_deg=th_range[0]+th_step*indgen(th_points)
  endif else th_deg = angle
  th=90.-th_deg

  if n_elements(energy) eq 2 then begin
    en_points=200
    en_range = energy
    en_step=(en_range[1]-en_range[0])/(en_points-1)
    en=en_range[0]+en_step*indgen(en_points)
  endif else en = energy
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
    if n_elements(t_range) eq 0 then t_range=c_thick   ;[20.,270.]
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
  
  Pt={sample,material:'Pt',density:21.4,filename:'PtC',octhickness:80.}  ; material structure
  
  ;not necessary to use a structure here, just for backwards compatibility
  hxmt={name:"PolariX/HXMT", angles:[0.61,0.88],energy:[2.,8.],$         
    color:4,labeloffset:[0.95,6.2],linestyle:0}  ;labeloffset:[0.07,2.80]
  theta = vector(hxmt.angles[0],hxmt.angles[1],200)
  ener = vector(hxmt.energy[0],hxmt.energy[1],200)
  ;-------------------------------------
  ;generate the 3d plot of angle-energy gain
  mat=Pt     ;mat
        
  oc_analysis,mat,theta,ener,'a-C',[20.,270.],$
   r_bare=r_bare,r_coated=r_coated,optimize=1,besttvec=besttvec
  
  ; can be removed and put in external test:
  plot_gain,theta,ener,R_coated,R_bare,density,filename=mat.filename,$
     perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,window=5
  print,bestTVec
  window,2
  plot,bestTVec
  maketif,mat.filename+'_thick'
  
;  oc_analysis ,mat,[0,2.0],[0.1,10.],'a-C',80.,perc_gain=perc_gain,area_gain=area_gain,$
;    ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated
  ;oc_analysis ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
    ;ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated
;  
;  plot_gain,theta,ener,R_coated,R_bare,mat.density,filename=mat.filename,$
;      perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,$
;      window=3,extracolors=extracol
 
end

