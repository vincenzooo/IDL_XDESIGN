pro hewShift,folder,index,zVector,wplot=wplot,nops=nops,$
    figureErrorArcsec=FEarcsec,bestHEW=bestHEWindex
;-----------------------------------
;variabili da impostare
;folder: folder with data.
;index: indice dell'angolo fuori asse nella simulazione.
;wplot: array con le finestre da plottare: 1-spot focale, 2-hew in funzione di 
;shift, 3-posizioni del baricentro dello spot focale 

print, "Routine replaced by bestFocal.pro"
print, "Update your code"
stop

;th: off-axis angle
;focal: focal length in mm
;ntot: number of photons used for raytracing
;nsel: number of photons meeting the conditions
;barx, bary: coords of the baricentre of photons (geometric, reflectivity not considered)
;realxc: center of image as F*tan(theta)
;x,y,psi,r: cartesian and polar choords of photons positions on focal plane
;k=index of the selected photons in raytracing
;a1,a2: impact angles in rad
;ximp1,yimp1,zimp1,ximp2,yimp2,zimp2: cartesian coordinates of the two impact points
;psiimp1,rimp1,psiimp2,rimp2: polar coordinates of the two impact points
;k2: index of the selected photons in raytracing

;	folder='E:\Dati_applicazioni\idl\usr_contrib\kov\test_data\F10D394ff010_thsx'
;	zvector=vector(-30.,30.,100)
;	index=4
;	hewShift,folder,index,zVector,figureErrorArcsec=0.,wplot=[1]

end