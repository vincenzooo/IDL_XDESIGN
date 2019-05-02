function merge_struct,s1,override,defaults=defaults
  ;+
  ; merge two structures S and Override.
  ; return a structure with all keys and values from first structure overridden
  ;   by the second structure (files are replaced if existing, and copied if not,
  ;   other existing tags of `s1` are left untouched).
  ;
  ; usage:
  ;   ;
  ;
  ; s1 = {s1,A: 1,B: "xxx",FIRST: 2,LAST: 28}
  ; override={orr,a:2,MEDIAN:15}
  ; print, merge_struct(s1,override)
  ;
  ; ;expected={ABfull, A: 2,B: "xxx",FIRST: 2,LAST: 28,MEDIAN:15}

  ;  defaults={a:2,MEDIAN:15}
  ;  m=merge_struct(s1,defaults,/defaults)
  ;
  ; ;expected={A: 1,B: "xxx",FIRST: 2,LAST: 28,MEDIAN:15}
  ;
  ;-
  ; note that this doesn't work because fails on duplicate keys
  ;    ;s2={ss2,inherits s1, inherits orr}
  ;   it also needs named structures (that in turns change the structure to
  ;   `object type`, whatever it means, but can create problems with already defined
  ;   structures). So it is better to just copy the
  ;   structure to an anonymous one, postponing (potentially for ever) more sofisticated ideas.

  ; "relaxed structure assignment" is also not useful, because of the strange behavior of non common
  ;   fields.

  ; dictionaries are instead perfect, as they are very similar to structures with easy modification.
  ;    note that they completely lack a comparison (equality) operation.
  
  if n_elements(override) eq 0 then return, s1
  a=dictionary(s1)
  b=dictionary(override)
  res = a+b

  if keyword_set(defaults) then return, (b+a).ToStruct() $
  else return, (a+b).ToStruct()

end


pro test_merge_struct ;s1,override,expected,default=defaults

  ;s1=
  ;  p = CREATE_STRUCT(name='AB', 'A', 1, 'B', 'xxx')
  ;  ;add tags “FIRST” and “LAST” to the structure:
  ;  p = CREATE_STRUCT(p,'FIRST', 2,  'LAST', 28)
  ;  or also ? something like:
  ;  p = { AB_ext, INHERITS AB, FIRST, 2,  LAST, 28 }
  ;  % Conflicting or duplicate structure tag definition: <missing>

  s1 = {s1,A: 1,B: "xxx",FIRST: 2,LAST: 28}
  override={orr,a:2,MEDIAN:15}
  expected={ABfull, A: 2,B: "xxx",FIRST: 2,LAST: 28,MEDIAN:15}

  m=merge_struct(s1,override)

  print,"expected :"
  help,expected,/struct
  print,"result:"
  help,m,/struct

  print, '------'
  s1 = {s1,A: 1,B: "xxx",FIRST: 2,LAST: 28}
  defaults={a:2,MEDIAN:15}
  expected={A: 1,B: "xxx",FIRST: 2,LAST: 28,MEDIAN:15}

  m=merge_struct(s1,defaults,/defaults)

  print,"expected :"
  help,expected,/struct
  print,"result:"
  help,m,/struct

end