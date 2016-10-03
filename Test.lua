

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
print(table.foreach(java(content), print))