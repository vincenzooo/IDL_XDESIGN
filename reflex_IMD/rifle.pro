;   2019/03/25 moved to independent file from reflex_funk_beta

;+
; NAME:
; RIFLE
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
; Reflex = Rifle(th, lam, materials,z,sigma)
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



function Rifle, th, lam, materials,z,sigma,c_thick,c_mat

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
  FRESNEL, th, lam, nc, z2,sigma, RA=RA  ;,RS=RS,RP=RP
  return,ra
end

