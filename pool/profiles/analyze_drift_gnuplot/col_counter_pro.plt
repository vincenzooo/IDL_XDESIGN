#script col_counter_pro.plt (from stackoverflow: col_counter.gp), usage:
#call "col_counter_pro.plt" "my_datafile_name"
#print col_count   #number of columns is stored in col_count.
col_count=1
good_data=1
name="$0"
while (good_data){
   stats @name u (valid(col_count)) nooutput
   if ( STATS_max ){
      col_count = col_count+1
   } else {
      col_count = col_count-1
      good_data = 0
   }
}


