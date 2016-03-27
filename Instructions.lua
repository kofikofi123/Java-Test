--Made seperate file for instructions

local instructions = {}
local bitwise = require("ay/Bitwise.lua")

--* = asd repetetive ik, just want to make it easy on the eyes 
instructions[0] = function(method) end --nop
instructions[1] = function(method) method.stack:Push(nil) end --aconst_null
instructions[2] = function(method) method.stack:Push(-1) end -- iconst_m1
instructions[3] = function(method) method.stack:Push(0) end -- iconst_0
instructions[4] = function(method) method.stack:Push(1) end --iconst_1 
instructions[5] = function(method) method.stack:Push(2) end --iconst_2 
instructions[6] = function(method) method.stack:Push(3) end --iconst_3 
instructions[7] = function(method) method.stack:Push(4) end --iconst_4 
instructions[8] = function(method) method.stack:Push(5) end --iconst_5 
instructions[9] = function(method) method.stack:Push(0) end --lconst_0*
instructions[10] = function(method) method.stack:Push(1) end --lconst_1*
instructions[11] = function(method) method.stack:Push(0) end --fconst_0*
instructions[12] = function(method) method.stack:Push(1) end --fconst_1*
instructions[13] = function(method) method.stack:Push(2) end --fconst_2*
instructions[14] = function(method) method.stack:Push(0) end --dconst_0*
instructions[15] = function(method) method.stack:Push(1) end --dconst_1*

instructions[16] = function(method)
    method.stack:Push(method:get())
end --bipush
instructions[17] = function(method)
    --local a, b = method:get(), method:get()
    method.stack:Push(bitwise:OR(bitwise:SHL(method:get(), 8), method:get(), 16))
end--sipush
instructions[18] = function(method)
    local constant = method.block.constant_pool[method:get()]
    local tag = constant[1] 
    
    if (tag == 3 or tag == 4) then
        method.stack:Push(constant)
    elseif (tag == 
return instructions