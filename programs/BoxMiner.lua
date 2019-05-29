os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("TrackedTurtle")

local boxSize = PVector3.New(1, 1, 1)
local myTurtle = TrackedTurtle.New()

print(boxSize:ToString())
print(myTurtle:ToString())
