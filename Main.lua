

function JVM(bytecode)
	local bitwise = require("ay/Bitwise") -- For of
	local java = require("ay/Java")
	local stack = require("ay/Stack")
	
	
	local function code_wrap(block)

		local m = {
		    LoadedClasses = {},
		    ProgramCounter = 1,
			GetBlock = function()
				return block 
			end,
			PrepareMethod = function(method_info)
			    local pmethod = {}
			    local code_segment = java.Parser.GetAttribute(block.constant_pool, method_info[5], "Code")
			    
			    pmethod.stack = stack(code_segment[3])
			    pmethod.instructions = code_segment[6]
			    pmethod.n_stack = code_segment[3]
				pmethod.n_locals = code_segment[4]
			    
			    return pmethod
		    end,
		    LoadClass = function(self, block)
		        local classname = java.JParser.UTF8(block.constant_pool[block.constant_pool[block.this_class][2]])
		        
		        self.LoadedClasses[classname] = block
		        
		        local init_method = self.PrepareMethod(java.Parser.GetMethod(block.constant_pool, block.methods, "<init>"))
	        end,
			RunDebug = function(self)
			
			    
			
				self:LoadClass(block)
				
				---------------------------------------------------------------------------------------------
				local this_class_name = java.JParser.UTF8(block.constant_pool[block.constant_pool[block.this_class][2]])
				
				print(string.format("The current class name is (%s)", this_class_name))
				------------------------------------------------------------------
				local methods = block.methods
				local fields = block.fields
				
				print(string.format("Num methods: %d", #methods))
				
				for x = 1, #methods do 
					print(string.format("\tMethod name (%s)", java.JParser.UTF8(block.constant_pool[methods[x][2]])))
				
				end 
				print(string.format("Num fields: (%d)", #fields))
				
				for x = 1, #fields do 
					print(string.format("\tField name (%s)", java.JParser.UTF8(block.constant_pool[fields[x][2]])))
				end 
			    
				local Source = java.Parser.GetAttribute(block.constant_pool, block.attribute_info, "SourceFile")
				
				print(string.format("Source name (%s)", java.JParser.UTF8(block.constant_pool[Source[3]])))
			    
			end,
			Run = function(self)
		    end 
		    
		}
		
		return m
	end
	
	
	return code_wrap(java.Blockify(bytecode))
	
end

--commentmeant


return JVM