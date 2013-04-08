#23/06/2010
#plotta la funzione di vignetting
#
#energie: 
# 1.0	5.0    10.0    20.0    30.0    50.0	70.0
#
#colonne del file di vignetting (con IDL extractvignetting):
# angle  energy  aeff(cm^2) vignetting mirrorAreaFraction nOfFocusedPhotons Error(cm^2)

filedata = 'F10D394ff010_thsx\F10D394ff010_thsx_vig.dat'  #name (with relative path) of the file containing vignetting file
titolo='NHXM - 70 shells 154-390 mm - Pt/C ML ph-A - F10D394ff010_thsx (traie 7)'

set title titolo
set key bottom left box vertical title 'Vignetting function'
set grid
set yrange [0:1.05]
set xlabel 'Off axis angle (arcmin)'
set ylabel 'Fraction of on-axis area'

plot filedata i 0 u 1:4 title 'Geometrical' w l,\
filedata i 5 u 1:4 title '5.0 keV' w l,\
filedata i 10 u 1:4 title '10.0 keV' w l,\
filedata i 20 u 1:4 title '5.0 keV' w l,\
filedata i 30 u 1:4 title '30.0 keV' w l,\
filedata i 50 u 1:4 title '50.0 keV' w l,\
filedata i 70 u 1:4 title '70.0 keV' w l

#filedata i 1 u 1:($3*0.9) title '1.0 keV' w l,\

pause -1

set terminal png size 800,600 medium 
set output filedata.'_vign.png'
replot
set terminal win
set output


#----------------------------------
#con errori
set title titolo
set key bottom center box horizontal title 'Vignetting function'
set grid
set yrange [0:1.05]
set xlabel 'Off axis angle (arcmin)'
set ylabel 'Fraction of on-axis area'

plot filedata i 0 u 1:4:($7/$3) title 'Geometrical' w e,\
filedata i 5 u 1:4:($7/$3) title '5.0 keV' w e,\
filedata i 10 u 1:4:($7/$3) title '10.0 keV' w e,\
filedata i 20 u 1:4:($7/$3) title '20.0 keV' w e,\
filedata i 30 u 1:4:($7/$3) title '30.0 keV' w e,\
filedata i 50 u 1:4:($7/$3) title '50.0 keV' w e,\
filedata i 70 u 1:4:($7/$3) title '70.0 keV' w e,\
filedata i 0 u 1:4 notitle w l lt 1,\
filedata i 5 u 1:4 notitle w l lt 2,\
filedata i 10 u 1:4 notitle w l lt 3,\
filedata i 20 u 1:4 notitle w l lt 4,\
filedata i 30 u 1:4 notitle w l lt 5,\
filedata i 50 u 1:4 notitle w l lt 6,\
filedata i 70 u 1:4 notitle w l lt 7

#filedata i 1 u 1:($3*0.9) title '1.0 keV' w l,\

pause -1

set terminal png size 800,600 medium 
set output filedata.'_vig_werr.png'
replot
set terminal win
set output
#----------------------------------

set title titolo
set key top left box horizontal title 'Vignetting function'
#set key bottom right box title 'Effective area'
set grid
set yrange [0:700]
set xlabel 'Off axis angle (arcmin)'
set ylabel 'Effective area (cm^2)'

plot filedata i 0 u 1:($3*0.9) title 'Geometrical' w l,\
filedata i 5 u 1:($3*0.9) title '5.0 keV' w l,\
filedata i 10 u 1:($3*0.9) title '10.0 keV' w l,\
filedata i 20 u 1:($3*0.9) title '20.0 keV' w l,\
filedata i 30 u 1:($3*0.9) title '30.0 keV' w l,\
filedata i 50 u 1:($3*0.9) title '50.0 keV' w l,\
filedata i 70 u 1:($3*0.9) title '70.0 keV' w l

pause -1
set terminal png size 800,600 medium 
set output filedata.'_area.png'
replot
set terminal win
set output