

function ReadFile(filepath)
  local file = io.open(filepath, "r")
  if (not file) then return nil end 
  
  local content = file:read("*a")
  
  io.close(file)
  
  
  return content
end

local content = ReadFile("Test.class")
if (not content) then
  print("Couldn't get bytcode111")
  os.exit(1)
end

local java = require("Main")
local content = java(content)

local methods = content.Debugger:GetMethods()

print("Methods", "|", "Grammar")
table.foreach(methods, function(a, b)
   print(b[1], "|", b[2])
end)

local init  = content.Debugger:GetMethod("<init>")
local code_attribute = content.Debugger:GetAttribute(init[5], "Code")

table.foreach(code_attribute[6], function(a, b) 
	print(tonumber(b:byte(1,1)))
end)