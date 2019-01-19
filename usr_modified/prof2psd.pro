;+
; NAME:
;
;        PROF2PSD
;
; PURPOSE:
;
;        Function to compute the power-spectral-density function from
;        the profile data.
;
; CATEGORY:
;
;        Topographic analysis
;
; CALLING SEQUENCE:
;
;        S=PROF2PSD(X,Y,F=F)
; 
; INPUTS:
;
;        X - 1D array of (equally-spaced) lengths.
;
;        Y - 1D array of heights.
;
; OUTPUTS:
;
;        F - 1D array of spatial frequencies, in units of 1/[X].
;
;        S - 1D array of PSD values, in units of [Y]^3.
;
; KEYWORD PARAMETERS:
;
;        POSITIVE_ONLY - Set to compute the psd function for positive
;                        frequencies only.
;
;        RANGE - 2-element array specifying the min and max spatial
;                frequencies to be considered. Default is from
;                1/(length) to 1/(2*interval) (i.e., the Nyquist
;                frequency), where length is the length of the scan,
;                and interval is the spacing between points.
;
;        ZERO_PAD - Set this to an integer specifying the number of
;                   zero-height points to add on either side of the
;                   profile data.
;
;        HANNING - Set this to use a Hanning window function.
;
;        KAISER - Set this to use a Kaiser-Bessel window function
;
; RESTRICTIONS:
;
;        The X values must be equally spaced.
;    
; PROCEDURE
;
;       S=Length*ABS(FFT(Y*Window),-1)^2
; 
;       Where Length is as described above, and Window is the value of
;       the optional window function (Hanning or Kaiser-Bessel).
;
; MODIFICATION HISTORY:
;
;      David L. Windt, Bell Laboratories, May 1997
;      windt@bell-labs.com
;      
; 2013/07/09 V. Cotroneo: renamed HANNING flag to HANN, to avoid name conflict.
; IDL was interpreting Hanning(1500) as indicization of a variable rather
; than routine calling. Could have been probably solved with some fancy compiler
; option (using square brackets only for array indicization).
;
;-

function prof2psd,x,y,f=f, $
                  range=range, $
                  positive_only=positive_only, $
                  zero_pad=zero_pad, $
                  hanning=hann,kaiser=kaiser

; function to calculate the power-spectral-density from the profile.

n_pts=n_elements(x)             ; number of points.
if n_pts le 1 then message,'Must have at least 2 points.'

if n_elements(zero_pad) gt 0 then begin
    ;; compute spacing between X points, assuming
    ;; all points are equally-spaced:
    xx=findgen(2*zero_pad+n_pts)*(x(1)-x(0))
    yy=xx*0
    yy(zero_pad)=y
endif else begin
    xx=x
    yy=y
endelse

window=yy*0+1.
if keyword_set(hann) then window=hanning(n_elements(yy))
if keyword_set(kaiser) then window=kaiser_bessel(n_elements(yy))

length=max(xx)-min(xx)            ; total scan length.
s=length*abs(fft(yy*window,-1)^2) ; psd function, w/ spectral window.
s=s(1:(n_pts/2+1*(n_pts mod 2))) ; take an odd number of points.
n_ps=n_elements(s)              ; number of psd points.
interval=length/(n_pts-1)       ; sampling interval.
f_min=1./length                 ; minimum spatial frequency.
f_max=1./(2.*interval)          ; maximum (Nyquist) spatial frequency.
f=findgen(n_ps)/(n_ps-1)*(f_max-f_min)+f_min ; spatial frequencies.
if n_elements(range) eq 2 then begin ; only keep frequencies within range...
    roi=where((f le range(1)) and (f ge range(0)))
    f=f(roi)
    s=s(roi)
endif
if keyword_set(positive_only) eq 0 then begin ; only keep pos. frequencies...
    f=[-reverse(f),f]
    s=[reverse(s),s]
endif
return,s
end

