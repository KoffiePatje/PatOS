os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("PVector2")

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

function GetTreeFarmGridSizeFromInput()
	local grid = PVector2.New()
	local spacing = PVector2.New()
	
	print('colums (forward):')
	repeat grid.x = Input.GetNumberInput() until not (grid.x == nil)
	print('rows (sideways):')
	repeat grid.y = Input.GetNumberInput() until not (grid.y == nil)
	
	print('column spacing:')
	repeat spacing.x = Input.GetNumberInput() until not (spacing.x == nil)
	print('row spacing:')
	repeat spacing.y = Input.GetNumberInput() until not (spacing.y == nil)
	
	return grid, spacing
end

function GetTreeFarmGridSizeFromCLA()
	local grid = nil
	local spacing = nil 
	
	local values = CLAUtil.GetArgumentValues("-grid", 2)
	if not (values == nil) then 
		grid = PVector2.New(tonumber(values[1]), tonumber(values[2]))
	else
		print('false')
		return false
	end
	
	values = CLAUtil.GetArgumentValues("-spacing", 2)
	if not (values == nil) then
		spacing = PVector2.New(tonumber(values[1]), tonumber(values[2]))
	else
		print("Spacing not defined, using default values of 2")
		spacing = PVector2.New(2, 2)
	end
	
	return true, grid, spacing
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
		turtle:Refuel(15)
		if not turtle:HasFuel() then
			print("Couldn't refuel, please supply fuel in the 15th slot and then press C to retry")
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
function IsLog(blockData)
	local name = blockData.name
	local i = name:find(':', 0, true)
	
	if i == nil then error("Expected all Item names to have a ':', it was not the case for the following name "..name) end
	
	-- Let's find any occurence of logs and then check the following conditions;
	-- 1: it was preceded by either ':', '.' or '_'
	-- 2: it was followed by an optional 's' and then either '.', '_' or '<end of string>' 
	repeat
		i = name:find('log', i + 1, true)
		
		-- Check if it meets the log conditions
		if not (i == nil) then
			local frontChar = name:byte(i-1)
			local frontCharValid = (frontChar == (':'):byte() or frontChar == ('.'):byte() or frontChar == ('_'):byte())
			
			if frontCharValid then
				local followingCharIdx = (name:byte(i+3) == ('s'):byte()) and i+3 or i+4
				local followingChar = name:byte(followingCharIdx)
				local followingCharValid = (followingCharIdx > name:len() or followingChar == ('.'):byte() or followingChar == ('_'):byte())
				
				if followingCharValid then
					return true
				end
			end
		end
	until(i == nil)
	
	return false
end

function IsSapling(itemName)
	local i = itemName:find(':', 0 , true)
	return not (itemName:find('sapling', i, true) == nil)
end

function IsSaplingInSlot(slotNumber)
	return turtle.getItemCount(slotNumber) > 0 and IsSapling(turtle.getItemDetail(slotNumber).name)
end

function MineTree()
	myTurtle:DigForward()
	myTurtle:MoveForward()
	
	local startPosition = myTurtle.position
	
	local isBlockBelow, blockBelowData = turtle.inspectDown()
	if isBlockBelow and IsLog(blockBelowData) then
		myTurtle:DigDown()
	end

	local isBlockAbove, blockAboveData
	repeat
		isLogAbove, blockAboveData = turtle.inspectUp()
		if isLogAbove and IsLog(blockAboveData) then
			myTurtle:DigUp()
			myTurtle:MoveUp()
		else
			isLogAbove = false
		end
	until not isLogAbove
	
	myTurtle:MoveTo(startPosition)
	PlantSapling()
end

function OutOfSaplingsInSlot16()
	for i=1, 15 do
		if IsSaplingInSlot(i) then
			turtle.select(i)
			turtle.transferTo(16)
		end
	end
	
	while not IsSaplingInSlot(16) do
		print("Unable to resolve state, no more sapplings would fit in spot 16 or we simply ran out of them, please fix the state and press C to continue")
		Input.WaitForKey(keys.c)
	end
end

function PlantSapling()
	local previousSlot = turtle.getSelectedSlot()
	while not IsSaplingInSlot(16) do
		OutOfSaplingsInSlot16()
	end
	
	turtle.select(16)
	turtle.placeDown()
	turtle.select(previousSlot)
end

function ProcessTreeSpot()
	local isBlockInFront, blockData = turtle.inspect()
	if isBlockInFront and IsLog(blockData) then 
		MineTree()
	else
		myTurtle:MoveForward()
		PlantSapling()
	end
end

function IsTreeSpot(position, gridStartPosition, grid, spacing)
	local extendA = gridStartPosition
	local extendB = gridStartPosition + PVector3.New(((spacing.x + 1) * (grid.x - 1)) + 1, 0, ((spacing.y + 1) * (grid.y - 1)) + 1)
	
	if not (position.x >= extendA.x and position.x <= extendB.x and position.z >= extendA.z and position.z <= extendB.z) then 
		return false 
	end
	
	local delta = position - gridStartPosition
	
	local xRemainder = delta.x % (spacing.x + 1)
	local zRemainder = delta.z % (spacing.y + 1)
	
	return xRemainder == 0 and zRemainder == 0
