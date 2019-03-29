function IRT_REFLEX,ANG,NC
  ;simple fresnel formula for monolayer, from IRT.

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