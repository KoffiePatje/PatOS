-- PatOS - Github Install Script 

local GITHUB_REST_API_BASE = "https://api.github.com/";
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/"

-- Helper functions
function requestHttp(url) {
	local requestResult = http.get(url)
	local status = request.getResponseCode()
	local response = request.readAll()
	request.close()
	return status, response
}

-- Retrieve JSON parser
local jsonStatus, jsonResponse = requestHttp(GITHUB_RAW_BASE .. 'KoffiePatje/PatOS/master/inc/JSON.lua').readAll()
if jsonStatus not 200 then
	os.print("Couldn't dowload JSON lib..")
	shell.exit();
end

loadstring(jsonResponse);

-- See what Repository we are targeting (aka read command line)
local repo, tree = select(1, ...)

if not tree then
	tree = repo or 'master'
end

if not repo then
	repo = 'KoffiePatje/PatOS'
end


local status, response = requestHttp(GITHUB_REST_API_BASE .. repo .. '/contents')
if status not 200 then 
	os.print("Couldn't query github REST API") 
	shell.exit();
end

local responseData = decode(response)

for entry in responseData do
	if string.find(entry.name, '.lua') then
		os.print(entry.name)
	end
end

