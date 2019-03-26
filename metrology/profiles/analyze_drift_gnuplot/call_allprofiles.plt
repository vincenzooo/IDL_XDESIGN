 reset
 set macros
 set grid
 set key top box
#Launch this script from the results folder, created by the IDL drift analysis program
filesstr="x_axial_m30 x_axial_00 x_axial_p30 y_axial_m30 y_axial_00 y_axial_p30"

#test,use the same as filestr
titlesstr= "xscan_m30 xscan_00 xscan_p30 yscan_m30 yscan_00 yscan_p30"

ngroups=words(filesstr)
imgdir='img'
#plotTitle='06_mandrel3_grid_2500um'
plotTitle='Mandrel OP_P1 run1'
xroi='30:110'  #this must be correspond to the settings in IDL script.

 filenames(n)=word(filesstr,n)
 titles(n)=word(titlesstr,n)
 
set title plotTitle.': Offsets for each sequence of scans' 
set xlabel 'Scan #'
set ylabel 'Offset for leveling on X='.xroi.' mm (um)'
plot for [i=1:ngroups] 'offset.dat' u ($0+1):i title titles(i) w lp
pause -1
set terminal png
set output imgdir.'\offset_absolute.png'
replot
set term win
set output

#------------------------
set title plotTitle.': Difference in offset from first point for each sequence of scans' 
set key top left box 
unset arrow
set xlabel 'Scan #'
set ylabel 'Offset (um)'
plot for [i=1+ngroups:2*ngroups] 'offset.dat' u ($0+1):i title titles(i) w lp
pause -1
set terminal png
set output imgdir.'\offset_relative.png'
replot
set term win
set output
#-----------------------
#order of passed parameters to allprofiles_pro.plt
#$0	filename
#$1 title 

set xrange [12:130]
set grid

call 'allprofiles_pro.plt' filesstr titlesstr imgdir

pause -1








