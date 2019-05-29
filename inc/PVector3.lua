local PVector3 = {
	Add = function (self, other)
		return PVector.New(
			self.x + other.x,
			self.y + other.y,
			self.z + other.z
		)
	end,
	
	Subtract = function(self, other)
		return PVector.New(
			self.x - other.x,
			self.y - other.y,
			self.z - other.z
		)
	end,
	
	Multiply = function(self, scalar)
		return PVector.New(
			self.x * scalar,
			self.y * scalar,
			self.z * scalar
		)
	end,
	
	Divide = function(self, divider)
		return PVector.New(
			self.x / divider,
			self.y / divider,
			self.z / divider
		)
	end,
	
	Negate = function(self)
		return PVector3.New(
			-self.x,
			-self.y,
			-self.z
		)
	end,
	
	Dot = function(self, other)
		return (self.x * other.x) + (self.y * other.y) + (self.z * other.z)
	end,
	
	Cross = Cross(self, other)
		return PVector.New(
			(self.y * other.z) - (self.z * other.y),
			(self.z * other.x) - (self.x * other.z),
			(self.x * other.y) - (self.y * other.x)
		)
	end,
	
	Round = function(self, nTolerance)
	    nTolerance = nTolerance or 1.0
		return vector.new(
			math.floor( (self.x + (nTolerance * 0.5)) / nTolerance ) * nTolerance,
			math.floor( (self.y + (nTolerance * 0.5)) / nTolerance ) * nTolerance,
			math.floor( (self.z + (nTolerance * 0.5)) / nTolerance ) * nTolerance
		)
	end,
	
	Normalize = function(self)
		local scalar = 1.0f / self:Length()
		self.Mul(scalar)
	end,
	
	Normalized = function(self)
		local scalar = 1.0f / self:Length()
		return PVector3.New(self.x * scalar, self.y * scalar, self.z * scalar)
	end,
	
	Length = function(self)
		return math.sqrt(self:LengthSqrd())
	end,

	LengthSqrd = function(self)
		return (self.x * self.x) + (self.y * self.y) + (self.z * self.z)
	end,

	ToString = function(self)
		return '(' .. self.x .. ', ' .. self.y .. ', ' .. self.z .. ')'
	end
}

local PVector3Metatable = {
	__index = PVector3,
	__add = PVector3.Add,
	__sub = PVector3.Subtract,
	__mul = PVector3.Multiply,
	__div = PVector3.Divide,
	__unm = PVector3.Negate,
	__tostring = vector.ToString
}

function New( x, y, z )
	local v = {
		x = tonumber(x) or 0,
		y = tonumber(y) or 0,
		z = tonumber(z) or 0
	}
	setmetatable(v, PVector3Metatable)
	return v
end



