pro testmultiplot


 x = findgen(100)    ;    MULTIPLOT
 t=exp(-(x-50)^2/300)    ;  -------------------------
 erase       ;  |           |           |
 u=exp(-x/30)      ;  |           |           |
 y = sin(x)      ;  |  UL plot  |  UR plot  |
 r = reverse(y*u)    ;  |           |           |
 !p.multi=[0,2,2,0,0]    ;  |           |           |
 multiplot       ; y-------------------------
 plot,x,y*u,title='MULTIPLOT'  ; l|           |           |
 multiplot & plot,x,r    ; a|           |           |
 multiplot       ; b|  LL plot  |  LR plot  |
 plot,x,y*t,ytit='ylabels' ; e|           |           |
 multiplot       ; l|           |           |
 plot,x,y*t,xtit='xlabels' ; s-------------------------
 multiplot,/reset    ;           xlabels
          
; wait,2 & erase      ;    TEST
; multiplot,[1,3]     ; H------------------------
; plot,x,y*u,title='TEST'   ; E|  plot #1   |
; multiplot     ; I------------------------
; plot,x,y*t,ytit='HEIGHT'  ; G|  plot #2   |
; multiplot     ; H------------------------
; plot,x,r,xtit='PHASE'   ; T|  plot #3   |
; multiplot,/reset    ;  ------------------------
;         ;    PHASE

 multiplot,[1,1],/init,/verbose  ; one way to return to single plot

end