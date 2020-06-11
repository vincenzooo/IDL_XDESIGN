function REFLEX_IRT,ANG,NC
  ; Simple self-contained fresnel formula for monolayer, from IRT.
  ; Pass angles (grazing) in radians and complex indices for a list of photons.
  ; ANG and NC must be same length, return a vector of same length with reflectivity for each photon.
  ; Indices can be loaded (e.g. from IMD optical constants) with LOAD_NK.

  if n_elements(ang) ne n_elements(NC) then message, "Angle and oprical constant must be same length"

  CT1=COS(ANG)
  ST1=SQRT(1.-CT1*CT1)
  ST2=ST1/NC
  CT2=SQRT(1.-ST2*ST2)
  TE=(CT1-NC*CT2)/(CT1+NC*CT2)
  TM=(CT1-CT2/NC)/(CT1+CT2/NC)
  RTE=double(TE*CONJ(TE))
  RTM=double(TM*CONJ(TM))
  R=(RTE+RTM)/2.

  RETURN, R
END