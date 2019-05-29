-----------------------------------
-- PatOS - File IO Utility Class --
-----------------------------------

function ReadAllText(path) 
	if not fs.exists(path) then
		print("[FileIO] Unable to find file at '" .. path .. "'")
		return ""
	end
	
	local file = fs.open(path, 'r')
	local fileContent = file.readAll()
	file.close()

	return fileContent
end

function WriteAllText(data, path)
	local file = fs.open(path, 'w')
	file.write(data)
	file.close()
end

function GetFilePathWithoutExtension(filePath)
	local i = nil;
	
	repeat
		local i = string.find(filePath, '.', i, true)
	until(i == nil)
	
	return string.sub(filePath, 0, i)
end