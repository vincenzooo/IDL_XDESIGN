function extractFoV,folder,vfile=vFile,angle=angle
;if vignettingFile is not given, launch extractVignetting to create it 
;(not implemented).
;Extract and plot the FOV as a function of energy from fortran ray-tracing results.

readcol,vFile,angle,ener,aeff,vignetting,areaFraction,nPhotons,Error
nangles=len_blocks(angle,nblocks=nener)

angle=angle[0:nangles-1]
fovVector=fltarr(nener) ;vettore FOV in funzione dell'energia
for i =0,nener-1 do begin
  en=ener[i*nangles:(i+1)*nangles-1]
  vign=vignetting[i*nangles:(i+1)*nangles-1]
  maxindex=where(vign ge 0.5,c,complement=notInFOV)
  if c eq -1 then message, "extractFOV: No vignetting value greater than 0.5!"
  if c eq nangles then notInFov=nangles else notInFOV=notInFOV[0]
  fovVector[i]=angle[notInFov-1]
endfor

return, fovvector

end

vfile='E:\work\workOA\traie8\NHXMphB_mlArea\baseline2phB_vig\baseline2phB_vig_vig.dat'
vign=extractFoV(vfile=vFile,angle=angle)
plot,angle,vign
end