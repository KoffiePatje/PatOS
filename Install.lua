-- PatOS - Github Install Script 

local GITHUB_REST_API_BASE = "https://api.github.com";
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com"

-- Helper functions
function requestHttp(url)
	local request = http.get(url)
	local status = request.getResponseCode()
	local response = request.readAll()
	request.close()
	return status, response
end

function RecursiveGetGithubFiles(string baseUrl)
	-- Retrieve directory listing from the Github REST API
	local status, response = requestHttp(baseUrl)
	
	if not (status == 200) then
		print("Couldn't query github REST API for url: " .. baseUrl)
		return
	end
	
	
	local responseData = JSON.decode(response)
	
	for i=1, #responseData do
		local entry = responseData[i]
		if entry.type == 'file' then 
			print(entry.name)
		else if entry.type == 'dir' then
			RecursiveGetGithubFiles(entry.url)
		end
	end 
end

-- Retrieve JSON parser
local jsonStatus, jsonResponse = requestHttp(GITHUB_RAW_BASE .. 'KoffiePatje/PatOS/master/inc/JSON.lua')
if not (jsonStatus == 200) then
	print("Couldn't dowload JSON lib..")
	shell.exit();
else
	print("Succesfully retrieved JSON library");
end

-- Store JSON lib at temporary location
if fs.exists('Temp') then
    fs.makeDir('Temp')
end

local file = fs.open('Temp/JSON', 'w')
file.write(jsonResponse);
file.close();

-- Load JSON API
os.loadAPI('Temp/JSON');

-- See what Repository we are targeting (aka read command line)
local repo, tree = select(1, ...)

if not tree then
	tree = repo or 'master'
end

if not repo then
	repo = 'KoffiePatje/PatOS'
end

SyncGitDirectory(GITHUB_REST_API_BASE .. '/repos/' .. repo .. '/contents')

