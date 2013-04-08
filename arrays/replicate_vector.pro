function replicate_vector,vector,nelements
;repeat the vector to fill nelements

if nelements lt 1 then message,'Invalid value for NELEMENTS argument'
n=n_elements(vector)
nrep=fix(nelements/n)
tmp=rebin([vector],n,nrep+1) ;square bracket is needed if it is a one element
tmp=reform(tmp,n*(nrep+1))
return,tmp[0:nelements-1]

end