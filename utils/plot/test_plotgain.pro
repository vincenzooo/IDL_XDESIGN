;2020/06/11 fails.
;
;This part defines telescopes from old code

;densita'  --
;C:1.9/2.3(graph)
;Ni:8.9
;Au:19.3
;Ir:22.4
;W:19.3
;Pt:21.4
;Si:2.33
print,"main"

Pt={sample,material:'Pt',density:21.4,filename:'PtC',octhickness:80.}
W={sample,material:'W',density:19.3,filename:'WC',octhickness:80.}
Ir={sample,material:'Ir',density:22.4,filename:'IrC',octhickness:105.}
Au={sample,material:'Au',density:19.3,filename:'AuC',octhickness:80.}
samples=[Pt,W,Ir,Au]
eRosita={name:"eRosita", angles:[0.34,1.6], energy:[0.5,10.], color:0,labeloffset:[1.57,6.5],$
  linestyle:2}  ;labeloffset:[0.07,0.3]
hxmt={name:"PolariX/HXMT", angles:[0.61,0.88], energy:[2.,8.],color:4,labeloffset:[0.95,6.2],$
  linestyle:0}  ;labeloffset:[0.07,2.80]
simbolx={name:"Simbol X", angles:[0.1,0.23], energy:[0.5,80.],color:0,labeloffset:[0.15,5.],$
  linestyle:1}  ;labeloffset:[0.07,2.5]
edge={name:"EDGE/XENIA", angles:[0.8,1.8], energy:[0.5,6.],color:0,labeloffset:[1.75,3],$
  linestyle:0}  ;labeloffset:[0.95,3]
xeus={name:"XEUS", angles:[0.24,0.85], energy:[0.1,40.], color:10,labeloffset:[0.30,0.5],$
  linestyle:0}  ;labeloffset:[0.07,0.5]
conx={name:"Constellation-X", angles:[0.11,0.46], energy:[0.1,70.], color:11,labeloffset:[0.17,7.0],$
  linestyle:0}  ;labeloffset:[0.07,6.0]

telescopes=[hxmt,simbolx,xeus,edge,eRosita,conx]


;this part create a reflectivity matrix, using new code obtained by adapting IRT reflectivity function.
WHILE !D.Window GT -1 DO WDelete, !D.Window ;close all currently open windows

nkpath='C:\Users\kovor\Documents\IDL\user_contrib\imd\nk'
testfolder = 'C:\Users\kovor\Documents\IDL\IDL_XDESIGN\test'

npe=100
npa=10
en_range=[0.1 ,5.]
deg_range=[0.7d, 0.85d]
mat = nkpath+path_sep()+'Ir.nk'

energy = dindgen(npe)/(npe-1)*(en_range[1]-en_range[0])+en_range[0]
alpha_deg =dindgen(npa)/(npa-1)*(deg_range[1]-deg_range[0])+deg_range[0]

;test calling with two vectors
setstandarddisplay,/tk
r2D=reflex2D_IRT(energy, alpha_deg*!PI/180d,mat)
print,r2d

;window,/free
;fig2d=image(r2D,alpha_deg,energy)

plot_gain,90.-alpha_deg,energy,transpose(R2d),transpose(R2d*0)+1d,$
  filename=testfolder+path_sep()+'output'+$
  path_sep()+'test_plotgain'+path_sep()+'Ir_test'

end