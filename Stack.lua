function Stack(d, n)
	local stack = newproxy(true)
	local s = getmetatable(stack)
	
	local field = {}

	s.__index = {
		Top = (n-1),
		Base = 0,
		Index = 0,
		CheckStack = function(self)
			if (not d) then return true end
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
			if (self:CheckStack()) then
				return false, error("Something wrong happened")
			end

			local index = self.Index 
			field[index] = item 

			self.Index = index + 1 
		end,
		Pop = function(self)
			if (self:CheckStack()) then 
				return false, error("Something wrong happened")
			end 
			
			local index = self.Index 
			local value = field[index]
			
			self.Index = index - 1 
			
			return true, value
		end 
	}

	s.__newindex = function(self, index, value)
		rawset(getmetatable(self).__index, index, value)
	end 
	
	return stack  --dont care for locking
end 


return Stack
