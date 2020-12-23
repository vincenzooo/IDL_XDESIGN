;+
; NAME:
; REFLEX_IMD
;
; PURPOSE:
; Wrapper for IMD fresnel function. Launch with material names instead of
; refracion indices. Not very efficient if you have to call it many times
; as it has to read index files every time is called (as opposite to directly call FRESNEL).
;
; CATEGORY:
; Reflex
;
; CALLING SEQUENCE:
; Reflex = Reflex_IMD(th, lam, materials,z,sigma)
;
; INPUTS:
; Format of inputs is same as IMD FRESNEL procedure, with Materials replacing refraction indices
; 
; Th: Scalar or 1-D array of incidence angles, in degrees,
;               measured from the normal 
; Lam: Scalar or 1-D array of wavelengths.  Units for LAMBDA
;                are the same as for Z and SIGMA.
; Materials: vector of strings with material names.
; Z: 1-D array of layer thicknesses. Units for Z are the same
;           as for SIGMA and LAMBDA.
; Sigma: Scalar, 1D or 3D array of interface widths.  If SIGMA
;               is a scalar, then the same roughness value is applied
;               to each interface.  If SIGMA is a 1-D array, it must
;               have (N_ELEMENTS(Z)+1) elements, corresponding to the
;               number of interfaces in the stack.  If SIGMA is a 3-D
;               array, it must have
;               (N_ELEMENTS(THETA),N_ELEMENTS(LAMBDA),N_ELEMENTS(Z)+1)
;               elements. Units for SIGMA are the same as for LAMBDA
;               and Z.
;
; OPTIONAL INPUTS:
; c_thick: thickness of optional overcoating
; c_mat: string, material of optional overcoating, must match a IMD optical constant file without nk extension.
;
; OUTPUTS:
; Return reflectivity from list of materials names (one per layer), list of thicknesses,
; list of rougness in angstrom, and optional overcoating descriptors.
; R[n,*] is reflectivity as a function of energy.
;
; SIDE EFFECTS:
; Describe "side effects" here.  There aren't any?  Well, just delete
; this entry.
;
; RESTRICTIONS:
; IMD functions must be loaded before with .run IMD
; Indices are loaded every time the function is called, so it might be not optimally
;   efficient.
;
; PROCEDURE:
; Return reflectivity from list of materials names (one per layer), list of thicknesses,
;   list of rougness in angstrom, and optional overcoating descriptors.
; IMD functions need to be loaded at beginning, software tries to load them otherwise, but
;   this doesn't seem to work, load them by calling .run IMD in command line before RIFLE
;   and closing all windows (there might be a IMD or IDL option to avoid windows at all).
;
; EXAMPLE:

;
; MODIFICATION HISTORY:
;   2020/06/14 renamed to REFLEX_IMD from Reflex_IMD
;   2019/03/25 moved to independent file from reflex_funk_beta
;   
;   Written by: Vincenzo Cotroneo, Date.
;   Harvard-Smithsonian Center for Astrophysics
;   60, Garden street, Cambridge, MA, USA, 02138
;   vcotroneo@cfa.harvard.edu
;
;   Written by: Vincenzo Cotroneo, Date.
;   INAF/Brera Astronomical Observatory
;   via Bianchi 46, Merate (LC), 23807 Italy
;   vincenzo.cotroneo@brera.inaf.it
;
;-

;ORIGINAL DOCUMENTATION
;wrapper per la funzione fresnel di imd, si lancia con i nomi dei materiali
;invece che gli indici di rifrazione.
;e' vero che e' un po' una minchiata, in quanto cosi' li rilegge ogni volta da file...

;restituisce la riflettivita', passando la lista dei nomi dei materiali (stringhe),
;lista degli spessori, lista delle rugosita', spessore dell'eventuale overcoating.
;la matrice di angoli (x) ed energie (y) e' contenuta nel blocco common.
;R[n,*] e' la riflettivita' in funzione dell'energia
;;usa le funzioni di imd, quindi le carica all'inizio se non gia' fatto
;(o almeno ci prova: non funziona, bisogna lanciare imd a mano)



function Reflex_IMD, th, lam, materials,z,sigma,c_thick,c_mat

  ;------------------------------------
  if n_elements(c_thick) eq 0 then c_thick=0

  c_flag=c_thick ne 0? 1:0
  c_thick=float(c_thick)
  if n_elements(c_mat) eq 0 then c_mat='a-C'
  nm=n_elements(materials)
  nl=n_elements(lam)
  if c_flag eq 1 then begin
    nc=load_nc(lam, materials,c_mat)
    z2=[c_thick,z]
  endif else begin
    nc=load_nc(lam, materials)
    z2=z ;questo per impedire di restituire z modificato
  endelse
  FRESNEL, th, lam, nc, z2,sigma, RA=RA, mfc_model=1 ;mfc_model=1 treats reflectivity reduction according to nevot-croce ;,RS=RS,RP=RP
  return,ra
end

; 2020/06/14 Add example.

; CALLING SEQUENCE:
;
;       FRESNEL, THETA,LAMBDA,NC,Z[,SIGMA,INTERFACE,F,Q]
;
; INPUTS:
;
;       THETA - Scalar or 1-D array of incidence angles, in degrees,
;               measured from the normal.
;
;       LAMBDA - Scalar or 1-D array of wavelengths.  Units for LAMBDA
;                are the same as for Z and SIGMA.
;
;       NC - Complex array of optical constants.  The dimensions of NC
;            must be (N_ELEMENTS(Z)+2,N_ELEMENTS(LAMBDA)).
;
;       Z - 1-D array of layer thicknesses. Units for Z are the same
;           as for SIGMA and LAMBDA.
;
alpha=90.-1.3425 ;[1.8517,1.3425,0.5440]
en_vec=5d*(findgen(100))/100.+0.5
lam=12.398425/en_vec  ;entrano le energie in keV, le devo converire in A
;sample structure without carbon
z=[300.]
mat='Au'
c_mat='a-C'
materials=[mat,'Ni']
;repeated bilayer stack, rebin doesn't work with strings, use trick
m_str=['Pt','a-C']
mat_ml = [m_str[Reform(Rebin([0,1], 2, 10), 20)] ,'Ni']
z_ml = [Reform(Rebin([20,40], 2, 10), 20)]
sigma=0.
c_thick=75d0

nc_bare=load_nc(lam,materials)
nc_coated=load_nc(lam,materials,c_mat)
nc_ml=load_nc(lam,mat_ml)
fresnel,alpha, lam, nc_bare,z,sigma,ra=r_bare
fresnel,alpha, lam, nc_coated,[c_thick,z],sigma,ra=R_coated
fresnel,alpha, lam, nc_ml,z_ml,sigma,ra=R_ml

cleanup
setstandarddisplay

plot,en_vec,r_bare,yrange=[0,1]
oplot,en_vec,r_coated,color = 2
oplot,en_vec,r_ml, color=3

legend,['Au','Au+C','Pt/C multilayer'],color=[1,2,3]

;compare with direct fresnel formula
nkpath='C:\Users\kovor\Documents\IDL\user_contrib\imd\nk'
;r2=reflex2D_IRT(energy,!PI/180.*(90.-alpha),nkpath+path_sep()+mat+'.nk')
;oplot,en_vec,r2,color=2,psym=1
;wshow

;window,1
;plot,en_vec,r_bare-r2,title='Difference IMD - IRT'

end
