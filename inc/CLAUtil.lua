-------------------------------------------------
-- PatOS - Command Line Argument Utility Class --
-------------------------------------------------

local args = {}
local argsNameToIndex = {}

function SetArguments(arguments)
	args = arguments
	for i=1, #args do 
		argsNameToIndex[args[i]] = i
	end
end

function GetArgument(index)
	return args[index]
end

function GetArgumentValue(identifier)
	local argIndex = argsNameToIndex[identifier]
	
	if argIndex == nil then return nil end
	
	return args[argIndex + 1]
end

function GetArgumentValues(identifier, count)
	local argIndex = argsNameToIndex[identifier]
	
	if argIndex == nil then return nil end
	
	local returnValues = {}
	
	for i=1, count, 1 do
		table.insert(returnValues, i, args[argIndex + i])
	end
	
	return returnValues
end
