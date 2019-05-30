---------------------------------
-- PatOS - TrackedTurtle Class --
---------------------------------

API.Load("PVector3")

local TrackedTurtle = { 
	--------------
	-- Movement --
	--------------
	MoveInternal =  function(self, direction, moveFunc, inspectFunc, digFunc, attackFunc)
		self:CheckFuelLevels(1)
		
		while not moveFunc() do
			if inspectFunc() then
				digFunc()
			else
				attackFunc()
			end
			
			sleep(0.1)
		end
		
		self.position = self.position + direction
		self:__InvokeTransformChanged()
	end,
	
	MoveUp = function(self)
		self:MoveInternal(PVector3.new(0, 1, 0), turtle.up, turtle.detectUp, turtle.digUp, turtle.attackUp)
	end,
	
	MoveDown = function(self)
		self:MoveInternal(PVector3.new(0, -1, 0), turtle.down, turtle.detectDown, turtle.digDown, turtle.attackDown)
	end,
	
	MoveForward = function(self)
		self:MoveInternal(self.rotation, turtle.forward, turtle.detect, turtle.dig, turtle.attack)
	end,
	
	MoveTo = function(self, targetPosition)
		while self.position.y < targetPosition.y do self:MoveUp() end
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
	end,
	
	--------------
	-- Rotation --
	--------------
	RotateInternal = function(self, radians, turnFunc) 
		local dirx = round( self.rotation.x * math.cos( radians ) - self.rotation.z * math.sin( radians ) )
		local dirz = round( self.rotation.x * math.sin( radians ) + self.rotation.z * math.cos( radians ) )
		
		if turnFunc() then
			dir = vector.new( dirx, 0, dirz )
			self:__InvokeTransformChanged()
			return true
		end
	   
		return false
	end,
	
	
	RotateRight = function(self)
		self:RotateInternal(-math.pi*0.5, turtle.turnRight)
	end,
	
	RotateLeft = function(self)
		self:RotateInternal(math.pi*0.5, turtle.turnLeft)
	end,

	RotateTo = function(self, targetRotation)
		while not (self.rotation.x == targetRotation.x and self.rotation.z == target.rotation.z) do
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
		local amount = minimalAmount or 1
		if turtle.getFuelLevel() < minimalAmount then
			print('Not Enough Fuel')
			self:__InvokeRefuelRequired()
		end
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
	
	----------
	-- Misc --
	----------
	ToString = function(self) 
		return '[pos: ' .. self.position:ToString() .. ', rot: ' .. self.rotation:ToString() .. ']'
	end,
	
	------------
	-- Events --
	------------
	OnTransformChanged = function(self, callback)
		self.onTransformChangedCallback = callback
	end,
	
	__InvokeTransformChanged = function(self)
		if not (self.onTransformChangedCallback == nil) then 
			self.onTransformChangedCallback() 
		end
	end,
	
	OnRefuelRequired = function(self, callback)
		self.onRefuelRequiredCallback = callback
	end,
	
	__InvokeRefuelRequired = function(self)
		if not (self.onRefuelRequiredCallback == nil) then 
			self.onRefuelRequiredCallback() 
		end
	end
}

local TrackedTurtleMetatable = {
	__index = TrackedTurtle,
	__tostring = TrackedTurtle.ToString
}

function New(startPosition, startRotation, refuelRequiredCallback, transformChangedCallback)
	local trackedTurtle = {
		position = startPosition or PVector3.New(0, 0, 0),
		rotation = startRotation or PVector3.New(0, 0, 1),
		onRefuelRequiredCallback = refuelRequiredCallback or nil,
		onTransformChangedCallback = transformChangedCallback or nil
	}
	setmetatable(trackedTurtle, TrackedTurtleMetatable)
	return trackedTurtle
end

function FromTable(t) 
	local trackedTurtle = {
		position = PVector3.FromTable(t.position) or PVector3.New(0, 0, 0),
		rotation = PVector3.FromTable(t.rotation) or PVector3.New(0, 0, 1)
	}
	setmetatable(trackedTurtle, nil)
	setmetatable(trackedTurtle, TrackedTurtleMetatable)
	return trackedTurtle
end







