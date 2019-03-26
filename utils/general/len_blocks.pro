function len_blocks,vector,equal=equal,nblocks=nblocks
;16/04/2009 name of the function changed from <countBlocks> to <len_blocks>

;given a vector return the lenght of a block,
;assuming that a block is repeated more times (return in <nblocks>
;the number of blocks).
;(e.g. [1,2,3,1,2,3] -> return 3, nblocks=2 )
;if equal is set, consider a block made of equal values
;(e.g. [1,1,1,2,2,2,3,3,3,4,4,4] -> return 3, nblocks=4 )

if n_elements(equal) eq 0 then equal=0
equalTo1st=where(vector eq vector[0])

if equal eq 0 then begin
	if n_elements(equalTo1st) eq 1 then begin
		nblocks=1
		return,n_elements(vector)
	endif
	nblocks=n_elements(vector)/equalTo1st[1]
	return,equalTo1st[1]
endif else begin
	fd=where((vector eq vector[0]) eq 0)
	nblocks=n_elements(vector)/fd[0]
	return,fd[0]
endelse

end