end

function ProcessColumn(forwardLength, gridStartPosition, grid, spacing)
	for i=1, forwardLength do
		local targetPosition = myTurtle.position + myTurtle.rotation
		
		if IsTreeSpot(targetPosition, gridStartPosition, grid, spacing) then
			ProcessTreeSpot()
		else
			if not (i == forwardLength) then
				myTurtle:MoveForward()
			end
		end
		
		turtle.suckDown()
	end
end

function StartRound(grid, spacing)
	local stationPosition = myTurtle.position;
	local stationRotation = myTurtle.rotation;
	
	local gridStartPosition = stationPosition + PVector3.New(0, 0, 1)
	
	local startCorner = stationPosition - PVector3.New(2, 0, 1) -- offset to -2, 0, -2 from gridStart
	local endCorner = gridStartPosition + PVector3.New(((spacing.x + 1) * (grid.x - 1)) + 1, 0, ((spacing.y + 1) * (grid.y - 1)) + 1) + PVector3.New(2, 0, 2)
	
	myTurtle:MoveTo(startCorner)
	myTurtle:RotateTo(stationRotation)
	turtle.select(16)
	
	local targetDirectionX = MathUtil.Clamp(endCorner.x - myTurtle.position.x, -1, 1)
	local targetDirectionZ = MathUtil.Clamp(endCorner.z - myTurtle.position.z, -1, 1)
	
	local columnLength = math.abs(endCorner.z - startCorner.z)
	local rowCount = math.abs(endCorner.x - startCorner.x)
		
	for i=1, rowCount do
		ProcessColumn(columnLength, gridStartPosition, grid, spacing)
		
		if not (i == rowCount) then
			local previousZDirection = myTurtle.rotation.z
			myTurtle:RotateTo(PVector3.New(targetDirectionX, 0, 0))
			ProcessColumn(2, gridStartPosition, grid, spacing)
			myTurtle:RotateTo(PVector3.New(0, 0, -previousZDirection))
		end
	end
end

--------------------------
-- Inventory Management --
--------------------------
function DropItemsInChest()
	local currentPosition = myTurtle.position
	local currentRotation = myTurtle.rotation
	
	myTurtle:MoveTo(startPosition)
	
	AttemptToFuelWithAnythingFromInventoryButLogsAndSaplings()
	AttemptToDropAnythingInInventory()
	
	myTurtle:MoveTo(currentPosition)
	myTurtle:RotateTo(currentRotation)
end

function AttemptToFuelWithAnythingFromInventoryButLogsAndSaplings()
	local i = 1
	while i <= 15 and myTurtle:HasRoomForMoreFuel() do
		if turtle.getItemCount(i) > 0 then
			local itemData = turtle.getItemDetail(i)
			if not IsLog(itemData) and not IsSapling(itemData.name) then
				myTurtle:Refuel(i)
			end
		end
		
		i = i + 1
	end
end

function AttemptToDropAnythingInInventory() 
	local previousSlot = turtle.getSelectedSlot()
	for i=1, 15 do
		if turtle.getItemCount(i) > 0 and turtle.select(i) then
			while not turtle.dropUp() do
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
	local retrievedCLA, grid, spacing = GetTreeFarmGridSizeFromCLA()
	if not retrievedCLA then
		boxSize, spacing = GetTreeFarmGridSizeFromInput()
	end
	
	startPosition = myTurtle.position
	startRotation = myTurtle.rotation
	
	local shouldExit = false
	local roundStartTime, roundEndTime
	local waitTimeBetweenRoundsInSeconds = 180
	
	while not shouldExit do
		-- Record start of the round 
		roundStartTime = os.clock()
	
		-- Let's start mining that sucker!
		StartRound(grid, spacing) --subtract 1 from all directions since we're dealing with size and we count the block that the turtle is currently on
		
		-- Let's finish up
		myTurtle:MoveTo(startPosition)
		myTurtle:RotateTo(startRotation)
		DropItemsInChest()
		
		roundEndTime = os.clock()
		
		print('------------------------------')
		print('Finished round in '..(roundEndTime - roundStartTime)..'s')
		print('Hold C to start a new round immidiately, or Hold T to exit')
		print('------------------------------')
		
		local startNewRoundTimer = os.startTimer(waitTimeBetweenRoundsInSeconds)
		
		while true do
			local event, parameter = os.pullEvent()
			if event == "key" then
				if parameter == keys.t then 
					shouldExit = true
					break
				elseif parameter == keys.c then
					os.cancelTimer(startNewRoundTimer)
					break
				end
			elseif event == "timer" and parameter == startNewRoundTimer then
				print('Timer ran out, starting new round!')
				print('------------------------------')
				break
			end
		end
	end
end

Main()
