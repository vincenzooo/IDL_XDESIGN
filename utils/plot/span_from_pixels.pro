function span_from_pixels,p,n=n,vector=v
; From positions of pixel centers p returns a range from side to side. 
; Useful to adjust plot extent in 2d plots or binned 1d plots.
; In alternative, p can be provided as range and number of pixels.
; 
; VECTOR: output argument for a vector of ticks with correct
;   extremes and same number of elements as p
;   
; 2020/12/29 translated from python 

if n_elements(n) eq 0 then n = n_elements(p)

dx=(max(p)-min(p))/(n-1)
s = [min(p)-dx/2,max(p)+dx/2]
if arg_present(v) then v = vector(s[0],s[1],n_elements(p))
return, s

end

print, span_from_pixels([0.,3.],n=4) ;[-0.5,3.5]
print, span_from_pixels([0.,2.],n=3) ;[-0.5,2.5]
print, span_from_pixels([0.,1.,2.]) ;[-0.5,2.5]
print, span_from_pixels([0,0.5,1,1.5,2.]) ;[-0.25,2.25]

end