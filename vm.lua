
local player = game:GetService("Players")["kofikofi123"]
HardwareFrame = Instance.new("Part", player.Character)
HardwareFrame.TopSurface = "Smooth"
HardwareFrame.BottomSurface = "Smooth"
HardwareFrame.FormFactor = "Custom"
HardwareFrame.Size = Vector3.new(16, 0.2, 16)
HardwareFrame.CanCollide = false
HardwareFrame.Anchored = false
HardwareFrame.CFrame = CFrame.Angles(2.5, 1.55, 2.5)
HardwareFrame.Name = tostring(math.random(0, 9999))

local HardwareFrame_Hold = Instance.new("BodyPosition", HardwareFrame)
HardwareFrame_Hold.maxForce = Vector3.new(math.huge, math.huge, math.huge)
--HardwareFrame_Hold.D = 190
--HardwareFrame_Hold.P = 300
coroutine.resume(coroutine.create(function()
	while true do
		HardwareFrame_Hold.position = player.Character.Head.CFrame.p + Vector3.new(0, 4, 10)
		wait()
	end
end))
--Workspace.Base.Wall.Size = Vector3.new(Workspace.Base.Wall.Size.X, Workspace.Base.Wall.Size.X) 
Software = Instance.new("SurfaceGui", HardwareFrame)
Software.Face = "Top"
local asd = Instance.new("ScrollingFrame", Software)
asd.Size = UDim2.new(0, Software.AbsoluteSize.X, 0, Software.AbsoluteSize.Y)
asd.CanvasSize = UDim2.new(0, asd.Size.X.Offset, 0, asd.Size.Y.Offset * 9)
asd.BackgroundTransparency = 1
asd.Parent = Software
local frame = Instance.new("TextLabel", asd)
frame.Size = UDim2.new(0, Software.AbsoluteSize.X, 0, Software.AbsoluteSize.Y)
frame.ClipsDescendants = true
--frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.Position = UDim2.new(0,0,0,0) 
frame.BackgroundColor3 = Color3.new(1, 1, 1)
frame.TextXAlignment = "Left"
frame.TextYAlignment = "Top"
frame.TextScaled = true
frame.TextWrapped = true
frame.Text = ""
function kprint(...)

	local args = {...}
	local temp = "" 
	for d = 1, #args do 
		local x = tostring(args[d])
		if (#frame.Text == 1024 or (#frame.Text + #x) >= 1024) then
			local old_frame = frame
			frame = frame:Clone()
			frame.Text = "" 
			frame.Position = UDim2.new(0, 0, 0, old_frame.Position.Y.Offset + old_frame.Size.Y.Offset)
			frame.Parent = asd 
		end 
		temp = temp .. x .. " "
	end
	
	frame.Text = frame.Text .. temp
	frame.Text = frame.Text .. "\n"
	
	print(...)
end

--function kprint(...) print(...) end


function JVM(bytecode)
	local bitwise = {
		AND = function(self, byte1, byte2, size)
			local value = 0
			for i = 1, size do
				--[[
				local bit1, bit2 = (math.floor(byte1/(2^(i-1)))%2), (math.floor(byte2/(2^(i-1)))%2)
				kprint(string.format("bits(%d, %d) index(%d)", bit1, bit2, i))
				]]
				value = value + ((((math.floor(byte1/(2^(i-1)))%2))*((math.floor(byte2/(2^(i-1)))%2)))*2^(i-1))
			end
			return value
		end,
		OR = function(self, byte1, byte2, size)
			local value = 0
			for i = 1, size do
				local bit1, bit2 = (math.floor(byte1/(2^(i-1)))%2), (math.floor(byte2/(2^(i-1)))%2)
				--kprint(string.format("bits(%d, %d) index(%d)", bit1, bit2, i))
				local final_bit = 0
				
				if (bit1 == 1 and bit2 == 1) then
					final_bit = 1
				elseif(bit1 == 1 or bit2 == 1) then
					final_bit = 1
				else
					final_bit = 0
				end
				
				value = value + (final_bit * 2 ^ (i-1))
			end
			
			return value
		end,
		NOT = function(self, byte1, size) 
			local value = 0
			for i = 1, size do
				local bit = (math.floor(byte1/(2^(i-1)))%2)
				local final_bit = 0
				
				if (bit == 1) then
					final_bit = 0
				else
					final_bit = 1
				end
				
				value = value + (final_bit * 2 ^ (i-1))
				
			end
			
			return value
		end,
		XOR = function(self, byte1, byte2, size)
			local value = 0
			for i = 1, size do
				local bit1, bit2 = (math.floor(byte1/(2^(i-1)))%2), (math.floor(byte2/(2^(i-1)))%2)
				local final_bit = 0
				
				if (bit1 == 1 and bit2 == 1) then
					final_bit = 0
				elseif(bit1 == 1 or bit2 == 1) then
					final_bit = 1
				else
					final_bit = 0
				end
				
				value = value + (final_bit * 2 ^ (i-1))
			end
			
			return value
		end,
		SHL = function(self, byte, shift)
			return byte * (2 ^ shift)
		end,
		SHR = function(self, byte, shift)
			return byte / (2 ^ shift)
		end,
		ROL = function(self, byte, shift, size)
			return self:OR(self:SHL(byte, shift), self:SHR(byte, shift), size)
		end,
		ROR = function(self, byte, shift, size)
			return self:OR(self:SHR(byte, shift), self:SHL(byte, shift), size)
		end
	}

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
				
				while (c > 0) do 
					buffer = {}
					temp = Parser.byte()
					buffer[1] = temp 
					
					print(temp, "cp_info")
					
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
						Parser.byte() -- trash it
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
					end
					
					cp_info[#cp_info + 1] = buffer 
					
					c = c - 1 
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
                        
                    buffer[6][3] = self:vertification_info_parser(buffer[6][1] - 251)
                    
                    
                    buffer[7] = {self.byte(), self.word(), self.word()}
                        
                    buffer[7][4] = self:vertification_info_parser(buffer[7][3])
                    buffer[7][5] = self.word()
                    buffer[7][6] = self:vertification_info_parser(buffer[7][4])
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
			        buffer[7] = {self.byte(), self.word()}
			        buffer[8] = {self.byte(), self.word()}
			        
			        
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
						ati[4] = self.dword()
						ati[5] = self.word()
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
					elseif (__string__ == "StackMapTable") then 
						ati[3] = self.word()
						ati[4] = self:StackMapTableParse(ati[3])
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
							buffer[#buffer + 1] = self.GetArray(2, 2)
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
					    print(__string__, "non existant")
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
				return getByteArrayFloat({get_erase(1, 4):byte(1, 4)})
			end]]
			
			Parser.GetAttribute = function(constant_pool, attributes, classname) 
				local picked
				--print(#attributes)
				for x = 1, #attributes do 
					local __string__ = JParser.UTF8(constant_pool[attributes[x][1]])
					--print(__string__, classname, "au")
					if (__string__ == classname) then 
						return attributes[x]
						--break
					end 
				end 
				--return picked
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
                    if (constant_pool[x] == classnumber) then 
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
		return block
	end 
	
	local function Stack(n)
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
	
	function local_list(n)
		local locals = newproxy(true)
		local l = getmetatable(locals)
		
		local function _nil_() end 
		
		local field = {}
		
		l.__index = function(self, index)
			
			if (field[index] == _nil_ or field[index] == nil) then 
				return nil 
			else 
				return field[index]
			end 
		end 
		l.__newindex = function(self, index, value)
			if (value == nil) then 
				value = _nil_
			end 
			
			field[index] = value
		end 
		
		return locals
	end 
	
	local function code_wrap(block)
		--local 
		print("nbytecode", #bytecode)
		local m = {
			GetBlock = function()
				return block 
			end,
			PrepareMethod = function(method_info)
			    local pmethod = {}
			    local code_segment = Parser.GetAttribute(block.constant_pool, method_info[5], "Code")
			    
			    pmethod.stack = Stack(code_segment[3])
			    pmethod.instructions = code_segment[6]
			    pmethod.n_stack = code_segment[3]
				pmethod.n_locals = code_segment[4]
			    
			    return pmethod
		    end,
			RunDebug = function(self)
			    local bootstrap = Parser.GetConstant(block.constant_pool, 18)
			    print(#bootstrap, "n bootstraps")
			    local bootstrap_methods = Parser.GetAttribute(block.constant_pool, block.attribute_info, "BootstrapMethod")
			    print(bootstrap_methods)
				------------------------------------------------------------------
				local methods = block.methods
				local fields = block.fields
				
				kprint(string.format("Num methods: %d", #methods))
				
				for x = 1, #methods do 
					kprint(string.format("Method name (%s)", JParser.UTF8(block.constant_pool[methods[x][2]])))
				
				end 
				kprint("asd", block.fields_count)
				kprint(string.format("Fields: (%d)", #fields))
				
				for x = 1, #fields do 
					kprint(string.format("Field name (%s)", JParser.UTF8(block.constant_pool[fields[x][2]])))
				end 
			    
				local Source = Parser.GetAttribute(block.constant_pool, block.attribute_info, "SourceFile")
				
				kprint(string.format("Source name (%s)", JParser.UTF8(block.constant_pool[Source[3]])))
			    
			end,
			Run = function(self)
		    end 
		    
		}
		
		return m
	end 
	
	assert(CheckCombatibility())
	return code_wrap(Blockify())
end

--commentmeant

function fetch(url)
	return game:GetService("HttpService"):GetAsync(url)
end 

function pure_fetch(filename)
    local file = io.open(filename, "r")
    local content = file:read("*a")
    file:close()
    return content 
end
kprint(string.format("[Code]\n\n%s\n\n[/Code]", fetch("https://preview.c9users.io/xxx_triangle_xxx/new_dev/test.java")))
local code = fetch("https://preview.c9users.io/xxx_triangle_xxx/new_dev/test.class")
--[[
kprint(string.format("[Code]\n\n%s\n\n[/Code]", pure_fetchv("Test.java")))
local code = pure_fetch("Test.class")]]
local _code_ = JVM(code)

_code_:RunDebug()