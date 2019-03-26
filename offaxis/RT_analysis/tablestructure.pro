pro tableStructure,filename,outfile
;make a latex table from a structure file (shellStruct.txt)
;write the result on <outfile>

	readcol,filename, Nshell,Dmax,Dmid,Dmin,thickness,Angle,Area,peso,skip=1

	tmpArr=[[Nshell],[Dmax],[Dmid],[Dmin],[thickness],[Angle],[Area],[peso]]
	nlines=n_elements(nshell)

	get_lun,nf
	openw,nf,outfile
	printf,nf,latexTableLine(['Nshell','Dmax(mm)','Dmid(mm)','Dmin(mm)',$
		'Thickness(mm)','Angle(rad)','Area(cm^2)','Mass(kg)'],$
		format='(a,a,a,a,a,a,a,a)')
	for i=0,nlines-1 do begin
		printf,nf,latexTableLine(reform(tmpArr[i,*]),$
			format='(i3,f8.3,f8.3,f8.3,f6.3,f8.5,f8.3,f8.3)')
	endfor
	free_lun,nf
end


filename='D:\work\traie7\hexitSat_2009\F10D394ff010_thsx\shellStruct.txt'
outfile='shellStruct.tex'
tableStructure,filename,outfile

end