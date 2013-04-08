;see also programRootDir by Coyote.

pro prova
  print, "---------------------------------"
  print, "In procedure:"
  Help, /Source, Output=helpoutput 
  print,"helpoutput: ",helpoutput
  print,"-----"
  help,/source_files,output=dummy,Names='findProcedurePath' ;metodo fornitomi da Meroni (IDL)
  print,"helpoutput (IDL support): ",dummy
  print, "---"
  print,"help,call=call & print,call"
  help,call=call & print,call
  print, "---------------------------------"
end

pro findProcedurePath
prova

print, "---------------------------------"
print,"In main"
Help, /Source, Output=helpoutput 
print,"helpoutput: ",helpoutput
print,"-----"
help,/source_files,output=dummy,Names='findProcedurePath.pro' ;metodo fornitomi da Meroni (IDL)
print,"helpoutput (IDL support): ",dummy
print, "---"
print,"help,call=call & print,call"
help,call=call & print,call
print, "---------------------------------"
PRINT, FILE_DIRNAME((ROUTINE_INFO('findprocedurepath', /SOURCE)).path) 



end