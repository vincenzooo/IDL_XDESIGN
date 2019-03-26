;+
;ndkov: c'era anche una routine legend in astron.tar, che ho rinominato perche' veniva
;sempre chiamata al posto di questa.
;18 Oct 2010 Added position 13, outside up right 
; April 2011 added positions outside the graph and custom.
;            added maxwidth (in device coordinate)


;NAME:
;         LEGEND
;
; PURPOSE:
;
;         Add to a plot a legend containing lines and plotting symbols,
;         enclosed in a box.
;
; CALLING SEQUENCE:
;
;        LEGEND,LABELS
;
; INPUTS:
;        LABELS - n-element string array of labels.
;
; KEYWORD PARAMETERS:
;
;       POSITION - an integer, specifying the location of the legend box:
;
;                  0: no legend is drawn.
;                  1: below plot, left
;                  2: below plot, center
;                  3: below plot, right
;                  4: lower left
;                  5: lower center
;                  6: lower right
;                  7: middle left
;                  8: middle center
;                  9: middle right
;                  10: upper left
;                  11: upper center
;                  12: upper right
;                  13: outside up right 
;                  for custom position, pass a two-element vector
;                  if not specified, default position=10
;
;        COLOR - n-element array of colors. default is !p.color
;
;        LINESTYLE - n-element array of linestyles. if ommited, only
;                    symbols are plotted.
;
;        THICK - n-element array of thicknesses. default is !p.thick
;
;        PSYM - n-element array of psym values. if positive, only
;               symbols are plotted.
;
;        SYMSIZE - n-element array of symsize values. default is !p.symsize
;
;        SYMBOLS - array of 'symbol' specifiers: each element of
;                  psym which is equal to 8 (user-defined symbol)
;                  must have a corresponding value for 'symbol' to be
;                  used by the procedure SYMBOLS.
;                  Examples:	psym=[8,8,8,8],symbols=[1,2,20,30]
;                                psym=[1,2,8,8],symbols=[1,2]
;
;        CHARSIZE - scalar specifiying the size of the text.
;
;        TITLE - scalar string specifying legend title
;
;        T_COLOR - scalar specifying the color index of the title.
;
;        NOLINES - set to inhibit drawing lines and symbols; just draw
;                  labels in color.
;
;        SYM_ONLY - set to inhibit drawing lines; just draw symbols.
;
;        NOBOX - set to inhibit drawing a box around the legend
;
;        LINEWIDTH - width in character units. default = 4.
;
;        BOXPADX - padding in character units, between text and box in
;                  x. default=2.0
;        BOXPADY - padding in character units, between text and box in
;                  y. default=0.5
;
;        FONT - Set to an integer from 3 to 20, corresponding to the
;               Hershey vector font sets, referring to the font used
;               to display the text.  If a font other than !3 is used
;               in the text string, then FONT should be set
;               accordingly. (Any font commands embedded in the text
;               string are ignored.)
;
;        BOXFUDGEX - A scaling factor, used to fudge the width of the
;                    box surrounding the text.  Default=1.0.
;
; RESTRICTIONS:
;
;       When specifying a position of 1,2 or 3, you'll need
;       to (a) use the same charsize value for the plot and
;       for the legend, and (b) draw the plot with an extra
;       ymargin(0).  i.e., set ymargin(0)=7+n_elements(text_array)
;
;
; MODIFICATION HISTORY:
;
;        David L. Windt, Bell Labs, March 1997
;        windt@bell-labs.com
;
;       October, 1997, dlw:
;
;       Now using the TEXT_WIDTH function, in order to do a somewhat
;       better job of drawing the box around the text.
;
;       NONPRINTER_SCALE keyword parameter is now obsolete.
;
;       BOXFUDGEX keyword parameter added.
;
;-
pro legend,labels,position=position, $
           color=color,linestyle=linestyle, $
           thick=thick,psym=psym,symsize=symsize, $
           symbol=symbol, $
           charsize=charsize, $
           linewidth=linewidth, $
           title=title,t_color=t_color, $
           nolines=nolines,sym_only=sym_only,nobox=nobox, $
           boxpadx=boxpadx,boxpady=boxpady, $
           nonprinter_scale=nonprinter_scale, $
           font=font,boxfudgex=boxfudgex,$
           maxwidth=maxwidth
           
on_error,2

if n_params() ne 1 then message,'usage: legend,labels'

case n_elements(position) of 
  0: position=10 
  1: if position eq 0 then return
  2: begin
      custompos=position
      position=20
     end 
  else: message,'number of elements not recognized for POSITION'
endcase


;; get/set charsize
if n_elements(charsize) eq 0 then charsize=!p.charsize
if charsize eq 0 then charsize=1.

;; scale factor for text, relative to charsize
scale=0.85

;; scale factors for "character" sizes:
sx=float(scale*charsize)
sy=float(charsize)

