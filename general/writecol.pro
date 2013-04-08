;+
; NAME:
; writecol
;
; PURPOSE:
;    Prints a series of arrays to a file in ASCII format
;
; CALLING SEQUENCE:
;
;   writecol, filename, v1, v2, FMT='', HEADER=''
;
; INPUTS:
;   file     - Name of the ASCII file
;   v1       - Vector 1
;   v2       - Vector 2
;   [v3-v19]       - Vectors 3-14
;
; RETURNS:
;
; OUTPUTS:
;   Prints v1, v2 to screen
;
; OPTIONAL KEYWORDS:
;   FMT -  FORTRAN formatting
;   FILNUM - File number (as opposed to file)
;   HEADER - String or array of strings, each one is a line written on top of file.
;
; OPTIONAL OUTPUTS:
;
; COMMENTS:
;   The program keys off the number of elements in v1
;
; EXAMPLES:
;   writecol, 'arrays.dat', array1, array2
;
;
; PROCEDURES CALLED:
;
; REVISION HISTORY:
;   17-June-2001 Written by JXP
;-
;   21-December-2011 kov:
;     L'originale e' stato rinominato in 
; E:\Dati_applicazioni\idl\usr_contrib\Readcol\writecol_original.pro
; 14/10/2010 it is now possible to use it with only one vector.
; ??/??/20?? added header
;------------------------------------------------------------------------------
pro writecol, file, v1, v2, v3, v4, v5, v6, v7, v8, v9, $
              v10, v11, v12, v13, v14, v15, v16, v17, v18, v19, $
              FMT=fmt, FILNUM=filnum, HEADER=header


; writecol -- Writes a 2 column ascii file

  if (N_params() LT 2) then begin
    print,'Syntax - ' + $
             'writecol, file, v1, [v2-v19] FMT=, FILNUM= , HEADER='
    return
  endif

;

  flgvn = N_params()-1
  if not keyword_set( FMT ) then    flgfmt    = 0 else begin
      flgfmt = 1
      fmt = fmt[0]
  endelse

  if not keyword_set(FILNUM) then begin
      filnum = 91
      close, filnum
      openw, filnum, file
      flg_fil = 91
  endif
  
  if keyword_set(HEADER) then begin
      htemp=[header]
      for i =0,n_elements(htemp)-1 do begin
        printf,filnum,htemp[i]
      endfor
  endif

  for i=0L,n_elements(v1)-1 do begin
      case flgvn of
          19: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i],v12[i],v13[i],v14[i],v15[i], $
            v16[i],v17[i], v18[i], v19[i]
          18: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i],v12[i],v13[i],v14[i],v15[i], $
            v16[i],v17[i], v18[i]
          17: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i],v12[i],v13[i],v14[i],v15[i],v16[i],v17[i]
          16: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i],v12[i],v13[i],v14[i],v15[i],v16[i]
          15: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i],v12[i],v13[i],v14[i],v15[i]
          14: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i],v12[i],v13[i],v14[i]
          13: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i],v12[i],v13[i]
          12: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i],v12[i]
          11: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i],v11[i]
          10: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i],v10[i]
          9: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],$
            v8[i],v9[i]
          8: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i],v8[i]
          7: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i],v7[i]
          6: printf, filnum, FORMAT=fmt, v1[i],v2[i],v3[i],v4[i],v5[i],v6[i]
          5: printf, filnum, FORMAT=fmt, v1[i], v2[i], v3[i], v4[i], v5[i]
          4: printf, filnum, FORMAT=fmt, v1[i], v2[i], v3[i], v4[i]
          3: printf, filnum, FORMAT=fmt, v1[i], v2[i], v3[i]
          2: printf, filnum, FORMAT=fmt, v1[i], v2[i]
          1: printf, filnum, FORMAT=fmt, v1[i]
          else: stop
      endcase
  endfor
  if keyword_set(FLG_FIL) then close, filnum


return
end
