function make_band, ntones,startcolor,endcolor
  ;build a single band of ntones colors with a gradient from startcolor to endcolor
  if ntones le 0 then message, "ntones must be > 0!"
  return, transpose(congrid([[startcolor],[endcolor]],3,ntones,/interp,/minus_one))
end

function colors_band_palette, Vmin, Vmax, Colors, pmin=pmin, pmax=pmax,$
         zero=zero, izeroCT=izeroCT,bandsize=bandsize, bandvalsize=bandvalsize,$
         extracolors=ec,tek=tek,noreverse=noreverse,load=load,currentCT=currentCT,$
         nozeropoint=nozeropoint
  
    ;+
    ; NAME:
    ; colors_band_palette
    ;
    ; PURPOSE:
    ; This function builds a palette made of bands with gradient of colors in correspondence of
    ;   a given range of values (e.g. can be used to generate a colorbar). Values that are not
    ; assigned are kept unchanged from the current palette. 
    ; The resulting palette is in a format (basically a Nx3 array) that can be used with TVLCT 
    ; to load it in direct graphic palette and probably to initialize a IDlgrPalette (non testato)
    ; in object graphics.
    ;
    ; The bands are built in a way such that a given reference value (default=0) 
    ;   is on the separation between different bands.
    ; Normally (unless /noreverse is set) the gradient is reversed for values lower 
    ;   than the zero level (this leads to darker colors for higher absolute values).
    ;
    ; CATEGORY:
    ; Plot
    ;
    ; CALLING SEQUENCE:
    ; Result = COLORS_BAND_PALETTE (Vmin, Vmax,Colors)
    ;
    ; INPUTS:
    ; Vmin, Vmax: The minimum and maximum values to be plotted (used to calculate the position of the reference level). Typically use min and max
    ; of data to plot to plot full scale.
    ;
    ; OPTIONAL INPUTS:
    ; Colors: a matrix [ncolors,2,3] containing starting and ending rgb values for
    ;         each band of colors (with format [[[rgbBand1start],[rgbBand1End]],...[[rgbBand1start],[rgbBand1End]]],
    ;         with rgbBandxxxx 3-dim vector of rgb colors).
    ;         e.g.: to set uniform (no gradient) bands set the same values for starting and ending 
    ;         colors.
    ;         if missing a default palette with tones of R,G,B,Yellow,Magenta,Cyan is used.
    ; 
    ; KEYWORD PARAMETERS:
    ; Pmin, Pmax:   The minimum and maximum color indexes in palette to be replaced.
    ; Bandvalsize:  Number of values for each color band.
    ; Bandsize:     Number of colors for each color band.
    ; /Tek:         Load the the default Tektronix 4115 colortable in the first 32 position of palette,
    ;               using the tek_color command.
    ; Extracolors:  Custom colors to be loaded. in the format [[paletteindex,r,g,b],[..],...,[..]].
    ; Zero:         The value used for the zero point (white).
    ; izeroCT:       Give as output the color table index corresponding to the zero point.
    ; /Load:        Load the result in the current palette.
    ; CurrentCT:    Return the current (before call) color table.
    ; NoZeroPoint:  If set, create the palette from min to max without setting the zero point.
    ;
    ; OUTPUTS:
    ; This function returns a palette V as a n-by-3 array of integers, where V[*,0], V[*,1], V[*,2]
    ; are respectively, the R, G and B values. 
    ; If /load is set, the color table is also loaded in the current palette.
    ;
    ; SIDE EFFECTS:
    ; If /Load is selected, the current color table is changed.
    ;
    ; EXAMPLE (see more and results at the end of the .pro file):
    ; To define a palette from a range of values (between -20 and 50) with default zero level=0
    ; and a bandwidth in values of 20. (this results in 4 color bands, see test at the end of the 
    ; .pro file for the resulting values):
    ;
    ; for i=0,255 do tvlct,0,0,0,i  ;completely black palette
    ; values=[-20,-10,0,11,21,33,49,50] ;to set zero. Only min and max matter: [-20,50]
    ; ct1=colors_band_palette(min(values),max(values),pmin=101,pmax=200,bandvalsize=20,/load)
    ;; ---- check ----
    ; print,transpose([[findgen(!D.TABLE_SIZE)],[ct1]]) ;print: index, R, G, B
    ; cindex  ;if David Fanning routine is present, show colors and index in palette.
    ;
    ; MODIFICATION HISTORY:
    ; Written by: 
    ; Vincenzo Cotroneo - Brera Astronomical Observatory, 14 June 2008
    ; vincenzo.cotroneo@brera.inaf.it
    ;---------------------------
    ;2019/12/03 default zero is now 0 only if inside vmin and vmax (it was giving error), otherwise average of vmin vmax is used. Test works.
    ;todo improvements: 
    ; - more extensive testing, bandsize, bandvalsize, etc..
    ; - management of color bands if they are not enough to
    ;cover all the values when a binsize is given (forse fatto).
    ; - usare tutti i colori se si seleziona nozero
    ;---------------------------
    ;-
    
    TVLCT, Palette,/GET ;load the current color table
    currentCT=Palette
    if !D.NAME eq 'WIN' then device,decomposed=0
    if n_elements (pmin) eq 0 then pmin=1  ;keep the first value for the background and
    if n_elements (pmax) eq 0 then pmax= !D.TABLE_SIZE-2  ;the last for the foreground
    npal=pmax-pmin+1
    if keyword_set(tek) then tek_color
    if n_elements (colors) eq 0 then	colors=[[[50,0,0],[255,0,0]],$
    			[[0,50,0],[0,255,0]],$
    			[[0,0,50],[0,0,255]],$
    			[[50,50,0],[255,255,0]],$
    			[[50,0,50],[255,0,255]],$
    			[[0,50,50],[0,255,255]]]
    ncol=n_elements(colors[0,0,*])
    
    ;find the index izeroCT corresponding to zero value
    ;default is if 0 is between min and max, it is used,
    ;  otherwise use average.
    if n_elements(zero) ne 0 then zeroval=zero $
    else begin
      if vmin lt 0 and vmax gt 0 then zeroval=0 else zeroval=(vmin+vmax)/2
    endelse
    
    if keyword_set(nozeropoint) then begin 
      izeroCT = pmin-1 
    endif else begin
      tmp=bytscl([vmin,zeroval,vmax], top=pmax-pmin)+pmin
      if tmp[0] ne pmin then message,"Error in resampling Values to Palette: Vmin must correspond to Pmin",/info
      if tmp[2] ne pmax then message,"Error in resampling Values to Palette: Vmax must correspond to Pmax",/info
      izeroCT=tmp[1]
    endelse
    
    if keyword_set(nozeropoint) then begin
      ncolperband=fix((npal-1)/(ncol))+1
    endif else begin
      ncolperband=fix((npal-1)/(ncol-1))+1 ;number of color indexes
      	;in palette for each color band in colors, if all colors are used.
      	;Keep one more (ncol-1) than needed, to fill positive and negative.
    endelse
    
    if (n_elements(bandvalsize) ne 0 ) then begin
    	tmp=bytscl([0,bandvalsize,vmax-vmin],top=pmax-pmin)+pmin
    	bandsize=tmp[1]
    endif
    
    if (n_elements(bandsize) ne 0 ) then begin
       if (bandsize lt ncolperband) then begin
       		print,"not enough colors to use bandsize/bandvalsize:"
    
       		if n_elements(bandvalsize) ne 0 then begin
       			print, "bandsize= ", bandsize,$
       				" (calculated from bandvalsize=",bandvalsize,")"
       			print, "min val, max val, zero position=",vmin,vmax,izeroCT
       		endif else begin
       			print, "bandsize= ", bandsize
       		endelse
       		print, "ncolors= ",ncol
       		print, "palette size= ",npal
       		print, "minimum bandsize= ", ncolperband
       		print, "-----------------"
       		ncolperband=fix(npal/(ncol-1))
       	endif else begin
       	  ; it fails if bandvalsize e' troppo grande
    		  ncolperband=bandsize 
    	endelse
    endif
    ;
    ;if n_elements(info) ne 0 then begin
    ;  print, "From arguments passed:"
    ;  print, "Number of bands: ",ncol
    ;  print, "------------------" 
    ;  print, "Number of colors in palette: ",
    ;  print, "Selected palette range: ",Pmin,"-",pmax
    ;  if n_elements(bandsize) ne 0 then print, $
    ;    "Minimum number of colors for a bandsize of ",bandsize," tones: ",fix((vmax-izeroCT)
    ;endif
    
    j=0
    ;j index of color in colors, i position in palette
    ;fill the part of the palette corresponding to positive values
    for i = izeroCT+1,pmax,ncolperband do begin
      ;load_color_range,i,i+ncolperband-1,colors[*,1,j],colors[*,0,j],pmax=pmax
      tmpBand=make_band(ncolperband,[colors[*,0,j]],[colors[*,1,j]])
      palette[i:(i+ncolperband-1)<pmax,*]=tmpBand[0:(ncolperBand-1)<(pmax-i),*]
    	j=j+1
    endfor
    if ~keyword_set(nozeropoint) then begin
      palette[izeroCT,*]=transpose([255,255,255]) ;use white for zero value of gain
      ;negative values
      for i=izeroCT-1,pmin,-ncolperband do begin
        tmpBand=make_band(ncolperband,[colors[*,0,j]],[colors[*,1,j]])  ;build as usual, load reversed if needed
        if n_elements(noreverse) ne 0 then begin 
          palette[(i-ncolperband+1)>pmin:i,*]=tmpBand[0:(ncolperBand-1)<(i-pmin),*]
        endif else begin
          palette[(i-ncolperband+1)>pmin:i,*]=reverse(tmpBand[0:(ncolperBand-1)<(i-pmin),*])
        endelse
        ;load_color_range,i-ncolperband+1,i,colors[*,0,j],colors[*,1,j],pmin=pmin
        j=j+1
      endfor
    endif
    if n_elements(ec) ne 0 then begin
      ecWork=transpose(ec)	
      s=size(ecWork)
    	len=s[1]
    ;	for i =0,len-1 do begin
    ;	  palette[ecWork[i,0],*]=ecWork[i,1:3]
    ;	endfor
      palette[ecWork[*,0],*]=ecWork[*,1:3]
    endif
    
    if keyword_set(load) then begin
      tvlct, palette
      device,decomposed=0
    endif
    return,palette

end


;TEST
 for i=0,255 do tvlct,0,0,0,i  ;completely black palette
 values=[-20,-10,0,11,21,33,49,50] ;to set zero. Only min and max matter: [-20,50]
 
 ;set colors from 101 to 200 with bandsize 20 over all black palette
 ct1=colors_band_palette(min(values),max(values),pmin=101,pmax=200,bandvalsize=20,/load)
; ---- check ----
 print,transpose([[findgen(!D.TABLE_SIZE)],[ct1]]) ;print: index, R, G, B
 cindex  ;if David Fanning routine is present, show colors and index in palette.
 print,"-----------------"
 
 ;loading a single extracolor 
 ct1=colors_band_palette(min(values),max(values),pmin=101,pmax=200,$
      bandvalsize=20,/load,extracolors=[10,30,31,32])
 print,transpose([[9,10,11],[ct1[[9,10,11],*]]]) ;print: index, R, G, B
 cindex  ;if David Fanning routine is present, show colors and index in palette.
 print,"-----------------"
 ;loading extracolor with matrix
 ct1=colors_band_palette(min(values),max(values),pmin=101,pmax=200,$
      bandvalsize=20,/load,extracolors=[[10,40,41,42],[11,50,51,52]])
 print,transpose([[9,10,11],[ct1[[9,10,11],*]]]) ;print: index, R, G, B
 cindex  ;if David Fanning routine is present, show colors and index in palette.

;
;useful commands for checking:
;----------------------
;cindex  ;show colors and index in palette
;----------------------
;tvlct,rVec,gVec,bVec,/get  ;retrieve palette color indeces
;-----------------------------------------------
;print,"Index ","R     ","G    ","B    " & print,transpose([[findgen(!D.TABLE_SIZE)],[res]])
;;RESULT:
;Index R     G    B    
;     0.000000     0.000000     0.000000     0.000000
;      1.00000     0.000000     0.000000     0.000000
;      ..          ..           ..           ..
;      100.000     0.000000     0.000000     0.000000
;      101.000      247.000      247.000     0.000000
;      102.000      240.000      240.000     0.000000
;      ..          ..           ..           ..
;      127.000      57.0000      57.0000     0.000000
;      128.000      50.0000      50.0000     0.000000
;      129.000      255.000      255.000      255.000
;      130.000      50.0000     0.000000     0.000000
;      131.000      57.0000     0.000000     0.000000
;      ..          ..           ..           ..
;      157.000      247.000     0.000000     0.000000
;      158.000      255.000     0.000000     0.000000
;      159.000     0.000000      50.0000     0.000000
;      160.000     0.000000      57.0000     0.000000
;      ..          ..           ..           ..
;      186.000     0.000000      247.000     0.000000
;      187.000     0.000000      255.000     0.000000
;      188.000     0.000000     0.000000      50.0000
;      189.000     0.000000     0.000000      57.0000
;      ..          ..           ..           ..      
;      199.000     0.000000     0.000000      130.000
;      200.000     0.000000     0.000000      137.000
;      201.000     0.000000     0.000000     0.000000
;      ..          ..           ..           ..
;      255.000     0.000000     0.000000     0.000000

end