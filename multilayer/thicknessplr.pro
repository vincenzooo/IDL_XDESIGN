function thicknessPLR, alfa, beta, c, Nbil,gamma
	;return the sequence of thicknesses calculated
	;by using the rescaled power-law

	x=findgen(Nbil)/(Nbil-1)
	dspacing=alfa/(beta+x)^c
	if n_elements(gamma) eq 0 then return, dspacing else $
		return,reform(transpose([[gamma*dspacing],[(1-gamma)*dspacing]]),2*nbil,1)
end