;if maxwidth is provided, wrap text in legend
if n_elements(maxwidth) ne 0 then begin
  maxleg=convert_coord(maxwidth,0,/normal,/to_device)/!d.x_ch_size
  maxleg=maxleg[0]
  ;temptative editing, can be improved
  for i=0,n_elements(labels)-1 do begin
    if strlen(labels[i]) gt maxleg then begin
      if i eq 0 then labels=[strsplit(labels[0],/Extract),labels[1:n_elements(labels)-1]] else $
      if i eq n_elements(labels)-1 then labels=[labels[0:i-1],strsplit(labels[i],/Extract)] else $
      labels=[labels[0:i-1],strsplit(labels[i],/Extract),labels[i+1:n_elements(labels)-1]]
    endif
  endfor
endif 
;; compute number of lines of text:
n_lines=n_elements(labels)

if n_elements(color) ne n_lines then $
  if n_elements(color) eq 0 then color=replicate(cgcolor('black'),n_lines) else $
  color=replicate_vector(color,n_lines)
if n_elements(linestyle) ne n_lines then linestyle=replicate(!p.linestyle,n_lines)
if n_elements(thick) ne n_lines then thick=replicate(!p.thick,n_lines)
if n_elements(psym) ne n_lines then psym=replicate(!p.psym,n_lines)
if n_elements(symsize) ne n_lines then symsize=replicate(!p.symsize,n_lines)
for i=0,n_lines-1 do if symsize(i) eq 0 then symsize(i)=1.
if n_elements(t_color) eq 0 then t_color=cgcolor('black')

;; fudge factor to get right side of box close to end of text:
if n_elements(boxfudgex) ne 1 then boxfudgex=1.

;; determine maximum number of printing characters:
width=0
for i=0,n_lines-1 do width=width > text_width(labels(i),font=font)

;; width of text region, in characters:
;; (add sympad characters for padding)
if n_elements(linewidth) ne 1 then linewidth=4.
linewidth=linewidth*sx
linepad=.75*sx
sympad=max(symsize)*(total(psym) ne 0)*sx
if keyword_set(nolines) then begin
    linewidth=0
    linepad=0
    sympad=0
endif
if keyword_set(sym_only) then begin
    linewidth=0
    linepad=0
endif
if n_elements(boxpadx) ne 1 then boxpadx=2.
lxc=((linewidth+linepad+sympad*1.5)+(width+boxpadx)*sx)*boxfudgex

;; height of text region, in characters:
;; (add boxpady characters for padding)
if n_elements(boxpady) ne 1 then boxpady=.5
lyc=-(n_lines+ (n_elements(title) eq 1) + boxpady)*sy

;; coordinates of plot area, in device units:
xcrange=!x.crange
if !x.type then xcrange=10^xcrange
ycrange=!y.crange
if !y.type then ycrange=10^ycrange
lower_left=convert_coord(xcrange(0),ycrange(0),/data,/to_device)
upper_right=convert_coord(xcrange(1),ycrange(1),/data,/to_device)

;; width of plot area, in characters:
pxc=float(upper_right(0)-lower_left(0))/!d.x_ch_size

;; height of plot area, in characters:
pyc=-float(upper_right(1)-lower_left(1))/!d.y_ch_size

;; define padding: distance (in characters) of edge of
;; text box from plot axes:
padxc=3.*sx
padyc=1.5*sy

