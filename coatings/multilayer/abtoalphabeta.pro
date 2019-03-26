function abtoalphabeta,a,b,c,N,alpha=alpha,beta=beta
    d=thicknesspl(a,b,c,N)
    alphabeta=d1dntoalphabeta(d[0],d[N-1],c)
    alpha=alphabeta[0]
    beta=alphabeta[1]
    return,alphabeta
end