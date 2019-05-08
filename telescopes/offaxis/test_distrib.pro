;2019/04/03 test to recover and sort old distribution routines
cleanup
setstandarddisplay

alpha=0.0037
theta=6./60.*!PI/180.
tStep=5./206265.
x0=max([0,alpha-theta])
x1=alpha+theta
nbins=fix((x1-x0)/(tStep))+1
a1x=vector(alpha-theta,alpha+theta,nbins+1)
a1x=a1x[0:nbins-1]
d=impangledistr(alpha,theta,a1x)

; multiplot, [1,3], gap=0.1

plot,a1x+tstep/2,d,psym=10,title='imapangledistr'
print,total(d)

window,/free
oad=oaAngleDistr(alpha,theta,locations=a1x,nbins=nb,thetaStep=tstep)
;multiplot

plot,a1x+tstep/2,oad,psym=10,title='oaangledistr'

dm=distributionMatrix([alpha],a1x,locations=locations)


end