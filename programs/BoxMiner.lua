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
local yDirection = nil
local droppingToChest = false
local startPosition = nil
local startRotation = nil

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

function GetBoxSizeFromInput() 
	local number = nil
	local size = PVector3.New()
	
	print('x: ')
	repeat size.x = Input.GetNumberInput() until not (size.x == nil)
	print('y: ')
	repeat size.y = Input.GetNumberInput() until not (size.y == nil)
	print('z: ')
	repeat size.z = Input.GetNumberInput() until not (size.z == nil)
	
	return size
end

function TryGetBoxSizeFromCLA()
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
	--print("Moved "..turtle:ToString());
end

-- Make sure to refuel when needed, throw error message if out of fuel and keep polling for new fuel each 
function OnTurtleRefuelRequired(turtle)
	while not turtle:HasFuel() do 
		turtle:Refuel(16)
		if not turtle:HasFuel() then
			print("Couldn't refuel, please supply fuel in the 16th slot and then press C to retry")
			Input.WaitForKey(keys.c)
		end
	end
end

-- We saveguard the DropItemsInChest in case this gets called why moving towards the chest, simply ignore it and let 1 block get away
function OnTurtleNoRoomForNextBlock(turtle)
	print("No room for next block")
	if not droppingToChest then
		droppingToChest = true
		DropItemsInChest()
		droppingToChest = false
	end
end

------------
-- Mining --
------------
function Mine(mineUp, mineDown, mineForward)
	local didDigSomething;
	
	repeat
		didDigSomething = false
		
		if mineDown and myTurtle:CanMineDown() then
			myTurtle:DigDown()
			didDigSomething = true
		end
		
		if mineUp and myTurtle:CanMineUp() then
			myTurtle:DigUp()
			didDigSomething = true
		end
		
		if mineForward and myTurtle:CanMineForward() then
			myTurtle:DigForward()
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
		if lastRow then
			Mine(mineUp, mineDown, false) -- Last position we won't mine forward
		else 
			Mine(mineUp, mineDown, true)
			myTurtle:MoveForward()
		end
	end
end

function MineLayer(cornerPosA, cornerPosB, mineUp, mineDown)
	if not (cornerPosA.y == cornerPosB.y) then error ("Same Y level expected for both input corners") end
	if not (myTurtle.position.y == cornerPosA.y) then error("Same Y level expected for the turtle and the corners...") end
	
	local minX = math.min(cornerPosA.x, cornerPosB.x)
	local minZ = math.min(cornerPosA.z, cornerPosB.z)
	local maxX = math.max(cornerPosA.x, cornerPosB.x)
	local maxZ = math.max(cornerPosA.z, cornerPosB.z)
	
	if not (myTurtle.position.x == minX or myTurtle.position.x == maxX) then error("At least one of the corners should share the same X coordinate") end
	if not (myTurtle.position.z == minZ or myTurtle.position.z == maxZ) then error("At least one of the corners should share the same Z coordinate") end
	
	local targetX = (myTurtle.position.x == minX) and maxX or minX
	local targetZ = (myTurtle.position.z == minZ) and maxZ or minZ
	
	local distanceX = maxX - minX;
	local distanceZ = maxZ - minZ;
	
	local targetDirectionX = MathUtil.Clamp(targetX - myTurtle.position.x, -1, 1)
	local targetDirectionZ = MathUtil.Clamp(targetZ - myTurtle.position.z, -1, 1)
	
	-- Let's prefer the longest lane direction
	local targetDirection, turnDirection, rowLength, rowCount
	if (distanceX >= distanceZ) then
		targetDirection = PVector3.New(targetDirectionX, 0, 0)
		turnDirection = PVector3.New(0, 0, targetDirectionZ)
		rowLength = distanceX + 1
		rowCount = distanceZ + 1
	else
		targetDirection = PVector3.New(0, 0, targetDirectionZ)
		turnDirection = PVector3.New(targetDirectionX, 0, 0)
		rowLength = distanceZ + 1
		rowCount = distanceX + 1
	end
	
	-- Let's prefer the X direction
	myTurtle:RotateTo(targetDirection)
	
	for i=1, rowCount do
		MineRow(rowLength, mineUp, mineDown)
		
		-- Turn corner
		if not (i == rowCount) then
			local previousDirection = myTurtle.rotation
			myTurtle:RotateTo(turnDirection)
			MineRow(2, false, false)
			myTurtle:RotateTo(-previousDirection)
		end
	end	
