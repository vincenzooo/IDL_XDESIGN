pro angleDistSetError,nbins=nbins,tstep=tstep
		print, "only one between nbins and thetaStep can be set."
		if n_elements(nbins) eq 0 then print, "nbins not defined " $
		else print, "nbins: ",nbins
		if n_elements(tstep) eq 0 then print, "thetaStep not defined " $
		else print, "thetaStep: ",tstep
		stop
end    


function oaAngleDistr,alpha,theta,locations=a1x,nbins=nb,thetaStep=ts,half=half
	;given the shell slope <alpha> and the off-axis angle <theta>
	;and the number of bins or step for incidence angle
	;return the distribution for the incidence angles a1x.
	;uses formula by Daniele.
	;if half is set return the first half only ; not implemented, I don't know if
	;is useful


	if n_elements(half) eq 0 then half=0
	n1bins=n_elements(nb)
	n2steps=n_elements(tS)
	;n3vec=n_elements(a1x)
	if n1bins eq 0 && n2steps eq 0 then angleDistSetError,nbins=nb,tstep=ts
	if n1bins ne 0 && n2steps ne 0 then angleDistSetError,nbins=nb,tstep=ts

	if theta eq 0 then begin
		print,"impact angle distribution calculation:"
		print,"theta=0, return monodimensional vectors"
		a1x=[alpha]
		return,[1.]
	endif

	if n1bins ne 0 then begin
		;n1bins valido, nstep non definito
		nbins=nb
		if nbins eq 1 then begin
			print,"impact angle distribution calculation:"
			print,"nbins=1, return monodimensional vectors"
			a1x=[alpha]
			return,[1.]
		endif
		a1x=vector(alpha-theta,alpha+theta,nbins+2)
		a1x=a1x[1:nbins]
	endif else begin
		tStep=ts
		if tStep gt 2*theta then begin
			print,"impact angle distribution calculation:"
			print,"thetaStep (",tStep,") larget than delta theta (",2*theta,"),"
			print,"return monodimensional vectors"
			a1x=[alpha]
			return,[1.]
		endif
		nbins=fix(2*theta/tStep)
		a1x=vector(alpha-theta+tStep,alpha+theta-tStep,nbins)
	endelse

	deltax=a1x[1]-a1x[0]
	normalization=alpha*!PI-2*theta
	quadrant1=deltax*a1x/sqrt(theta^2-(alpha-a1x)^2)/normalization
	quadrant2=deltax*(2*alpha-a1x)/sqrt(theta^2-(-alpha+a1x)^2)/normalization
	q1index=where(a1x lt alpha,complement=q2index)
	distr=fltarr(n_elements(a1x))
	distr[q1index]=quadrant1[q1index]
	distr[q2index]=quadrant2[q2index]
	return,distr*normalization
end