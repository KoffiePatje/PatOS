os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("TrackedTurtle")
API.Load("GPSUtil")
API.Load("Input")
API.Load("CLAUtil")

CLAUtil.SetArguments({...})

local gpsSupported = false

function InitializeTurtle()
	local gpsSupported, newTurtle = GPSUtil.TryGetGPSTrackedTurtle(3)
	if gpsSupported then 
		print('GPS supported, using global coordinate system!')
	else
		print('GPS not Supported, using local coordinate system!')
	end
	
	return newTurtle
end

function GetBoxBoundsFromInput() 
	local number = nil
	local bounds = PVector3.New()
	
	print('x: ')
	repeat bounds.x = Input.GetNumberInput() until not (bounds.x == nil)
	print('y: ')
	repeat bounds.y = Input.GetNumberInput() until not (bounds.y == nil)
	print('z: ')
	repeat bounds.z = Input.GetNumberInput() until not (bounds.z == nil)
	
	return bounds
end

function TryGetBoxBoundsFromCLA()
	local values = CLAUtil.GetArgumentValues("-box", 3)
	if values == nil then 
		return false, nil 
	end
	
	local x = tonumber(values[1])
	local y = tonumber(values[2])
	local z = tonumber(values[3])
	
	if x == nil or y == nil or z == nil then
		return false, nil
	else		
		return true, PVector3.New(x, y, z)
	end
end

function OnTurtleTransformChanged(turtle)
	print("I Changed!")
end

function OnTurtleRefuelRequired(turtle)
	print("Requires Refuel")
	turtle:Refuel(16)
end

function Main()
	-- Create/Retrieve TrackedTurtle
	local myTurtle = InitializeTurtle()
	
	-- Get Box Bounds
	local retrievedBoundsFromCLA, boxBounds = TryGetBoxBoundsFromCLA()
	if not retrievedBoundsFromCLA then
		boxBounds = GetBoxBoundsFromInput()
	end
	
	print(myTurtle)
	print(boxBounds)
		
	myTurtle.onTransformChanged:Subscribe(OnTurtleTransformChanged)
	myTurtle.onRefuelRequired:Subscribe(OnTurtleRefuelRequired)
	
	print('Moving Forward')
	myTurtle:MoveForward()
	
end

Main()
