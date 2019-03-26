#Plot the deviation from average for 10 tracks from columns of a text file, 
#	first col (1) is used as X, last (12) column is used as average. 

#order of passed parameters
#$0	filename
#$1 title 
#$2 imgdir

filesstr=$0
titlesstr=$1
imgdir=$2
ngroups=words(filesstr)

 #these lines define convenience functions, to call the nth word of the list string as titles(n)
 filenames(n)=word(filesstr,n)
 titles(n)=word(titlesstr,n)

 #---------------
#RMS all together (one per group)
#rmsCols=""	#to store list of column indices for each file
## do for [i=1:ngroups] {
## fn=filenames(i).'_rep_sm.dat'
## call "col_counter_pro.plt" fn 
## rmsCols=rmsCols." ".col_count
## }
## rmsCol(n)=word(rmsCols,n)
## print 'created rmscol'
## nscans=(col_count-3) #x, avg, rms are extra columns, but it changes for each file, eliminate it and replace it
#	with rmsCol(i)-2
set title 'rms for profile repetitions '.titles(i)
set xlabel 'Scan Axis(mm)'
set ylabel 'rms(um)'
plot for [i=1:ngroups] (filenames(i)).'_rep_sm.dat' u 1:"Rms" title titles(i) w l 
#plot for [i=1:ngroups] (filenames(i)).'_rep_sm.dat' u 1:"Rms" title sprintf("%i",i) w l lw 2 #working
pause -1

set terminal png
set output imgdir.'\'.(filenames(i)).'_rep_sm_rms.png'
replot
set term win
set output

#ALT 
#---------------
do for [i=1:ngroups] {
fn=filenames(i).'_rep.dat'
print "Processing ".fn
call "col_counter_pro.plt" fn
nscans=(col_count-3) #x, avg, rms are extra columns
set title 'deviation from average for '.nscans.' scans on profile '.titles(i)
set xlabel 'Scan Axis(mm)'
set ylabel 'Height(um)'
plot for [j=2:1+nscans] fn u 1:(column(j)-column("Average")) w l title sprintf("%i",j-1) 
set terminal png
set output imgdir.'\'.(filenames(i)).'_rep.png'
replot
set term win
set output
}
pause -1

#---------------

do for [i=1:ngroups] {
fn=filenames(i).'_rep_sm.dat'
call "col_counter_pro.plt" "fn" 
nscans=(col_count-3) #x, avg, rms are extra columns
set title 'deviation from average for '.nscans.' scans on profile '.titles(i)
set xlabel 'Scan Axis(mm)'
set ylabel 'Height(um)'
plot for [j=2:1+nscans] fn u 1:(column(j)-column("Average")) w l title sprintf("%i",j-1) lw 2
set terminal png
set output imgdir.'\'.(filenames(i)).'_rep_sm.png'
replot
set term win
set output
}
pause -1





