function newline,graph=graph
;return the character for inserting a newline into a string.
;call with /graph set for output on direct graphics.

if (!D.NAME eq 'WIN') then newline = string([13B, 10B]) else newline = string(10B)
if keyword_set(graph) then newline = '!C' ;for output on direct must use 
                                          ;an "embedded formatting command"
return,newline


end
