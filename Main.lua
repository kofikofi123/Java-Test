

function JVM(bytecode)
	local bitwise = require("Bitwise") -- For of
	local java = require("Java")
	local stack = require("Stack")
	local frame = require("Frame")
	
	local function code_wrap(block)
	    
		local m = {
			Stack = stack(true, 0), --jvm method/interface stack, not operand stack
			Run = function(self, ...)
				local arguments = {...}
				
			end
		}
		
		return m
	end
	
	
	return code_wrap(java.Blockify(bytecode))
	
end

--commentmeant


return JVM