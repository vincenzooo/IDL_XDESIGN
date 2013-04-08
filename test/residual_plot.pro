pro residual_plot
x = findgen(100)/99*8     
model = sin(x)
data = model+randomn(seed, 100)
spaces = replicate(' ', 59); these will supress tick labels
blanks = replicate('', 59);null strings don't suppress tick labels                          
oldp = !p
oldy = !y ;Remember...
!p.multi = [0, 1, 2]   ;2 plots
!y.margin[0] = 0      ;put plot at bottom of plot box
plot, x, data, ps = 1, xstyle = 4+1, ytickname = [' ', blanks]
; 4+1 = no x axes + exact range
axis, 0, !y.crange[1], xaxis = 1, xtickname = spaces    ;top axis
axis, 0, !y.crange[0], xaxis = 0, xtickname = spaces    ;bottom axis
oplot, x, model
!y = oldy             ;get old !y back
!y.margin[1] = 0      ;put plot at top of plot box
!p.region = [!x.region[0], 0.3, !x.region[1], !y.region[1]]
;above shrinks down the residual plot
plot, x, data-model, ps = 1, xstyle = 8+1, ytickname = [blanks[0:5], ' ']
;8+1= bottom axis only + exact range
axis, 0, !y.crange[1], xaxis = 1, xtickname = spaces
oplot, !x.crange, [0, 0]
!y = oldy             ;get old !y back
!p = oldp
end