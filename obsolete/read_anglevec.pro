function read_anglevec,filename
;generate a vector of off-axis angles in radians from the fortran namelist
;in a file of settings for the offAxis ray-tracing program

MESSAGE, 'The routine read_anglevec is obsolete, please replace it with getOAangle'

;get_lun,nf
;openr,nf,filename
;line=''
;; Loop until EOF is found:
;WHILE ~ EOF(nf) DO BEGIN
;   READF, nf, line
;   s=strsplit(STRLOWCASE(line),'=',/extract)
;   ss=strtrim(s[0])
;   if (ss eq 'ang0arcmin') then ang0=float(s[1])
;   if (ss eq 'ang1arcmin') then ang1=float(s[1])
;   if (ss eq 'pasa') then pasa=float(s[1])
;ENDWHILE
;na=1
;if (pasa ne 0) then na=fix((ang1-ang0)/pasa)+1 ; number of angular steps
;angvec=findgen(na)*pasa+ang0
;angvec=angvec*!PI/(60*180)
;free_lun,nf
;
;return,angvec
end
