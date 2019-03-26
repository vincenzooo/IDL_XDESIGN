pro changeN, a,b,c, nold, nnew
	;return the new a,b,c
	;passing from old number of layers to a new one
	;with same dmin e dmax
	k=float(nold-1)/(nnew-1)

	a=a/k^c
	b=(b+1)/k-1

end