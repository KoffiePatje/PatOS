os.loadAPI('PatOS/inc/PVector3')

Entity = { 
	position = PVector3.new(0, 0, 0),
	rotation = PVector3.new(0, 0, 1),
}

function Entity:New()
	entity = {}
	setmetatable(entity, self)
	self.__index = self
	return entity;

end

function Entity:Mine(front, up, down) 
	if front then 
		turtle.dig()
end

--------------
-- Movement --
--------------
function Entity:MoveInternal(direction, moveFunc, inspectFunc, digFunc, attackFunc)
	while not moveFunc() do
		if inspectFunc() then
			digFunc()
		else
			attackFunc()
		end
		sleep(0.1)
	end
	
	self.position.Add(direction)
end

function Entity:MoveUp()
	self.MoveInternal(PVector3.new(0, 1, 0), turtle.up, turtle.detectUp, turtle.digUp, turtle.attackUp)
end

function Entity:MoveDown()
	self.MoveInternal(PVector3.new(0, -1, 0), turtle.down, turtle.detectDown, turtle.digDown, turtle.attackDown)
end

function Entity:MoveForward()
	self.MoveInternal(self.rotation, turtle.forward, turtle.detect, turtle.dig, turtle.attack)
end

function Entity:MoveTo(targetPosition)
	while self.position.y < targetPosition.y do MoveUp() end
	while self.position.y > targetPosition.y do MoveDown() end
	
	if not (self.position.x == targetPosition.x) then
		local direction = (PVector3.New(targetPosition.x, 0, 0) - PVector3.New(self.position.x, 0, 0)):Normalized()
		RotateTo(direction)
		while not (self.position.x == targetPosition.x) do MoveForward() end
	end
	
	if not (self.position.z == target.position.z) then
		local direction = (PVector3.New(0, 0, targetPosition.z) - PVector3.New(0, 0, self.position.z)):Normalized()
		RotateTo(direction)
		while not (self.position.z == target.position.z) do MoveForward() end
	end

end

--------------
-- Rotation --
--------------
function RotateInternal(radians, turnFunc) 
        local dirx = round( self.rotation.x * math.cos( radians ) - self.rotation.z * math.sin( radians ) )
        local dirz = round( self.rotation.x * math.sin( radians ) + self.rotation.z * math.cos( radians ) )
		
		if turnFunc() then
                dir = vector.new( dirx, 0, dirz )
                return true
        end
       
        return false
end

function Entity:RotateRight()
	self.RotateInternal(-math.pi*0.5, turtle.turnRight)
end

function Entity:RotateLeft()
	self.RotateInternal(math.pi*0.5, turtle.turnLeft)
end

function Entity:RotateTo(targetRotation)
	while not (self.rotation.x == targetRotation.x and  self.rotation.z == target.rotation.z) do
		local cross = self.rotation.Cross(targetRotation)
		if cross.y >= 0 then 
end
