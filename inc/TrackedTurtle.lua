---------------------------------
-- PatOS - TrackedTurtle Class --
---------------------------------

API.Load("PVector3")
API.Load("Event")
API.Load("MathUtil")

local TrackedTurtle = { 
	--------------
	-- Movement --
	--------------
	__Move =  function(self, direction, moveFunc, inspectFunc, digFunc, attackFunc)
		self:CheckFuelLevels(1)
		
		while not moveFunc() do
			if inspectFunc() then
				digFunc(self)
			else
				attackFunc()
			end
			
			sleep(0.1)
		end
		
		self.position = self.position + direction
		self.onTransformChanged:Invoke(self)
	end,
	
	MoveUp = function(self)
		self:__Move(PVector3.New(0, 1, 0), turtle.up, turtle.detectUp, self.DigUp, turtle.attackUp)
	end,
	
	MoveDown = function(self)
		self:__Move(PVector3.New(0, -1, 0), turtle.down, turtle.detectDown, self.DigDown, turtle.attackDown)
	end,
	
	MoveForward = function(self)
		self:__Move(self.rotation, turtle.forward, turtle.detect, self.DigForward, turtle.attack)
	end,
	
	MoveTo = function(self, targetPosition)
		while self.position.y > targetPosition.y do self:MoveDown() end
		
		if not (self.position.x == targetPosition.x) then
			local direction = (PVector3.New(targetPosition.x, 0, 0) - PVector3.New(self.position.x, 0, 0)):Normalized()
			self:RotateTo(direction)
			while not (self.position.x == targetPosition.x) do self:MoveForward() end
		end
		
		if not (self.position.z == target.position.z) then
			local direction = (PVector3.New(0, 0, targetPosition.z) - PVector3.New(0, 0, self.position.z)):Normalized()
			self:RotateTo(direction)
			while not (self.position.z == target.position.z) do self:MoveForward() end
		end
		
		while self.position.y < targetPosition.y do self:MoveUp() end
	end,
	
	--------------
	-- Rotation --
	--------------
	__Rotate = function(self, radians, turnFunc) 
		local dirx = MathUtil.Round( self.rotation.x * math.cos( radians ) - self.rotation.z * math.sin( radians ) )
		local dirz = MathUtil.Round( self.rotation.x * math.sin( radians ) + self.rotation.z * math.cos( radians ) )
		
		if turnFunc() then
			dir = vector.new( dirx, 0, dirz )
			self.onTransformChanged:Invoke(self)
			return true
		end
	   
		return false
	end,
	
	
	RotateRight = function(self)
		self:__Rotate(-math.pi*0.5, turtle.turnRight)
	end,
	
	RotateLeft = function(self)
		self:__Rotate(math.pi*0.5, turtle.turnLeft)
	end,

	RotateTo = function(self, targetRotation)
		targetRotation = PVector3.New(MathUtil.Clamp(targetRotation.x, -1, 1), 0, MathUtil.Clamp(targetRotation.z, -1, 1))
		while not (self.rotation.x == targetRotation.x and self.rotation.z == targetRotation.z) do
			local cross = self.rotation:Cross(targetRotation)
			if cross.y >= 0 then 
				self:RotateRight() 
			else 
				self:RotateLeft() 
			end
		end
	end,
	
	---------------------
	-- Fuel Management --
	---------------------
	CheckFuelLevels = function(self, minimalAmount)
		minimalAmount = minimalAmount or 1
		while not self:HasFuel(minimalAmount) do 
			self.onRefuelRequired:Invoke(self)
		end
	end,
	
	HasFuel = function(self, minimalAmount)
		minimalAmount = minimalAmount or 1
		return turtle.getFuelLevel() > minimalAmount
	end,
	
	Refuel = function(self, slot, maxConsumeAmount)
		local consumeAmount = maxConsumeAmount or 99999
		local previousSelectedSlot = turtle.getSelectedSlot()
		turtle.select(slot)
		
		while turtle.getItemCount(slot) > 0 and turtle.getFuelLevel() < (turtle.getFuelLimit() - 1000) and consumeAmount > 0 and turtle.refuel() do -- 1000 is max fuel item
			consumeAmount = consumeAmount - 1
		end
		
		turtle.select(previousSelectedSlot)
	end,
	
	--------------------------
	-- Inventory Management --
	--------------------------
	__HasRoomForBlock = function(self, compareFunc)
		local previousSlot = turtle.getSelectedSlot()
		for i=1, 16 do 
			turtle.select(i)
			if turtle.getItemCount(i) == 0 or (compareFunc(i) and (turtle.getItemSpace(i) > 0)) then
				turtle.select(previousSlot)
				return true
			end
		end
		
		turtle.select(previousSlot)
		return false
	end,
	
	HasFreeSlot = function(self) 
		for i=1, 16 do
			if turtle.getItemCount(i) == 0 then
				return true
			end
		end
	end,
	
	HasRoomForBlockAbove = function(self)
		return self:__HasRoomForBlock(turtle.compareUp)
	end,
	
	HasRoomForBlockBelow = function(self)
		return self:__HasRoomForBlock(turtle.compareDown)
	end,
	
	HasRoomForBlockInFront = function(self)
		return self:__HasRoomForBlock(turtle.compare)
	end,
	
	--------------------
	-- Mining Utility --
	--------------------
	__Dig = function(self, digFunc, inventoryCheckFunc) 
		if not inventoryCheckFunc(self) then
			self.onNoRoomForNextBlock:Invoke(self)
		end
		
		digFunc()
	end,
	
	DigForward = function(self) 
		self:__Dig(turtle.dig, self.HasRoomForBlockInFront)
	end,
	
	DigUp = function(self)
		self:__Dig(turtle.digUp, self.HasRoomForBlockAbove)
	end,
	
	DigDown = function(self)
		self:__Dig(turtle.digDown, self.HasRoomForBlockBelow)
	end,
	
	----------------------
	-- Block Inspection --
	----------------------
	CanMineForward = function(self)
		return turtle.detect() and self:HasRoomForBlockInFront()
	end,
	
	CanMineUp = function(self)
		return turtle.detectUp() and self:HasRoomForBlockAbove() 
	end,
	
	CanMineDown = function(self)
		return turtle.detectDown() and self:HasRoomForBlockBelow()
	end,
	
	----------
	-- Misc --
	----------
	ToString = function(self) 
		return '[pos: ' .. self.position:ToString() .. ', rot: ' .. self.rotation:ToString() .. ']'
	end,
}

local TrackedTurtleMetatable = {
	__index = TrackedTurtle,
	__tostring = TrackedTurtle.ToString
}

function __CreateObject(pos, rot)
	return {
		position = pos or PVector3.New(0, 0, 0),
		rotation = rot or PVector3.New(0, 0, 1),
		onRefuelRequired = Event.New(),
		onNoRoomForNextBlock = Event.New(),
		onTransformChanged = Event.New()
	}
end

function New(startPosition, startRotation)
	local trackedTurtle = __CreateObject(startPosition, startRotation);
	setmetatable(trackedTurtle, TrackedTurtleMetatable)
	return trackedTurtle
end

function FromTable(t) 
	local trackedTurtle = __CreateObject(t.position, t.rotation)
	setmetatable(trackedTurtle, nil)
	setmetatable(trackedTurtle, TrackedTurtleMetatable)
	return trackedTurtle
end







