pro load_color_range, startindex, endindex,startcolor,endcolor,pmin=pmin,pmax=pmax
  ;load the interpolated colors between startcolor and endcolor in
  ;the palette index between startindex and endindex
  ;startcolor and endcolor 3dim rgb vectors.
  
  if startindex eq endindex then begin
    colorange=endcolor
  endif else begin
    colorange=congrid([[startcolor],[endcolor]],3,abs(endindex-startindex)+1,/interp,/minus_one)
  endelse

  if n_elements (pmin) eq 0 then pmin=0
  if n_elements (pmax) eq 0 then pmax= endindex

  tvlct,colorange[0,((pmin-startindex)>0):(pmax-startindex)<(endindex-startindex)],$
  colorange[1,((pmin-startindex)>0):(pmax-startindex)<(endindex-startindex)],$
  colorange[2,((pmin-startindex)>0):(pmax-startindex)<(endindex-startindex)],startindex>pmin

end

pro colors_band3d, vmin, vmax, pmin, pmax, colors, zero=zero, bandsize=bandsize, $
	bandvalsize=bandvalsize,extracolors=ec,tek=tek,noreverse=noreverse,force=force

  if ~keyword_set(force) ne 0 then begin
      errmsg="The Colors_band3d routine is obsolete. Use function"+$
      "color_band_palette with /load option. e.g.: "+$
      "result=colors_band_palette(vmin,vmax,Colors,pmin=pmin,pmax=pmax,/load"+$
      "Otherwise, set the /force flag to use colors_band3d (at your risk!)."
      message,errmsg
  endif

;+
;Vincenzo Cotroneo - Brera Astronomical Observatory
;vincenzo.cotroneo@brera.inaf.it
;14 June 2008

;load a palette for the plot, using bands of colors to represent values between
;vmin e vmax. Uses the color indexes in palette between pmin and pmax.
;the zero of values is set as start of color band, positive tones inside each
;band are reversed to have darker colors on higher absolute values..
;--------------------------
;optional arguments:
;- colors: a matrix [ncolors,2,3] containing starting and ending rgb values for
;each band of colors
;(in format [[[rgbBand1start],[rgbBand1End]],...[[rgbBand1start],[rgbBand1End]]],
;with rgbBandxxxx 3-dim vector of rgb colors)
;- bandvalsize: number of values for each color band
;- bandsize: number of colors for each color band
;- /tek load the the default Tektronix 4115 colortable in the first 32 position of palette,
;using the tek_color command
;- extracolors: custom colors to be loaded. in the form [[paletteindex,r,g,b],[..],...,[..]]
;- zero: set the zero point (marked in white): 
;---------------------------
;todo improvements: 
;management of color bands if they are not enough to
;cover all the values when a binsize is given (forse fatto).
;---------------------------
;8/6/2010 added:
;option noreverse to not reverse the negative values.
;-

if !D.NAME eq 'WIN' then device,decomposed=0
npal=pmax-pmin+1
if n_elements(tek) ne 0 then tek_color
if n_elements (colors) eq 0 then	colors=[[[50,0,0],[255,0,0]],$
			[[0,50,0],[0,255,0]],$
			[[0,0,50],[0,0,255]],$
			[[50,50,0],[255,255,0]],$
			[[50,0,50],[255,0,255]],$
			[[0,50,50],[0,255,255]]]
ncol=n_elements(colors[0,0,*])


;find the index z0 corresponding to zero value
z0=bytscl([vmin,0,vmax], top=pmax-pmin)+pmin
z0=z0[1]
ncolperband=fix((npal-1)/(ncol-1))+1 ;number of color indexes
	;in palette for each color band in colors, if all colors are used.
	;Keep one more (ncol-1) then needed to fill positive and negative

if (n_elements(bandvalsize) ne 0 ) then begin
	zb=bytscl([vmin,bandvalsize,vmax],top=pmax-pmin)+pmin
	bandsize=zb[1]-z0
endif

if (n_elements(bandsize) ne 0 ) then begin
   if (bandsize lt ncolperband) then begin
   		print,"not enough colors to use bandsize/bandvalsize:"

   		if n_elements(bandvalsize) ne 0 then begin
   			print, "bandsize= ", bandsize,$
   				" (calculated from bandvalsize=",bandvalsize,")"
   			print, "min val, max val, zero position=",vmin,vmax,z0
   		endif else begin
   			print, "bandsize= ", bandsize
   		endelse
   		print, "ncolors= ",ncol
   		print, "palette size= ",npal
   		print, "minimum bandsize= ", ncolperband
   		print, "-----------------"
   		ncolperband=fix(npal/(ncol-1))
   	endif else begin
		ncolperband=bandsize
	endelse
endif

j=0
;j index of color in colors, i position in palette
;fill the part of the palette corresponding to positive values
for i = z0+1,pmax,ncolperband do begin
	load_color_range,i,i+ncolperband-1,$
	colors[*,1,j],colors[*,0,j],pmax=pmax
	j=j+1
endfor
tvlct,255,255,255,z0 ;use white for zero value of gain
;negative values
for i=z0-1,pmin,-ncolperband do begin
	load_color_range,i-ncolperband+1,i,colors[*,0,j],colors[*,1,j],pmin=pmin
	j=j+1
endfor

if n_elements(ec) ne 0 then begin
	s=size(ec)
	s=s[2]
	for i =0,s-1 do begin
		tvlct,ec[0,i],ec[1,i],ec[2,i],ec[3,i]
	endfor
endif

end


;test

;initialize to a totally black palette
for i=0,255 do tvlct,0,0,0,i
;definisce valori: min(a)=-10 max(a)=50
a=[-20,-10,0,11,21,33,49,50]

colors_band3d,min(a),max(a),101,200,bandvalsize=20
;
;useful commands for checking:
;----------------------
;cindex  ;show colors and index in palette
;----------------------
;tvlct,rVec,gVec,bVec,/get  ;retrieve palette color indeces
;print,"Index ","R     ","G    ","B    " & print,transpose([[findgen(n_elements(rvec))],[rvec],[gvec],[bvec]])
;;RESULT:
;Index R     G    B    
;     0.000000     0.000000     0.000000     0.000000
;      1.00000     0.000000     0.000000     0.000000
;      ..          ..           ..           ..
;      100.000     0.000000     0.000000     0.000000
;      101.000      57.0000      57.0000     0.000000
;      102.000      64.0000      64.0000     0.000000
;      ..          ..           ..           ..
;      127.000      247.000      247.000     0.000000
;      128.000      255.000      255.000     0.000000
;      129.000      255.000      255.000      255.000
;      130.000      255.000     0.000000     0.000000
;      131.000      247.000     0.000000     0.000000
;      ..          ..           ..           ..
;      157.000      57.0000     0.000000     0.000000
;      158.000      50.0000     0.000000     0.000000
;      159.000     0.000000      255.000     0.000000
;      160.000     0.000000      247.000     0.000000
;      ..          ..           ..           ..
;      186.000     0.000000      57.0000     0.000000
;      187.000     0.000000      50.0000     0.000000
;      188.000     0.000000     0.000000      255.000
;      189.000     0.000000     0.000000      247.000
;      ..          ..           ..           ..      
;      199.000     0.000000     0.000000      174.000
;      200.000     0.000000     0.000000      167.000
;      201.000     0.000000     0.000000     0.000000
;      ..          ..           ..           ..
;      255.000     0.000000     0.000000     0.000000



end