set grid
set key top box
unset logscale y
set xlabel 'energy (keV)'
set ylabel 'Reflectivity'
set yrange [0:1]
#Pt
set title 'Pt sample -      0.099998474 deg'
plot 'PtC_0.1000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.1000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.1000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.15000153 deg'
plot 'PtC_0.1500.dat' u 1:2 title 'Pt' w l,\
'PtC_0.1500.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.1500.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.19999695 deg'
plot 'PtC_0.2000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.2000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.2000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.30000305 deg'
plot 'PtC_0.3000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.3000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.3000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.40000153 deg'
plot 'PtC_0.4000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.4000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.4000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.50000000 deg'
plot 'PtC_0.5000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.5000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.5000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.59999847 deg'
plot 'PtC_0.6000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.6000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.6000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.69999695 deg'
plot 'PtC_0.7000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.7000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.7000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.80000305 deg'
plot 'PtC_0.8000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.8000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.8000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -       0.90000153 deg'
plot 'PtC_0.9000.dat' u 1:2 title 'Pt' w l,\
'PtC_0.9000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_0.9000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -        1.0000000 deg'
plot 'PtC_1.0000.dat' u 1:2 title 'Pt' w l,\
'PtC_1.0000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_1.0000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -        1.0999985 deg'
plot 'PtC_1.1000.dat' u 1:2 title 'Pt' w l,\
'PtC_1.1000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_1.1000.png'
replot
set term X11
set output
#------------------------------


#Pt
set title 'Pt sample -        1.1999969 deg'
plot 'PtC_1.2000.dat' u 1:2 title 'Pt' w l,\
'PtC_1.2000.dat' u 1:3 title 'Pt + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'PtC_1.2000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -      0.099998474 deg'
plot 'WC_0.1000.dat' u 1:2 title 'W' w l,\
'WC_0.1000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.1000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.15000153 deg'
plot 'WC_0.1500.dat' u 1:2 title 'W' w l,\
'WC_0.1500.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.1500.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.19999695 deg'
plot 'WC_0.2000.dat' u 1:2 title 'W' w l,\
'WC_0.2000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.2000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.30000305 deg'
plot 'WC_0.3000.dat' u 1:2 title 'W' w l,\
'WC_0.3000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.3000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.40000153 deg'
plot 'WC_0.4000.dat' u 1:2 title 'W' w l,\
'WC_0.4000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.4000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.50000000 deg'
plot 'WC_0.5000.dat' u 1:2 title 'W' w l,\
'WC_0.5000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.5000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.59999847 deg'
plot 'WC_0.6000.dat' u 1:2 title 'W' w l,\
'WC_0.6000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.6000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.69999695 deg'
plot 'WC_0.7000.dat' u 1:2 title 'W' w l,\
'WC_0.7000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.7000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.80000305 deg'
plot 'WC_0.8000.dat' u 1:2 title 'W' w l,\
'WC_0.8000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.8000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -       0.90000153 deg'
plot 'WC_0.9000.dat' u 1:2 title 'W' w l,\
'WC_0.9000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_0.9000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -        1.0000000 deg'
plot 'WC_1.0000.dat' u 1:2 title 'W' w l,\
'WC_1.0000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_1.0000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -        1.0999985 deg'
plot 'WC_1.1000.dat' u 1:2 title 'W' w l,\
'WC_1.1000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_1.1000.png'
replot
set term X11
set output
#------------------------------


#W
set title 'W sample -        1.1999969 deg'
plot 'WC_1.2000.dat' u 1:2 title 'W' w l,\
'WC_1.2000.dat' u 1:3 title 'W + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'WC_1.2000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -      0.099998474 deg'
plot 'IrC_0.1000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.1000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.1000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.15000153 deg'
plot 'IrC_0.1500.dat' u 1:2 title 'Ir' w l,\
'IrC_0.1500.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.1500.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.19999695 deg'
plot 'IrC_0.2000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.2000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.2000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.30000305 deg'
plot 'IrC_0.3000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.3000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.3000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.40000153 deg'
plot 'IrC_0.4000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.4000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.4000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.50000000 deg'
plot 'IrC_0.5000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.5000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.5000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.59999847 deg'
plot 'IrC_0.6000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.6000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.6000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.69999695 deg'
plot 'IrC_0.7000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.7000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.7000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.80000305 deg'
plot 'IrC_0.8000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.8000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.8000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -       0.90000153 deg'
plot 'IrC_0.9000.dat' u 1:2 title 'Ir' w l,\
'IrC_0.9000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_0.9000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -        1.0000000 deg'
plot 'IrC_1.0000.dat' u 1:2 title 'Ir' w l,\
'IrC_1.0000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_1.0000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -        1.0999985 deg'
plot 'IrC_1.1000.dat' u 1:2 title 'Ir' w l,\
'IrC_1.1000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_1.1000.png'
replot
set term X11
set output
#------------------------------


#Ir
set title 'Ir sample -        1.1999969 deg'
plot 'IrC_1.2000.dat' u 1:2 title 'Ir' w l,\
'IrC_1.2000.dat' u 1:3 title 'Ir + a-C(      105.000 A)' w l lt 3
pause -1
set terminal png
set out 'IrC_1.2000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -      0.099998474 deg'
plot 'AuC_0.1000.dat' u 1:2 title 'Au' w l,\
'AuC_0.1000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.1000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.15000153 deg'
plot 'AuC_0.1500.dat' u 1:2 title 'Au' w l,\
'AuC_0.1500.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.1500.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.19999695 deg'
plot 'AuC_0.2000.dat' u 1:2 title 'Au' w l,\
'AuC_0.2000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.2000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.30000305 deg'
plot 'AuC_0.3000.dat' u 1:2 title 'Au' w l,\
'AuC_0.3000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.3000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.40000153 deg'
plot 'AuC_0.4000.dat' u 1:2 title 'Au' w l,\
'AuC_0.4000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.4000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.50000000 deg'
plot 'AuC_0.5000.dat' u 1:2 title 'Au' w l,\
'AuC_0.5000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.5000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.59999847 deg'
plot 'AuC_0.6000.dat' u 1:2 title 'Au' w l,\
'AuC_0.6000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.6000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.69999695 deg'
plot 'AuC_0.7000.dat' u 1:2 title 'Au' w l,\
'AuC_0.7000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.7000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.80000305 deg'
plot 'AuC_0.8000.dat' u 1:2 title 'Au' w l,\
'AuC_0.8000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.8000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -       0.90000153 deg'
plot 'AuC_0.9000.dat' u 1:2 title 'Au' w l,\
'AuC_0.9000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_0.9000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -        1.0000000 deg'
plot 'AuC_1.0000.dat' u 1:2 title 'Au' w l,\
'AuC_1.0000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_1.0000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -        1.0999985 deg'
plot 'AuC_1.1000.dat' u 1:2 title 'Au' w l,\
'AuC_1.1000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_1.1000.png'
replot
set term X11
set output
#------------------------------


#Au
set title 'Au sample -        1.1999969 deg'
plot 'AuC_1.2000.dat' u 1:2 title 'Au' w l,\
'AuC_1.2000.dat' u 1:3 title 'Au + a-C(      80.0000 A)' w l lt 3
pause -1
set terminal png
set out 'AuC_1.2000.png'
replot
set term X11
set output
#------------------------------


