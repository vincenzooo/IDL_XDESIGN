function d1dNtoAlphabeta,d1,dN,c,alpha=alpha,beta=beta

beta=1/((d1/dn)^(1/c)-1)
alpha=d1*beta^c

return,[alpha,beta]

end
