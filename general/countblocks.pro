function countblocks,vector,equal=equal,nblocks=nblocks
;16/04/2009 name of the function changed from "countBlocks" to "len_blocks"

MESSAGE, 'The function countBlocks is obsolete, please replace it with len_blocks'

;given a vector return the lenght of a block,
;assuming that a block is repeated more times (return in <nblocks>
;the number of blocks).
;(e.g. [1,2,3,1,2,3] -> return 3, nblocks=2 )
;if equal is set, consider a block made of equal values
;(e.g. [1,1,1,2,2,2,3,3,3,4,4,4] -> return 3, nblocks=3 )

if n_elements(equal) eq 0 then equal=0
chk=where(vector eq vector[0])

if equal eq 0 then begin
	nblocks=n_elements(vector)/chk[1]
	return,chk[1]
endif else begin
	fd=where((vector eq vector[0]) eq 0)
	nblocks=n_elements(vector)/fd[0]
	return,fd[0]
endelse

end