end

function MineBox(cornerPosA, cornerPosB)
	if not (myTurtle.position == cornerPosA) and not (myTurtle.position == cornerPosB) then error("None of the start corners relate to our current position") end
	local targetCorner = (myTurtle.position == cornerPosA) and cornerPosB or cornerPosA
	
	print('Mining Box: '..cornerPosA:ToString()..', '..cornerPosB:ToString())
	
	-- Bounds are always relative
	local yDelta = (targetCorner.y - myTurtle.position.y) + 1;
	local yDistance = math.abs(yDelta)
	yDirection = MathUtil.Clamp(yDelta, -1, 1)
	
	local minY = math.min(cornerPosA.y, cornerPosB.y)
	local maxY = math.max(cornerPosA.y, cornerPosB.y)
		
	-- Compute the numbers of steps we have to take
	local ySteps = math.floor((yDistance + 2) / 3)
	
	for i=1, ySteps do
		-- Compute the desired Y
		local desiredY = MathUtil.Clamp(((i - 1) * (yDirection * 3)) + yDirection, minY, maxY)
		print('desiredY: '..desiredY)
		
		-- Let's move to that Y
		while not (myTurtle.position.y == desiredY) do
			Mine(true, false, false)
			if yDirection > 0 then myTurtle:MoveUp() else myTurtle:MoveDown() end
			print('newY: '..myTurtle.position.y)
		end
		
		-- Let's start mining the Layer
		local mineDown = ((desiredY - 1) >= minY)
		local mineUp = ((desiredY + 1) <= maxY)
		MineLayer(PVector3.New(cornerPosA.x, desiredY, cornerPosA.z), PVector3.New(cornerPosB.x, desiredY, cornerPosB.z), mineUp, mineDown)
	end
end

--------------------------
-- Inventory Management --
--------------------------
function DropItemsInChest()
	local currentPosition = myTurtle.position
	local currentRotation = myTurtle.rotation
	
	myTurtle:MoveTo(startPosition, -yDirection)
	myTurtle:RotateTo(-startRotation)
	
	AttemptToFuelWithAnythingFromInventory()
	AttemptToDropAnythingInInventory()
	
	myTurtle:MoveTo(currentPosition, -yDirection)
	myTurtle:RotateTo(currentRotation)
end

function AttemptToFuelWithAnythingFromInventory()
	local i = 1
	while i <= 16 and myTurtle:HasRoomForMoreFuel() do
		myTurtle:Refuel(i)
		i = i + 1
	end
end

function AttemptToDropAnythingInInventory() 
	local previousSlot = turtle.getSelectedSlot()
	
	while not turtle.detect() do 
		print("No block in front of the turtle, did you forget to place a chest? Resolve the situation and press C to retry")
		Input.WaitForKey(keys.c)
	end
	
	for i=1, 16 do
		if turtle.getItemCount(i) > 0 and turtle.select(i) then
			while not turtle.drop() do
				print("Couldn't drop item, perhaps the inventory is full, resolve the situation and press C to retry")
				Input.WaitForKey(keys.c)
			end
		end
	end
	turtle.select(previousSlot)
end

-------------
-- Startup --
-------------
function Main()
	-- Create/Retrieve TrackedTurtle
	myTurtle = InitializeTurtle()
	
	-- Get Box Bounds
	local retrievedSizeFromCLA, boxSize = TryGetBoxSizeFromCLA()
	if not retrievedSizeFromCLA then
		boxSize = GetBoxSizeFromInput()
	end
	
	startPosition = myTurtle.position
	startRotation = myTurtle.rotation
	
	-- Let's start mining that sucker!
	MineBox(myTurtle.position, myTurtle.position + (boxSize - PVector3.New(1, 1, 1))) --subtract 1 from all directions since we're dealing with size and we count the block that the turtle is currently on
	
	-- Let's finish up
	myTurtle:MoveTo(startPosition, -yDirection)
	DropItemsInChest()
	myTurtle:RotateTo(startRotation)
end

Main()
