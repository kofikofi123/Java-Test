

return function(size)
    local frame = newproxy(true)
    local f = getmetatable(frame)
    
    local dex = {}
    
    f.__index = {
        Size = size,
        GetIndex = function(index)
            if (index > size) then return error("Index failed in frame") end 
            return dex[index]
        end,
        SetIndex = function(index, value)
            if (index > size) then return error("Index failed in frame") end 
            dex[index] = value 
        end
        
        f.__metatable = true
    }
    
    return frame
end 