----------------------------
-- PatOS - PVector3 Class --
----------------------------

API.Load("MathUtil")

local PVector2 = {
	Add = function (self, other)
		return PVector2.New(
			self.x + other.x,
			self.y + other.y
		)
	end,
	
	Subtract = function(self, other)
		return PVector2.New(
			self.x - other.x,
			self.y - other.y
		)
	end,
	
	Multiply = function(self, scalar)
		return PVector2.New(
			self.x * scalar,
			self.y * scalar
		)
	end,
	
	Divide = function(self, divider)
		return PVector2.New(
			self.x / divider,
			self.y / divider
		)
	end,
	
	Negate = function(self)
		return PVector2.New(
			-self.x,
			-self.y
		)
	end,
	
	--Dot = function(self, other)
	--	return (self.x * other.x) + (self.y * other.y)
	--end
		
	Round = function(self, nTolerance)
		return PVector2.New(
			MathUtil.Round(self.x),
			MathUtil.Round(self.y)
		)
	end,
	
	Normalize = function(self)
		local scalar = 1.0 / self:Length()
		self.Mul(scalar)
	end,
	
	Normalized = function(self)
		local scalar = 1.0 / self:Length()
		return PVector2.New(self.x * scalar, self.y * scalar)
	end,
	
	Length = function(self)
		return math.sqrt(self:LengthSqrd())
	end,

	LengthSqrd = function(self)
		return (self.x * self.x) + (self.y * self.y)
	end,

	Equals = function(self, other)
		return self.x == other.x and self.y == other.y
	end,

	ToString = function(self)
		return '(' .. self.x .. ', ' .. self.y .. ')'
	end
}

local PVector2Metatable = {
	__index = PVector2,
	__add = PVector2.Add,
	__sub = PVector2.Subtract,
	__mul = PVector2.Multiply,
	__div = PVector2.Divide,
	__unm = PVector2.Negate,
	__eq = PVector2.Equals,
	__tostring = PVector2.ToString
}

function __CreateObject(x, y, z)
	return {
		x = tonumber(x) or 0,
		y = tonumber(y) or 0
	}
end

function New(x, y, z)
	local v = __CreateObject(x, y)
	setmetatable(v, PVector2Metatable)
	return v
end

function FromTable(t) 
	local v = __CreateObject(t.x, t.y)
	setmetatable(v, nil)
	setmetatable(v, PVector2Metatable)
	return v;
end


