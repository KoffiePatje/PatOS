---------------------------------------
-- PatOS - Preferences Utility Class --
---------------------------------------

API.Load("FileIO")

local preferencePath = 'PatOS/saves/%s/preferences.save'
local t = {}

function Set(name, value)
	t[name] = value
end

function Get(name)
	return t[name]
end

function Save(name)
	local savePath = preferencePath:format(name)
	
	if not t == nil then 
		FileIO.WriteAllText(textutils.serialize(t), savePath);
	end
end

function Load(name)
	local loadPath = preferencePath:format(name)
	local fileContent = FileIO.ReadAllText(loadPath)
	
	if not (fileContent == nil) and not (fileContent == "") then
		t = textutils.unserialize(fileContent)
	end
end
