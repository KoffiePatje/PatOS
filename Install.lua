-- PatOS - Github Install Script 

local GITHUB_REST_API_BASE = "https://api.github.com";
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com"

local GITHUB_TREE = 'master'
local GITHUB_REPO = 'KoffiePatje/PatOS'

local PROJECT_DIRECTORY = "PatOS"

-- Helper functions
function requestHttp(url)
	local request = http.get(url)
	local status = request.getResponseCode()
	local response = request.readAll()
	request.close()
	return status, response
end

function RecursiveGetGithubFiles(baseUrl)
	local status, response = requestHttp(baseUrl)
	
	if not (status == 200) then
		print("Couldn't query github REST API for url: " .. baseUrl)
		return
	end
	
	local responseData = JSON.decode(response)
	
	for i=1, #responseData do
		local entry = responseData[i]
		if entry.type == 'file' then 
			if string.find(entry.name, '.lua') then
				RetrieveGithubFile(entry)
			else
				print('Skipping non-lua file ' .. entry.name)
			end
		elseif entry.type == 'dir' then
			RecursiveGetGithubFiles(entry.url)
		end
	end 
end

function RetrieveGithubFile(entry) 
	local path = entry.path;
	local downloadUrl = entry.download_url;
	
	local status, response = requestHttp(downloadUrl)
	
	if not (status == 200) then
		print("Unable to retrieve file " .. path .. " from url: " .. downloadUrl)
		return
	end
	
	local savePath = PROJECT_DIRECTORY .. '/' .. path;
	
	if fs.exists(savePath) then 
		fs.delete(savePath)
	end
	
	local file = fs.open(savePath, "w")
	file.write(response)
	file.close()
	
	print('Succesfully retrieved ' .. path);
end


-- Retrieve JSON parser
local jsonStatus, jsonResponse = requestHttp(GITHUB_RAW_BASE .. '/KoffiePatje/PatOS/master/inc/JSON.lua')
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

-- Sync Github Directory
RecursiveGetGithubFiles(GITHUB_REST_API_BASE .. '/repos/' .. GITHUB_REPO .. '/contents')

