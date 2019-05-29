local preferencePath = 'PatOS/saves/%s/preferences.save'
local t = {}

function set(name, value)
	if not t[name] then 
		t.insert(name, value)
	else
		t[name] = value
	end
end

function get(name, value)
	return t[name]
end

function save(name)
	local savePath = preferencePath.format(name)
	local file = fs.open(savePath, 'w')
	file.write(textutils.serialize(t))
	file.close()
end

function load(name) {
	local loadPath = preferencePath.format(name)
	local file = fs.open(loadPath, 'r')
	local fileContent = file.readAll()
	file.close()
	
	t = textutils.unserialize(fileContent)
}

load()