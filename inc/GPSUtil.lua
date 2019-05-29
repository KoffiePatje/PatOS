API.Load("PVector3")
API.Load("TrackedTurtle")

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

function TryGetGPSTrackedTurtle(timeOut)
	local to = timeOut or 3
	local x, y, z = gps.locate(to)
	
	if not x then
		return false, TrackedTurtle.New()
	end
	
	local startPosition = PVector3.New(x, y, z)
	
	while not turtle.forward() do
		if turtle.detect() then 
			turtle.dig() 
		else
			turtle.attack()
		end
		sleep(0.1)
	end
	
	local samplePosition = gps.locate(to)
	turtle.backward()
	
	if startPosition == samplePosition then
		return false, TrackedTurtle.New()
	end
	
	local rotation = samplePosition - startPosition;
	return TrackedTurtle.New(position1, rotation)
end