function Round(value, nTolerance)
	nTolerance = nTolerance or 1.0
	return math.floor( (value + (nTolerance * 0.5)) / nTolerance ) * nTolerance
end

function Clamp(value, min, max)
	if value > max then
		return max
	elseif value < min then
		return min
	else
		return value
	end
end