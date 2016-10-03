function Stack(d, n)
	local stack = newproxy(true)
	local s = getmetatable(stack)
	
	local field = {}

	s.__index = {
		Top = (n-1),
		Base = 0,
		Index = 0,
		CheckStack = function(self)
			local base = self.Base 
			local top = self.Top
			local index = self.Index

			if (index > top) then 
				return false
			elseif (index < base) then 
				return false
			end 

			return true
		end,
		Push = function(self, item)
			if (self:CheckStack() and not d)
				return false, error("Something wrong happened")
			end

			local index = self.Index 
			field[index] = item 

			self.Index = index + 1 
		end,
		Pop = function(self)

		end 
	}

	s.__newindex = function(self, index, value)
		rawset(getmetatable(self).__index, index, value)
	end 
	
	return stack  --dont care for locking
end 


return Stack
