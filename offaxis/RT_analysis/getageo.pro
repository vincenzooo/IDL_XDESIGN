function getAgeo, folder
;read the geometric area calculated by the program traie
;as the telescope area on entrance pupil without walls

file=folder+path_Sep()+"reportRayTrace19.txt"
varname="geometrical area for raytracing"
area=readNamelistVar(file,varname,separator=":")
ageo=float(area)

return, ageo
end