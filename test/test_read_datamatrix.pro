datafolder = 'test_data\read_datamatrix'

cd,programrootdir() 


;a = read_datamatrix(datafolder+path_sep()+'aree_00.txt',delimiter = ' ')
;print,size(a,/dimensions)
;print,a
;;1.00000 573.35071 4.02586 .00702
;;2.00000 581.23128 4.08088 .00702
;;3.00000 573.92846 4.03009 .00702
;;4.00000 576.51217 4.04824 .00702
;;5.00000 577.35031 4.05434 .00702
;;6.00000 576.07787 4.04611 .00702


;a = read_datamatrix(datafolder+path_sep()+'aree_02.txt',delimiter = ' ')
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree_02.txt',delimiter = ' ',strip=0)
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree.txt',delimiter = ' ')
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree.txt')
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree.txt',strip=0)
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree_01.txt',strip=0)
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree_03.txt')
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree_04.txt',comment='#')
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree_05.txt',skip=2)
;print,size(a,/dimensions)
;print,a

;a = read_datamatrix(datafolder+path_sep()+'aree_06.txt',skip=2,comment=';')
;print,size(a,/dimensions)
;print,a

a = read_datamatrix(datafolder+path_sep()+'aree_06.txt',skip=2,comment=';',type=5,y=y)
print,size(a,/dimensions)
print,a
end