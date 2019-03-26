pro angleDistSetError,nbins=nbins,tstep=tstep
		print, "only one between nbins and thetaStep can be set."
		if n_elements(nbins) eq 0 then print, "nbins not defined " $
		else print, "nbins: ",nbins
		if n_elements(tstep) eq 0 then print, "thetaStep not defined " $
		else print, "thetaStep: ",tstep
		stop
end    

function primitiva,alpha,theta,a1x
return, sqrt(theta^2-(alpha-a1x)^2)+a1x*atan((a1x-alpha)/sqrt(theta^2-(alpha-a1x)^2))
;      if a1x lt alpha then begin
;        return,-sqrt(theta^2-(alpha-a1x)^2)+a1x*atan((a1x-alpha)/sqrt(theta^2-(alpha-a1x)^2))
;      endif else begin
;        return,sqrt(theta^2-(alpha-a1x)^2)+a1x*atan((a1x-alpha)/sqrt(theta^2-(alpha-a1x)^2))
;      endelse
end

function impAngleDistr,alpha,theta,a1x

	;given the shell slope <alpha> and the off-axis angle <theta>
	;and the number of bins or step for incidence angle
	;return the distribution for the incidence angles a1x.
	;uses formula by Daniele.
	;if half is set return the first half only ; not implemented, I don't know if
	;is useful
  
  if theta ge alpha then message,'Attenzione, il programma non è ancora pronto per theta>alpha'
  nbins=n_elements(a1x)
  distr=fltarr(nbins)
  
  startind=min(where(a1x gt alpha-theta))
  endind=max(where(a1x lt alpha+theta))
  distr[startind]=-sqrt(theta^2-(alpha-a1x[startind+1])^2)+a1x[startind+1]*atan((a1x[startind+1]-alpha)$
      /sqrt(theta^2-(alpha-a1x[startind+1])^2))+!PI/2*(alpha-theta)
  a2=2.*alpha-a1x[endind]  ;2.*alpha-a1x[nbins-1]
;  distr[nbins-1]=-sqrt(theta^2-(a2-alpha)^2)+a2*atan((a2-alpha)$
;      /sqrt(theta^2-(alpha-a2)^2))+!PI/2*(alpha-theta)
  distr[endind]=-sqrt(theta^2-(a2-alpha)^2)+a2*atan((a2-alpha)$
      /sqrt(theta^2-(alpha-a2)^2))+!PI/2*(alpha-theta)
  for i =startind,endind-1 do begin  ;nbins-2 do begin
    if ((a1x[i] ge alpha-theta)and(a1x[i] le alpha+theta)) then begin
      if a1x[i] lt alpha then begin
        distr[i]=primitiva(alpha,theta,a1x[i+1])-primitiva(alpha,theta,a1x[i])
      endif else begin
        distr[i]=-primitiva(alpha,theta,2*alpha-a1x[i+1])+primitiva(alpha,theta,2*alpha-a1x[i])
      endelse
       ;distr[i]=primitiva(alpha,theta,a1x[i+1])-primitiva(alpha,theta,a1x[i])
    endif
  endfor
  norm=1./(!PI/2*alpha-theta)
	return,norm*distr/2
end

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
plot,a1x+tstep/2,d,psym=10
print,total(d)
end