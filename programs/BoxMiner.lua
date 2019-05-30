os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("TrackedTurtle")
API.Load("GPSUtil")
API.Load("Input")
API.Load("CLAUtil")
API.Load("MathUtil")

CLAUtil.SetArguments({...})

local myTurtle = nil
local gpsSupported = false

----------------
-- Initialize --
----------------
function InitializeTurtle()
	local gpsSupported, newTurtle = GPSUtil.TryGetGPSTrackedTurtle(3)
	if gpsSupported then 
		print('GPS supported, using global coordinate system!')
	else
		print('GPS not Supported, using local coordinate system!')
	end
				
	newTurtle.onTransformChanged:Subscribe(OnTurtleTransformChanged)
	newTurtle.onRefuelRequired:Subscribe(OnTurtleRefuelRequired)
	newTurtle.onNoRoomForNextBlock:Subscribe(OnTurtleNoRoomForNextBlock)
	
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

--------------------
-- Event Handlers --
--------------------
function OnTurtleTransformChanged(turtle)
	print("Moved "..turtle:ToString());
end

-- Make sure to refuel when needed, throw error message if out of fuel and keep polling for new fuel each 
function OnTurtleRefuelRequired(turtle)
	while not turtle:HasFuel() do 
		turtle:Refuel(16)
		if not turle:HasFuel() then
			print("Couldn't refuel, please supply fuel in slot 16 and then press C to retry")
			Input.WaitForKey('c')
		end
	end
end

function OnTurtleNoRoomForNextBlock(turtle)
	print("No room for next block")
end

------------
-- Mining --
------------
function Mine(mineUp, mineDown, mineForward)
	local didDigSomething;
	
	repeat
		didDigSomething = false
		
		if mineDown and myTurtle:CanDigDown() then
			myTurtle:DigDown()
			didDigSomething = true
		end
		
		if mineUp and myTurtle:CanDigUp() then
			myTurtle:DigUp()
			didDigSomething = true
		end
		
		if mineForward and myTurtle:CanDigForward() then
			myTurtle:DigFoward()
			didDigSomething = true
		end
		
		if didDigSomething then 
			sleep(0.1) 
		end
	until not didDigSomething
end

function MineRow(forwardLength, mineUp, mineDown)
	for i=1, forwardLength do
		local lastRow = (i == forwardLength)
		Mine(mineUp, mineDown, lastRow) -- Last position we won't mine forward
		
		if not lastRow then 
			myTurtle:Forward() 
		end
	end
end

function MineLayer(cornerPosA, cornerPosB, mineUp, mineDown)
	if not (cornerPosA.y == cornerPosB.y) then error ("Same Y level expected for both input corners") end
	if not (myTurtle.position.y == cornerPosA.y) then error("Same Y level expected for the turtle and the corners...") end
	
	local minX = math.min(cornerPosA.x, cornerPosB.x)
	local minZ = math.min(cornerPosA.z, cornerPosB.z)
	local maxX = math.min(cornerPosA.x, cornerPosB.x)
	local maxZ = math.min(cornerPosA.z, cornerPosB.z)
	
	if not (myTurtle.position.x == minX or myTurtle.position.x == maxX) then error("At least one of the corners should share the same X coordinate") end
	if not (myTurtle.position.z == minZ or myTurtle.position.z == maxZ) then error("At least one of the corners should share the same Z coordinate") end
	
	local targetX
	if myTurtle.position.x == minX then targetX = maxX else targetX = minX end
	
	local targetZ
	if myTurtle.position.z == minZ then targetZ = maxZ else targetZ = minZ end
	
	local targetDirectionX = MathUtil.Clamp(targetX - myTurtle.position.x, -1, 1)
	local targetDirectionZ = MathUtil.Clamp(targetZ - myTurtle.position.z, -1, 1)
	
	-- Let's prefer the X direction
	myTurtle.RotateTo(PVector3.New(targetDirectionX, 0, 0))
	local rowLength = maxX - minX + 1; -- We count the current position aswell
	local rowCount = maxZ - minZ + 1;
	
	for i=1, rowCount do
		MineRow(rowLength, mineUp, mineDown)
		
		-- Turn corner
		if not (i == rowCount) then
			local previousXDirection = myTurtle.rotation.x
			myTurtle:RotateTo(PVector3.New(0, 0, targetDirectionZ))
			MineRow(2, false, false)
			myTurtle:RotateTo(PVector3.New(-previousXDirection, 0, 0))
		end
	end	
end

function MineBox(cornerPosA, cornerPosB)
	if not (myTurtle.position == cornerPosA) and not (myTurtle.position == cornerPosB) then error("None of the start corners relate to our current position") end
	local targetCorner = (myTurtle.position == cornerPosA) and cornerPosA or cornerPosB
	
	-- Bounds are always relative
	local yDelta = (targetCorner.y - myTurtle.position.y);
	local yDistance = math.abs(yDelta)
	local yDirection = MathUtil.Clamp(yDelta, -1, 1)
	
	local minY = math.min(cornerPosA.y, cornerPosB.y)
	local maxY = math.max(cornerPosA.y, cornerPosB.y)
	
	-- Compute the numbers of steps we have to take
	local ySteps = math.floor((yDistance + 2) / 3)
	
	for i=1, ySteps do
		-- Compute the desired Y
		local desiredY = MathUtil.Clamp(((i - 1) * (yDirection * 3)) + yDirection, minY, maxY)
		
		-- Let's move to that Y
		while not myTurtle.position.y == desiredY do
			Mine(true, false, false)
			if yDirection > 0 then myTurtle.MoveUp() else myTurtle.MoveDown() end
		end
		
		-- Let's start mining the Layer
		local mineDown = ((desiredY - 1) >= minY)
		local mineUp = ((desiredY + 1) <= maxY)
		MineLayer(PVector3.New(cornerPosA.x, desiredY, cornerPosA.z), PVector3.New(cornerPosB.x, desiredY, cornerPosB.z), mineUp, mineDown)
	end
end

-------------
-- Startup --
-------------
function Main()
	-- Create/Retrieve TrackedTurtle
	myTurtle = InitializeTurtle()
	
	-- Get Box Bounds
	local retrievedBoundsFromCLA, boxBounds = TryGetBoxBoundsFromCLA()
	if not retrievedBoundsFromCLA then
		boxBounds = GetBoxBoundsFromInput()
	end
	
	-- Let's start mining that sucker!
	MineBox(myTurtle.position, myTurtle.position + boxBounds)
end

Main()
