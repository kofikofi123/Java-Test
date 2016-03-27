local bitwise = require("ay/Bitwise")
local bytecode
local function getByteArray(tbl)
	--"32233223"
	local new_value = 0
	for x = 1, #tbl do 
		new_value = bitwise:SHL(new_value, 8)
		new_value = new_value + tbl[x]
	end
	return new_value
end 
	
local function toEndian(bool, ...)
	local pack = {...}
	if (bool == false) then 
		return unpack(pack)
	else 
		local new_array = {}
		for x = #pack, 1, -1 do 
			new_array[#new_array + 1] = pack[x]
		end 
		return unpack(new_array)
	end
end 
	
local function getByteArrayFloat(tbl)
	tbl = {toEndian(true, unpack(tbl))}
	local sign = math.floor(bitwise:SHR(bitwise:AND(tbl[1], 0x80, 8), 7))
	local temp = getByteArray(tbl)
	local expo = bitwise:AND(math.floor(bitwise:SHR(temp, 23)), 0xFF, 8) - 127
	local man = bitwise:AND(temp, (2^32) - 1, 23)
	
	return ((-1)^sign * (1 + (man / 16777216)) * (2^expo))
end 
local function getByteArrayDouble(tbl)--[[]]
	tbl = {toEndian(true, unpack(tbl))}
	local sign = math.floor(bitwise:SHR(bitwise:AND(tbl[1], 0x80, 8), 7))
	local temp = bitwise:OR(getByteArray(tbl), 0, 64)
	local expo = (bitwise:AND(bitwise:SHR(temp, 52), 0x7FF, 11)) - 1023
	local man = math.floor(bitwise:AND(temp, ((2^52)-1), 52))
	local leading = 1
	--[[
	man = man * (2 ^ 24)
	man = man - 24 ]]

	if ((expo + 1023) == 0 and man ~= 0) then 
		expo = -1022 
		leading = 0 
	elseif ((expo + 1023) == 0 and man == 0) then 
		return (-1)^sign * 0
	end
	
	local value = (((-1)^sign) * math.ldexp(leading + (man / 4503599627370496), expo))
	
	return value
end

local function BytesToArray(n, nx)
	local array = {}
	
	while (nx > 0) do 
		array[#array + 1] = math.floor(bitwise:AND(n, 0xFF, 8))
		n = math.floor(bitwise:SHR(n, 8))
		nx = nx - 1
	end 
	
	return array
end 
local function bigunpack(...)
	local args = {...}
	local result = {}
	for x = 1, #args do 
		for y = 1, #args[x] do 
			result[#result + 1] = args[x][y]
		end 
	end 
	return result 
end 
local function get(a, b)
	return string.sub(bytecode, a, (a + b) - 1)
end 
local function get_erase(a, b)
	local str = get(a, b)
	bytecode = string.sub(bytecode, a + b, -1) 
	
	return str 
end
local function toEndian(bool, ...)
	local pack = {...}
	if (bool == false) then 
		return unpack(pack)
	else 
		local new_array = {}
		for x = #pack, 1, -1 do 
			new_array[#new_array + 1] = pack[x]
		end 
		return unpack(new_array)
	end
end 

local function ToHex(value, pad)
--if (pad > 8) then pad = 8 end
	local hex = "0x"
	
	local switch = {
		[0xA] = 'A', [0xB] = 'B', [0xC] = 'C', [0xD] = 'D', [0xE] = 'E', [0xF] = 'F'
	}
			
	for i = pad-1, 0, -1 do
		local nibble = math.floor(bitwise:AND(bitwise:SHR(value, i * 4), 0xF, 4))
		
		if (not switch[nibble]) then
			hex = hex .. tostring(nibble)
		else
			hex = hex .. switch[nibble]
		end
	end
	return hex
end
	
local JParser = {
	UTF8 = function(utf8) 
		if (utf8[1] ~= 1) then return nil end 
		
		local str = ""
		
		for x = 1, utf8[2] do 
			str = str .. string.char(utf8[3][x])
		end 
		
		return str 
	end,
	DOUBLE = function(double)
	    if (double[1] ~= 6) then return nil end 
	    
	    local c = bitwise:OR(bitwise:SHL(double[2], 32), double[3], 64)
           return getByteArrayDouble(BytesToArray(c, 8))
    end,
    FLOAT = function(float)
        if (float[1] ~= 4) then return nil end 
        
        return getByteArrayFloat(BytesToArray(float[2], 4))
    end,
    
       
        
    
}

local Parser = {} do --not local for now
	Parser.byte = function()
		return tonumber(get_erase(1, 1):byte(1, 1))
	end
	
	Parser.word = function()
		return getByteArray({get_erase(1, 2):byte(1, 2)})
	end
	
	Parser.dword = function()
		return getByteArray({get_erase(1, 4):byte(1, 4)})
	end

	Parser.cp_info = function(self, c)
			local cp_info = {}
			local temp, buffer
			local index = 1 
			while (c > 0) do 
				buffer = {}
				temp = Parser.byte()
				buffer[1] = temp 
				
				if (temp == 7) then 
					buffer[2] = Parser.word()
				elseif (temp == 9 or temp == 10 or temp == 11) then	
					buffer[2] = Parser.word()
					buffer[3] = Parser.word()
				elseif (temp == 8) then 
					buffer[2] = Parser.word()
				elseif (temp == 3 or temp == 4) then 
					buffer[2] = Parser.dword()
				elseif (temp == 5 or temp == 6) then 
					buffer[2] = Parser.dword()
					buffer[3] = Parser.dword()
					c = c - 1
					index = index + 1
					--Parser.byte()
				elseif (temp == 12) then 
					buffer[2] = Parser.word()
					buffer[3] = Parser.word()
				elseif (temp == 1) then 
					buffer[2] = Parser.word()
					local ttemp = buffer[2]
					local bbuffer = {}
					while (ttemp > 0) do 
						bbuffer[#bbuffer + 1] = Parser.byte()
						ttemp = ttemp - 1
					end 
					buffer[3] = bbuffer
				elseif (temp == 15) then 
					buffer[2] = Parser.byte()
					buffer[3] = Parser.word()
				elseif (temp == 16) then 
					buffer[2] = Parser.byte()
				elseif (temp == 18) then
					buffer[2] = Parser.word()
					buffer[3] = Parser.word()
				else 
				    print("Unkown tag", buffer[1])
				end
				
				cp_info[index] = buffer 
				
			    c = c - 1 
			    index = index + 1
			    
			end 
			
			
			
			return cp_info
		end
		
		Parser.GetArray = function(n, size_t)
			local array = {}
			
				while (n > 0) do 
				array[#array + 1] = get_erase(1, size_t)
				n = n - 1
			end 
			
			return array
		end
		
		Parser.method_or_field_info = function(self, cp, c, mask) 
			local fields = {}
			local field_info
			while (c > 0) do 
				field_info = {
					bitwise:AND(Parser.word(), mask, 16),
					Parser.word(),
					Parser.word(),
					Parser.word()
				}
				field_info[5] = self:attribute_info(cp, field_info[4])
				fields[#fields + 1] = field_info
				c = c - 1
			end 
			
			return fields
		end 
		
		Parser.StackMapTableParse = function(self, n)
		    local attributes = {}
		    local buffer
		    while (n > 0) do 
                buffer = {}
                buffer[1] = {self.byte()}
                buffer[2] = {self.byte(), self:vertification_info_parser(1)}
                buffer[3] = {self.byte(), self.word(), self:vertification_info_parser(1)}
                buffer[4] = {self.byte(), self.word()}
                buffer[5] = {self.byte(), self.word()}
                buffer[6] = {self.byte(), self.word()}
                    
                    
                if (buffer[6][1] >= 252 and buffer[6][1] <= 254) then
                    buffer[6][3] = self:vertification_info_parser(buffer[6][1] - 251)
                end 
                
                buffer[7] = {self.byte(), self.word(), self.word()}
                buffer[7][4] = self:vertification_info_parser(buffer[7][3])
                buffer[7][5] = self.word() 
                buffer[7][6] = self:vertification_info_parser(buffer[7][5])
                    
                    
                attributes[#attributes + 1] = buffer
                n = n - 1 
			    end 
			    
		    end 
		    
		Parser.vertification_info_parser = function(self, n)
		    local tbl = {}
		    
		    local buffer = {}
		    
		    while (n > 0) do 
		        buffer[1] = {self.byte()}
		        buffer[2] = {self.byte()}
		        buffer[3] = {self.byte()}
		        buffer[4] = {self.byte()}
		        buffer[5] = {self.byte()}
		        buffer[6] = {self.byte()}
		        buffer[7] = {self.byte()}
		        buffer[8] = {self.byte(), self.word()}
		        buffer[9] = {self.byte(), self.word()}
		        
		        
		        tbl[#tbl + 1] = buffer 
		        n = n - 1     
	        end 
	        
		    return tbl
	    end 
	    
		Parser.elementvparser = function(self, n)
			local elements = {}
			while (n > 0) do 
				local buffer = {}
				buffer[1] = self.byte()
				buffer[2] = {self.word(), self.word()}
				buffer[3] = self.word()
				buffer[4] = self.annotation_parser(n)
				buffer[5] = {}
				
				
				buffer[5][1] = self.word()
				buffer[5][2] = self:elementvparser(buffer[5][1])
				
				elements[#elements + 1] = buffer 
				n = n - 1 
			end 
		end
		Parser.annotation_parser = function(self, n)
			local anno = {}
			while (n > 0) do 
				local buffer = {}
				
				buffer[1] = self.word()
				buffer[2] = self.word()
				buffer[3] = {}
				
				local temp = buffer[2]
				 
				 
				while (temp > 0) do
					buffer[3][#buffer[3] + 1] = {
						self.word(),
						self.elementvparser(1)
					}
					temp = temp - 1 
				end 
				
				
				n = n - 1
			end 
			return anno 
		end 
		Parser.attribute_info = function(self, cp, c)
			local attributes = {}
			while (c > 0) do 
				local ati = {
					self.word(),
					self.dword()
				}
				local buffer1 
				local __string__ = JParser.UTF8(cp[ati[1]])
				    
				
				if (__string__ == "ConstantValue") then 
					ati[3] = self.word()
				elseif (__string__ == "Code") then 
					ati[3] = self.word()
					ati[4] = self.word()
					ati[5] = self.dword()
					ati[6] = self.GetArray(ati[5], 1)
					ati[7] = self.word()
					ati[8] = {}
					local temp = ati[7]
					local buffer = ati[8]
					
					while (temp > 0) do 
						buffer[#buffer + 1] = self.GetArray(4, 2)
						temp = temp - 1 
					end
					
					ati[9] = self.word()
					ati[10] = self:attribute_info(cp, ati[9])
					--print("This is code", unpack(ati))
				--[[elseif (__string__ == "StackMapTable") then 
					ati[3] = self.word()
					print("ati[3]", ati[3])
					ati[4] = self:StackMapTableParse(ati[3])]]
				elseif (__string__ == "Exceptions") then 
					ati[3] = self.word()
					ati[4] = self.word() 
				elseif (__string__ == "InnerClasses") then
					ati[3] = self.word()
					ati[4] = {}
					
					local buffer = ati[4]
					local temp = ati[3]
					
					
					while (temp > 0) do 
						buffer[#buffer + 1] = self.GetArray(4, 2)
						temp = temp - 1 
					end 
				elseif (__string__ == "EnclosingMethod") then 
					ati[3] = self.word()
					ati[4] = self.word()
				elseif (__string__ == "Signature") then 
					ati[3] = self.word()
				elseif (__string__ == "SourceFile") then --could have done it with "Signature" but meh, I did same stuff with others
					ati[3] = self.word()
				elseif (__string__ == "SourceDebugExtension") then 
					ati[3] = self.GetArray(ati[2], 1)
				elseif (__string__ == "LineNumberTable") then 
					ati[3] = self.word()
					ati[4] = {}
					
					local temp = ati[3]
					local buffer = ati[4]
					while (temp > 0) do 
						buffer[#buffer + 1] = {self.word(), self.word()}--self.GetArray(2, 2)
						temp = temp - 1 
					end 
				elseif (__string__ == "LocalVariableTable") then  --asd
					ati[3] = self.word()
					
					local temp = ati[3]
					local buffer = ati[4]
					while (temp > 0) do 
						buffer[#buffer + 1] = self.GetArray(5, 2)
						temp = temp - 1 
					end 
				elseif (__string__ == "LocalVariableTypeTable") then 
					ati[3] = self.word()
					
					local temp = ati[3]
					local buffer = ati[4]
					while (temp > 0) do 
						buffer[#buffer + 1] = self.GetArray(5, 2)
						temp = temp - 1 
					end 
				elseif (__string__ == "RuntimeVisibleAnnotations") then 
					ati[3] = self.word()
					ati[4] = self:annotation_parser(ati[3])
				elseif (__string__ == "RuntimeInvisibleAnnotations") then 
					ati[3] = self.word()
					ati[4] = self:annotation_parser(ati[3])
				elseif (__string__ == "RuntimeVisibleParameterAnnotations") then 
					ati[3] = self.byte()
					ati[4] = {}
					
					local temp = ati[3]
					local buffer = ati[4]
					
					while (temp > 0) do 
						buffer[#buffer + 1] = {}
						buffer[#buffer][1] = self.word()
						buffer[#buffer][2] = self:annotation_parser(buffer[#buffer][1])
						temp = temp - 1 
					end 
				elseif (__string__ == "BootstapMethods") then 
					ati[3] = self.word()
					ati[4] = {}
					
					local temp = ati[4]
					local buffer = ati[4]
					while (temp > 0) do 
						buffer[#buffer + 1] = self.GetArray(3, 2)
						temp = temp - 1 
					end 
				elseif (__string__ == "AnnotationDefault") then 
					ati[3] = self:elementvparser(1)
				else
				    self.GetArray(ati[2], 1)
				end 
				
				    
				attributes[#attributes + 1] = ati
				c = c - 1
			end
			
			return attributes 
		end
		--[[
		JParser.double = function()
			return getByteArrayDouble({get_erase(1, 8):byte(1, 8)})
		end 
		
		JParser.float = function()
				return getByteArrayFloat({get_erase(1, 4):byte(1, 4)})		end]]
			
		Parser.GetAttribute = function(constant_pool, attributes, classname) 
			local picked
			--print(#attributes)
			for x = 1, #attributes do 
				local __string__ = JParser.UTF8(constant_pool[attributes[x][1]])
				if (__string__ == classname) then 
					return attributes[x]
					--break
				end 
			end 
			--return picked
		end 
		
		Parser.GetAttributes = function(constant_pool, attributes, classname)
			local stuff = {}
			for x = 1, #attributes do 
				local __string__ = JParser.UTF8(constant_pool[attributes[x][1]])
				if (__string__ == classname) then 
					stuff[#stuff + 1] = attributes[x]
				end 
			end 
			
			return stuff
		end 
		
		Parser.GetMethod = function(constant_pool, methods, classname)
		    --local method 
			    
		    for x = 1, #methods do 
		        local __string__ = JParser.UTF8(constant_pool[methods[x][2]])
		            
		        if (__string__ == classname) then 
		            return methods[x] 
	            end 
	            
	        end 
		end
           
         Parser.GetConstant = function(constant_pool, classnumber)
              local stuff = {}
               for x = 1, #constant_pool do 
                   if (constant_pool[x][1] == classnumber) then 
                       stuff[#stuff + 1] = constant_pool[x]
                   end 
               end 
               return stuff 
           end 
           
           
    
    end
	
local function CheckCombatibility()
	if (Parser.dword() ~= 0xCAFEBABE) then 
		return false, "Not valid magic number" 
	end
	return true
end 

local function Blockify()
	local block = {}
	local temp
	block.min = Parser.word()
	block.max = Parser.word()
	
	block.constants = Parser.word()	
	block.constant_pool = Parser:cp_info(block.constants - 1)
	
	block.access_flags = bitwise:AND(Parser.word(), 0x7631, 16)
	
	block.this_class = Parser.word()
	block.super_class = Parser.word()
	block.interfaces_count = Parser.word()
	block.interfaces = {}
	temp = block.interfaces_count 
	while (temp > 0) do 
		block.interfaces[#block.interfaces + 1] = Parser.word()
			temp = temp - 1 
	end 
	
	block.fields_count = Parser.word()
	block.fields = Parser:method_or_field_info(block.constant_pool, block.fields_count, 0x7631)
	
	block.method_count = Parser.word()
	block.methods = Parser:method_or_field_info(block.constant_pool, block.method_count, 0x1DFF)
	
	block.attribute_count = Parser.word()
	block.attribute_info = Parser:attribute_info(block.constant_pool, block.attribute_count)
	
	if (#bytecode > 0) then 
        (warn or print)("Unparsed extras detected")
    end 
    
    
	return block
end



return {
	["Parser"] = Parser,
	["JParser"] = JParser,
	["Blockify"] = function(b)
		bytecode = b
		assert(CheckCombatibility())
		return Blockify()
	end
}
