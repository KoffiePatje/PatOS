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
	local lastDotIndex = string.len(filePath)
	local i = -1;
	
	repeat
		i = string.find(filePath, '.', i + 1, true)
		if not (i == nil) then 
			lastDotIndex = i 
		end
	until(i == nil)
	
	return string.sub(filePath, 0, lastDotIndex)
end
