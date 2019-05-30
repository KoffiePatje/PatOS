function Round(value, nTolerance)
	nTolerance = nTolerance or 1.0
	return math.floor( (self.x + (nTolerance * 0.5)) / nTolerance ) * nTolerance
end