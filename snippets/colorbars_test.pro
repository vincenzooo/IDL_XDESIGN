;esempi di routines per colorbar

;colorbar__define.pro:
;routine per la creazione di una barra di colori, versione ad oggetti
;       Written by: David Fanning, Fanning Software Consulting,
;                  26 November 1998.

colorbar = Obj_New("COLORBAR", Title='Colorbar Values', Range=[0,1000],$
                  Format='(I4)')
       Window
       LoadCT, 5
       colorbar->Draw
       colorbar->SetProperty, Range=[0,500], /Erase, /Draw
       Obj_Destroy, colorbar

;colorbar.pro:
;routine per la creazione di una barra di colori, versione non ad oggetti
;       Written by: David W. Fanning, 10 JUNE 96.


;EXAMPLE:

       To display a horizontal color bar above a contour plot, type:

       LOADCT, 5, NCOLORS=100
       CONTOUR, DIST(31,41), POSITION=[0.15, 0.15, 0.95, 0.75], $
          C_COLORS=INDGEN(25)*4, NLEVELS=25
       COLORBAR, NCOLORS=100, POSITION=[0.15, 0.85, 0.95, 0.90]
       
;La routine cont_image di windt permette anche di plottare una colorbar


