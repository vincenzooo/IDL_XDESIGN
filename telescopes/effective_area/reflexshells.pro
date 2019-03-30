function reflexshells,coatings,alpha,lam,roughness=roughness
  ;loop through each coating and calculate effective area for all shells with the specific coating,
  ;  populating reflectivity matrix with reflectivity for each Energy
  ;  in columns and for offaxis angles + coating in rows
  ;

  if n_elements(coatings) eq 1 then coatings =replicate(coatings,n_elements(alpha))
  coatingslist=coatings[uniq(coatings)]
  reflex_m=dblarr(n_elements(alpha),n_elements(lam))

  foreach coat, coatingslist do begin
    ish_sel=where(coatings eq coat,c)
    if c ne 0 then $
      reflex_m[ish_sel,*]= coating_reflex(coat,lam,alpha[ish_sel],roughness=roughness)
  endforeach
  return, reflex_m
end