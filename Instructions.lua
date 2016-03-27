--Made seperate file for instructions

local instructions = {}

instructions[0] = function(method) end --nop
instructions[1] = function(method) method.stack:Push(nil) end --aconst_null
return instructions