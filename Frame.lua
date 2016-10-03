local stack = require("Stack")
local java = require("Java")


return function(method_info, cp)
    local frame = newproxy(true)
    local f = getmetatable(frame)
    local wrapped = java.PrepareMethod(method_info)
    
    f.__index = {
        Stack = stack(false, wrapped.n_stack), --value will come later
        ConstantPool = cp,
        DefinedMethod = wrapped,
        LocalVariables = {}
    }
  
    local temp = f.__index.LocalVariables
    
  
    f.__metatable = true
    
    return frame
end 