function sF,points,residuals=residuals,toll=toll,guess=guess,_extra=extra,$
                   amoeba=am,weight=weight,fom=fom
                   
func='_lssq'
p0=[10d,15.d,1000.d,900d]
result=protozoo(function_name=func,p0=p0)

print,result

result=amoeba(toll,function_name=fom,p0=guess,$
scale=guess,nmax=500,simplex=final,FUNCTION_VALUE=fom)


end

