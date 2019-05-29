local loadedAPIs = {}

function Load(apiName)
	if not loadedAPIs[apiName] then
		os.loadAPI('PatOS/inc/' .. apiName)
	end
end