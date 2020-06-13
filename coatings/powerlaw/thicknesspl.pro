function thicknessPL, a , b, c, Nbil, gamma,iminus=iminus
	;return the sequence of thickness for a power-law multilayer (Joensen):
	;d=a/(b+i)^c, with parameters a,b,c and i index from top.
	;if gamma is provided give sequence of layers (h-l) [Nbil*2]
	;if not provided, give single power law [nbil].
	;if iminus is set give the thickness sequence with the sign of i
	;changed.

	i=findgen(Nbil)+1
	if n_elements(iminus) ne 0 then i=-i

	if n_elements(gamma) ne 0 then begin
		nl=nbil*2
		t1= gamma*a/(b+i)^c
		t2=(1-gamma)*a/(b+i)^c
		return, reform(transpose([[t1],[t2]]),nl,1)
	endif else begin
		return, a/(b+i)^c
	endelse
end