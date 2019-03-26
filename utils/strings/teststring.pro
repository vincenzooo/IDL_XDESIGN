function teststring,string
return, n_elements(string) && string 
end

heap_gc
print,'Testing undefined string: ',testString(undefined)
print,'Testing empty string: ',testString("")
print,'Testing a normal string: ',testString("This is a string")

end
