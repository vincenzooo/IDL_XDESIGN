;+
; transform a Value in a vector of nel elements (defaults to 1) if it is a scalar.
; If it is already a vector, nothing happens, but if nel is passed, it raise error
;   if vector doesn't have the correct number of elements (unless /SILENT is set).
;
; Useful to "format" function argument that can be a scalar (to apply to n cases) or a vector
;   (with a different value for each of the ncases).
;
; :Examples:
;   colors = vectorize(['blue','red','green'],3)  ;-> doesn't do anything, colors=['blue','red','green']
;   colors = vectorize('blue',3)  ; -> colors = ['blue','blue', 'blue']
;   colors = vectorize(['blue'],3)  ; -> gives error (colors is already a vector). Can be bypassed setting /SILENT
;-
function vectorize,value,nel,silent=silent

  if n_elements(nel) eq 0 then nel=1

  if size(value) eq 0 then return, replicate(value, nel)

  ; value was already a vector, gives error if
  if keyword_set(silent) then $
    if n_elements(value) ne

end