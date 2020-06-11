function alphabetaToAB, alfa,beta,c, Nbil,a=a,b=b
	;convert from the rescaled power-law (Cotroneo) to the conventional one (Joensen)

	b=(nbil-1)*beta-1
	a=alfa*(nbil-1)^c
	return, [a,b]
end