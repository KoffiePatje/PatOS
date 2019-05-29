API.Load("PVector3")

function IsGPSAvailable(timeOut)
	local to = timeOut or 3
	local x, y, z = gps.locate(to)
	
	if not x then
		return false
	else 
		return true
	end
end

function TryGetGPSPosition(timeOut)
	local to = timeOut or 3
	local x, y, z = gps.locate(to)
	
	if not x then
		return false, PVector3.New(0, 0, 0)
	else 
		return true, PVector3.New(x, y, z)
	end
end