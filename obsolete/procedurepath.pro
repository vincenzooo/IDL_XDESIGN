function procedurePath,procedureName

message,"Obsolete, use instead PROGRAMROOTDIR from Coyote Library"
return, FILE_DIRNAME((ROUTINE_INFO(procedureName, /SOURCE)).path)

end