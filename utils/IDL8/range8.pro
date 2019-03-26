function range8, x,size=size

min=lmin(x)
max=lmax(x)

if keyword_set(size) ne 0 then return,max-min
return,[min,max]
end