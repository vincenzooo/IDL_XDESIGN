; this was at the end of oc_analysis, not sure what is plotted,
; probably something related to SPIE papers in years around 2008.
; One minimal test from below is also left in oc_analysis as inline test.

;densita'  --
;C:1.9/2.3(graph)
;Ni:8.9
;Au:19.3
;Ir:22.4
;W:19.3
;Pt:21.4
;Si:2.33

Pt={sample,material:'Pt',density:21.4,filename:'PtC',octhickness:80.}
W={sample,material:'W',density:19.3,filename:'WC',octhickness:80.}
Ir={sample,material:'Ir',density:22.4,filename:'IrC',octhickness:105.}
Au={sample,material:'Au',density:19.3,filename:'AuC',octhickness:80.}
;samples=[Pt,W,Ir,Au]
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

;-------------------------------------
;generate the 3d plot of angle-energy gain
mat=Pt     ;mat

extracol=[[0,0,0,0],[255,255,255,255]]

oc_analisys ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
 ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated,optimize=1,besttvec=besttvec

; oc_analisys ,mat,[0,2.0],[0.1,10.],'a-C',80.,perc_gain=perc_gain,area_gain=area_gain,$
;   ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated
 ;oc_analisys ,mat,hxmt.angles,hxmt.energy,'a-C',perc_gain=perc_gain,area_gain=area_gain,$
 ;ener=ener,theta=theta,r_bare=r_bare,r_coated=r_coated
 

set_plot, 'win'
plot_gain,theta,ener,R_coated,R_bare,density,filename=mat.filename,$
   perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,window=5
print,bestTVec
window,2
plot,bestTVec
maketif,mat.filename+'_thick'



;-------------------------------plot ps
set_plot,'ps'
Device, COLOR=1, BITS_PER_PIXEL=8
;device , FILEname=mat.filename+'.ps'
plot_gain,theta,ener,R_coated,R_bare,mat.density,filename=mat.filename,$
  perc_gain=perc_gain, area_gain=area_gain,telescopes=telescopes,$
  window=3,extracolors=extracol

device, /close
;-------------------------------
set_plot, 'PS'
;window,8
device , FILE='reflex2_0.7deg.ps'
i_th07=max(where(90.-theta lt 0.7))
pgain=100*(R_coated^2-R_bare^2)/R_bare^2

plot, ener,R_coated[i_th07,*]^2,xtitle='Energy (keV)',ytitle='Square reflectivity',$
  title='Square reflectivity vs energy at 0.7 deg'
oplot, ener,R_bare[i_th07,*]^2,color=100,linestyle=2
legend,["Pt + C(80 A)","Pt"],position=12,color=[!P.color,100],linestyle=[0,2]
;oplot,  ener,pgain[i_th07,*],color=160
;window,9,ysize=200
device,/close

;p=plot(ener,R_coated[i_th07,*]^2,xtitle='Energy (keV)',ytitle='Square reflectivity',$
;  title='Square reflectivity vs energy at 0.7 deg',name="Pt + C(80 A)")
;plot(ener,R_bare[i_th07,*]^2,color=100,linestyle=2,/overplot,name="Pt")

device , FILE='gain2_0.7deg.ps'
ysize_st=!D.Y_SIZE
device,ysize=5
plot,  ener,pgain[i_th07,*],ytitle='% Gain',xtitle='Energy (keV)'
oplot, ener,0*indgen(n_elements(ener)),linestyle=2
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

;-------------------------------
set_plot, 'PS'
device , FILE='reflex2_4.5keV.ps'
i_en4500=max(where(ener lt 4.5))

plot, ener,R_coated[*,i_en4500]^2,xtitle='Incidence angle (deg)',ytitle='Square reflectivity'
oplot, ener,R_bare[*,i_en4500]^2,color=100,linestyle=2
legend,["Pt","Pt + C(80 A)"],position=12,color=[!P.color,100]
device,/close
device , FILE='gain2_4.5keV.ps'
ysize_st=!D.Y_SIZE
device,ysize=5
plot,  90-theta,pgain[*,i_en4500],ytitle='% Gain',xtitle='Incidence angle (deg)'
oplot, 90-theta,0*indgen(n_elements(theta)),linestyle=1
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

setstandarddisplay
;set_plot, 'win'

;-------------------------------
set_plot, 'PS'
;window,8

device , FILE='gain2acoll_0.7deg.ps'
ysize_st=!D.Y_SIZE
device,ysize=5
plot,  ener,area_gain[i_th07,*]*100.,ytitle='Gain (% Acoll)',xtitle='Energy (keV)'
oplot, ener,0*indgen(n_elements(ener)),linestyle=1
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

;-------------------------------
set_plot, 'PS'
device , FILE='gain2acoll_4.5keV.ps'
ysize_st=!D.Y_SIZE
device,ysize=5
plot,  90-theta,area_gain[*,i_en4500]*100,ytitle='Gain (% Acoll)',xtitle='Incidence angle (deg)'
oplot, 90-theta,0*indgen(n_elements(theta)),linestyle=1
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

;-------------------------------
set_plot, 'PS'
device , FILE='gain2acoll_3.0keV.ps'
ysize_st=!D.Y_SIZE
i_en3000=max(where(ener lt 3.0))
device,ysize=5
plot,  90-theta,area_gain[*,i_en3000]*100,ytitle='Gain (% Acoll)',xtitle='Incidence angle (deg)'
oplot, 90-theta,0*indgen(n_elements(theta)),linestyle=1
;device, ysize=ysize_st
DEVICE, XSIZE=7, YSIZE=5, /INCHES
device,/close
;--------------------------------

setstandarddisplay
;set_plot, 'win'

;--------------------------------------

;------------------------------------
;launch angular scan simulator
;energy=[0.93,1.49,2.98,4.51,5.41,6.40]
;thrange=[0,2.]
;ang_simulator, samples, energy,thrange

;-------------------------------------
; launch energy scan simulator
;en_range =[0.1,10.]
;angles=[0.1,0.15, 0.2, 0.3,0.4, 0.5,0.6, 0.7,0.8,0.9, 1.0,1.1, 1.2]
;en_simulator,samples, angles, en_range
;-------------------------------------
end

