
function Stack(n)
		local stack = newproxy(true)
		local s = getmetatable(stack)
		
		local field = {}
		
		s.__index = {
			Top = n,
			Base = 1,
			Size = n,
			Push = function(self, n)
				if (self.Top < self.Base) then return error("Stack error") end 
				field[self.Top] = n 
				self.Top = self.Top - 1
			end,
			Pop = function(self)
				if (self.Top > self.Size) then return error("Stack error") end 
				self.Top = self.Top + 1 
				local val = field[self.Top]
				return val 
			end 
		}
		
		s.__newindex = function(self, index, value)
			rawset(getmetatable(self).__index, index, value)
		end 
		
		return stack  --dont care for locking
end 


return Stack