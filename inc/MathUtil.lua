function Round(value, nTolerance)
	nTolerance = nTolerance or 1.0
	return math.floor( (value + (nTolerance * 0.5)) / nTolerance ) * nTolerance
end