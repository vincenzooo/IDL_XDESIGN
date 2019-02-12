;+
; NAME:
; 
;
; PURPOSE:
; Wrapper for IMD fresnel function. Launch with material names instead of
; refracion indices. Not very efficient as it has to read index files every
; time.
;
; CATEGORY:
; Reflex
;
; CALLING SEQUENCE:
; Reflex = Rifle(th, lam, materials,z,sigma)
;
;
; INPUTS:
; th: array with thickness in Angstrom.
; lam: 
; materials: array of strings with material names.
; z:
; sigma:
;
; OPTIONAL INPUTS:
; c_thick
; c_mat
;
; OUTPUTS:
;restituisce la riflettivita', passando la lista dei nomi dei materiali (stringhe),
;lista degli spessori, lista delle rugosita', spessore dell'eventuale overcoating.
;la matrice di angoli (x) ed energie (y) e' contenuta nel blocco common.
;R[n,*] e' la riflettivita' in funzione dell'energia
;;usa le funzioni di imd, quindi le carica all'inizio se non gia' fatto
;(o almeno ci prova: non funziona, bisogna lanciare imd a mano)
;
;
; COMMON BLOCKS:
; BLOCK1: Describe any common blocks here. If there are no COMMON
;   blocks, just delete this entry.
;
; SIDE EFFECTS:
; Describe "side effects" here.  There aren't any?  Well, just delete
; this entry.
;
; RESTRICTIONS:
; Describe any "restrictions" here.  Delete this section if there are
; no important restrictions.
;
; PROCEDURE:
; You can describe the foobar superfloatation method being used here.
; You might not need this section for your routine.
;
; EXAMPLE:
; Please provide a simple example here. An example from the
; DIALOG_PICKFILE documentation is shown below. Please try to
; include examples that do not rely on variables or data files
; that are not defined in the example code. Your example should
; execute properly if typed in at the IDL command line with no
; other preparation.
;
;       Create a DIALOG_PICKFILE dialog that lets users select only
;       files with the extension `pro'. Use the `Select File to Read'
;       title and store the name of the selected file in the variable
;       file. Enter:
;
;       file = DIALOG_PICKFILE(/READ, FILTER = '*.pro')
;
; MODIFICATION HISTORY:
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

function load_nc,lam, materials,c_mat
	;carica gli indici di rifrazione. c_mat va passato esplicitamente se c'e'.
	c_flag=0
	if n_elements(c_mat) ne 0 then c_flag=n_elements(c_mat)
	nm=n_elements(materials)
	nl=n_elements(lam)
	nc=complexarr(nm+1+c_flag,nl)
	vac=complexarr(nl)+1	;il primo strato e' il vuoto
	nc[0,*]=vac
	;carica gli indici dei materiali dello specchio bare
	;i materiali vanno nelle ultime colonne
	;i indica il materiale
	for i= 0,nm-1 do begin
		;print,i
		ind=IMD_NK(materials[i],lam)
		nc[i+1+c_flag,*]=ind
	endfor
	if c_flag ne 0 then nc[1,*]=IMD_NK(c_mat,lam)
	return,nc
end

function opt_Rifle,th, lam,materials,z,sigma,E_range,c_mat,t_points=t_points,t_range=t_range
;trova il massimo con il raster scan

	if n_elements(t_range) eq 0 then t_range=[20.,270.]
	if n_elements(n_points) eq 0 then t_points=100
	t_step=(t_range[1]-t_range[0])/(t_points-1)
	t_vec=t_range[0]+t_step*indgen(t_points)
	if n_elements(c_mat) eq 0 then c_mat='a-C'

	;find indexes for E_range, define R_bare2
	en=12398.425/lam
	if n_elements(e_range) eq 0 then begin
		minind=0
		maxind=n_elements(en)-1
	endif else begin
		minind=fix(total(en lt E_range[0])-1)
		maxind=fix(total(en lt E_range[1]))
	endelse

	R_bare=Rifle(th, lam[minind:maxind],materials,z,sig)

	;inizia il ciclo e ottimizza la fom per ogni angInd
	bestTVec=fltarr(n_elements(th))
	bestR=fltarr(n_elements(th),n_elements(lam))
	for angInd=0,n_elements(th)-1 do begin
		best_fom=0
		best_t=100.
		for i=0,t_points-1 do begin
			R_coated=Rifle(th[angInd], lam[minind:maxind],materials,z,sig,t_vec[i],c_mat)
			fom=total((R_coated^2-R_bare[angInd,*]^2)/R_bare[angInd,*]^2)
			if fom gt best_fom then begin
				best_fom=fom
				best_t=t_vec[i]
			endif
			;print,fom
		end
		bestTVec[angInd]=best_t
		bestR[angInd,*]=Rifle(th[angInd], lam,materials,z,sig,best_t,c_mat)
	end
	print, bestTvec
	return,bestR
end




