PVector3 = {
	x = 0,
	y = 0,
	z = 0
}

function PVector3:New(x, y, z)
	v3 = {}
	setmetatable(v3, self)
	self.__index = self
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	return v3
end

function PVector3:Add(other)
	self.x = self.x + other.x
	self.y = self.y + other.y
	self.z = self.z + other.z
end

function PVector3:Sub(other)
	self.x = self.x - other.x
	self.y = self.y - other.y
	self.z = self.z - other.z
end

function PVector3:Mul(scalar)
	self.x = self.x * scalar
	self.y = self.y * scalar
	self.z = self.z * scalar
end

function PVector3:Dot(other)
	return (self.x * other.x) + (self.y * other.y) + (self.z * other.z)
end

function PVector3:Cross(other)
	return PVector.New(
		(self.y * other.z) - (self.z * other.y),
		(self.z * other.x) - (self.x * other.z),
		(self.x * other.y) - (self.y * other.x)
	)
end

function PVector3:RoundToInt()
	return PVector3.New(
		math.round(self.x),
		math.round(self.y),
		math.round(self.z)
	)
end

function PVector3:Normalize()
	local scalar = 1.0f / Length()
	self.Mul(scalar)
end

function PVector3:Normalized()
	local scalar = 1.0f / Length()
	return PVector3.New(self.x * scalar, self.y * scalar, self.z * scalar)
end

function PVector3:Length()
	return math.sqrt(self.LengthSqrd())
end

function PVector3:LengthSqrd()
	return (self.x * self.x) + (self.y * self.y) + (self.z * self.z)
end

function PVector3:ToString()
	return '(' .. self.x .. ', ' .. self.y .. ', ' .. self.z .. ')'
end
