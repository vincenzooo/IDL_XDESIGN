pro set_plot_default
a=!version
!Y.style=18
!X.style=1
if (a.os_family eq 'Windows') then SET_PLOT, 'WIN'  else SET_PLOT, 'X'
if (a.os_family eq 'unix') then device,retain=2 
end