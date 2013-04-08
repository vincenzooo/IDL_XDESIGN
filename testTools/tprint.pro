pro tprint,command,cmdmarker=cmd
;execute e command and print the command and the output.
;useful for writing test procedures, e.g.:

;it doesn't really work with user functions.
;it could be fixed with some kind of parsing of parentesys
; and call_function.

;to test function MY_FUNC
;tprint, 'MYFUNC(arg1,arg2,...)
;ex.:
;tprint,'atan(sqrt(2.),2.)'
;gives:
;atan(sqrt(2.),2.)
;     0.615480
;

if n_elements(cmd) eq 0 then cmd=''

print,cmd+command
dummy=execute('a='+command)
print,a

end