;; define coordinates of upper left corner of text region, in
;; characters, relative to upper left corner of plot data area.
case position of
    0: return
    1: begin                          ; below plot, left
        x1c=0.
        y1c=pyc-4.*sy-padyc
    end
    2: begin                          ; below plot, center
        x1c=.5*(pxc-lxc)
        y1c=pyc-4.*sy-padyc
    end
    3: begin                          ; below plot, right
        x1c=pxc-lxc
        y1c=pyc-4.*sy-padyc
    end
    4: begin                          ; lower left
        x1c=padxc
        y1c=pyc-lyc+padyc
    end
    5: begin                          ; lower center
        x1c=.5*(pxc-lxc)
        y1c=pyc-lyc+padyc
    end
    6: begin                          ; lower right
        x1c=pxc-lxc-padxc
        y1c=pyc-lyc+padyc
    end
    7: begin                          ; middle left
        x1c=padxc
        y1c=.5*(pyc-lyc)
    end
    8: begin                          ; middle center
        x1c=.5*(pxc-lxc)
        y1c=.5*(pyc-lyc)
    end
    9: begin                          ; middle  right
        x1c=pxc-lxc-padxc
        y1c=.5*(pyc-lyc)
    end
    10: begin                         ; upper left
        x1c=padxc
        y1c=-padyc
    end
    11: begin                         ; upper center
        x1c=.5*(pxc-lxc)
        y1c=-padyc
    end
    12: begin                         ; upper right
        x1c=pxc-lxc-padxc
        y1c=-padyc
    end
    13: begin                         ; outside upper right (kov)
        x1c=padxc+pxc
        y1c=-padyc
    end
    14: begin                         ; outside middle right (kov)
        x1c=padxc+pxc  
        y1c=.5*(pyc-lyc)
    end
    15: begin                         ; outside lower right (kov)
        x1c=padxc+pxc  
        y1c=pyc-lyc+padyc
    end
    16: begin                         ; outside upper left (kov)
        x1c=(-padxc-lxc-charsize)  ;charsize added to leave room for the axis title, it could be done in a better way (kov)
        y1c=-padyc
    end
    17: begin                         ; outside center left (kov)
        x1c=(-padxc-lxc-charsize)  ;charsize added to leave room for the axis title, it could be done in a better way (kov)
        y1c=.5*(pyc-lyc)
    end
    18: begin                         ; outside center left (kov)
        x1c=(-padxc-lxc-charsize)  ;charsize added to leave room for the axis title, it could be done in a better way (kov)
        y1c=pyc-lyc+padyc
    end
    20: begin     ;custompos=custom position of the center in normal coordinates
    ;N.B.:for some reason lyc is negative
      tmp=convert_coord(custompos[0],custompos[1],/normal,/to_device)
      x1c=(tmp[0]-lower_left[0])/!d.x_ch_size-lxc/2
      y1c=(tmp[1]-upper_right[1])/!d.y_ch_size-lyc/2
    end
    else: message,'value not recognized for POSITION'
endcase

;; define bottom right corner of text box, in characters:

x2c=x1c+lxc
y2c=y1c+lyc

;; position for title underline
ytc=y1c-1*sy

;; define bottom right corner of each line of text:

txc=fltarr(n_lines + (n_elements(title) eq 1))+  $
  x1c+sx*boxpadx/2.+linewidth+linepad+sympad*1.5
if n_elements(title) eq 1 then txc(0)=x1c+lxc/2.
tyc=fltarr(n_lines + (n_elements(title) eq 1))
for i=0,n_lines + (n_elements(title) eq 1) -1 do  $
  tyc(i)=y1c-(i+.85)*charsize-boxpady/2.
if n_elements(title) eq 1 then tyc(0)=tyc(0)+.15*charsize

;; define positions for lines/psyms:

linex1c=fltarr(n_lines)+x1c+boxpadx/2.+sympad/2.
linex2c=linex1c+linewidth+sympad/2.
;; if psym is positive, don't draw the line:
for i=0,n_lines-1 do if psym(i) gt 0 then linex1c(i)=linex2c(i)
if keyword_set(sym_only) then begin
    linex1c=linex1c*0+x1c+boxpadx/2.+sympad/2.
    linex2c=linex1c
endif
lineyc=tyc(n_elements(title) eq 1:*)+.25*sy

;; get coordinates of upper left corner ("origin")
;; of plot in device coords:

x0=lower_left(0)
y0=upper_right(1)

;; convert (x1,y1), (x2,y2), and (tx,ty) to device coords:

x1=x0+x1c*!d.x_ch_size
y1=y0+y1c*!d.y_ch_size

x2=x0+x2c*!d.x_ch_size
y2=y0+y2c*!d.y_ch_size

yt=y0+ytc*!d.y_ch_size

tx=x0+txc*!d.x_ch_size
ty=y0+tyc*!d.y_ch_size

linex1=x0+linex1c*!d.x_ch_size
linex2=x0+linex2c*!d.x_ch_size
liney=y0+lineyc*!d.y_ch_size

;; draw the labels:
i0=0
if n_elements(title) eq 1 then begin
    xyouts,tx(0),ty(0),title,color=t_color,charsize=scale*charsize, $
      _extra=_extra,/device,alignment=.5
    i0=1
endif
for i=0,n_lines-1 do xyouts,tx(i+i0),ty(i+i0),labels(i), $
  color=color(i),charsize=scale*charsize,_extra=_extra,/device

;; draw the box around the text:

if keyword_set(nobox) eq 0 then begin
    if n_elements(title) eq 1 then  $
      plots,[x1,x2],[yt,yt],/device,_extra=_extra
    plots,[x1,x2,x2,x1,x1],[y1,y1,y2,y2,y1],/device,_extra=_extra,color=t_color
endif

if keyword_set(nolines) then return

i=0
sindex=0
while i lt n_lines do begin
    if abs(psym(i)) eq 8 then begin
        symbols,symbol(sindex),1
        sindex=sindex+1
    endif
    plots,[linex1(i),linex2(i)],[liney(i),liney(i)], $
      color=color(i),linestyle=linestyle(i), $
      thick=thick(i),psym=psym(i),symsize=symsize(i),/device
    i=i+1
endwhile

return
end
