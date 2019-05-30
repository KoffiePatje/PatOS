-------------------------------------------------
-- PatOS - Command Line Argument Utility Class --
-------------------------------------------------

local args = {...}
local argsNameToIndex = {}
local argCount = 0

for i=1, args do 
	argCount = argCount + 1
	argsNameToIndex[args[i]] = i
end


function GetArgument(index)
	return args[index]
end

function GetArgumentValue(identifier)
	local argIndex = argsNameToIndex[identifier]
	
	if argIndex == nil then return nil end
	
	return args[argIndex]
end

function GetArgumentValues(identifier, count)
	local argIndex = argsNameToIndex[identifier]
	
	if argIndex == nil then return nil end
	
	returnValues = {}
	
	for i=1, count, +1 do
		table.insert(returnValues, i, args[argIndex + i]
	end
	
	return returnValues
end
