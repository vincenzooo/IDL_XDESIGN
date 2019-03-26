function LinesMinDist,P1,V1,P2,V2,points=points,coefficients=t1t2,mindist2=mindist2
;
;Minimum distance between two straight lines 
;  l1: P1+V1*t_1
;  l2: P2+V2*t_2 
;
; esprimendo due rette sghembe come R1=A+Bt e R2=C+Dt (A,B,C,D vettori, t parametro),
;la distanza minima è q=(A-C)-(A-C)B/|B|*B/|B|-(A-C)D/|D|*D/|D|.
;Nel nostro caso |B|=|D|=1 per costruzione, quindi:
;q=(A-C)-(A-C)B B-(A-C)D D

;test if the two lines are coplanar

A=P1
C=P2
;questo metodo alternativo da formula su wikipedia sembra funzionare ugualmente
B=v1/sqrt(total(v1^2))
D=v2/sqrt(total(v2^2))
Q=(A-C)-total((A-C)*B) * B-total((A-C)*D)*D
mindist2=sqrt(total((Q)^2))
;print, "minima distanza tra gli assi:",mindist
;print, "vettore minima distanza:",Q

;find the parameters by solving A+B*t_1+Q+D*t_2=C
matrix=[[total(v1^2),-total(v2*v1)],[total(v1*v2),-total(v2^2)]]
vec=[total((c-a)*v1),total((c-a)*v2)]
if array_equal(vec,vec*0) then t1t2=[0,0] else t1t2=cramer(matrix,vec)

t1=t1t2[0]
t2=t1t2[1]
pA=A+t1*V1
pC=C+t2*V2
points=[pA,pC]
return,sqrt(total((pa-pc)^2))


end


print
print,'------------'
print,'test 1:'
p1=[0,0,0]
v1=[0,0,2.]
p2=[1,1,0]
v2=[1,-1,0]
print,'P1=',p1
print,'V1=',v1
print,'P2=',p2
print,'V2=',v2
print,'-results-'
print,linesminDist(p1,v1,p2,v2,points=p,coeff=c,mindist2=m2)
print,m2
print,'points:'
print,p
print,'t1t2:',c
print
print,'------------'

print
print,'------------'
print,'test 2:'
p1=[1.,0,-2]
v1=[0,1.,1]
p2=[0,1.,1]
v2=[1.,-1,1]
print,'P1=',p1
print,'V1=',v1
print,'P2=',p2
print,'V2=',v2
print,'-results-'
print,linesminDist(p1,v1,p2,v2,points=p,coeff=c,mindist2=m2)
print,m2
print,'points:'
print,p
print,'t1t2:',c

print
print,'------------'
print,'test 2:'
p1=[0.,3,-3]
v1=[1,-5.,0]
p2=[-1,2.,0]
v2=[0,0,1.]
print,'P1=',p1
print,'V1=',v1
print,'P2=',p2
print,'V2=',v2
print,'-results-'
print,linesminDist(p1,v1,p2,v2,points=p,coeff=c,mindist2=m2)
print,m2
print,'points:'
print,p
print,'t1t2:',c

end