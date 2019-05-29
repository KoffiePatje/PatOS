os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("Entity")

local boxSize = PVector3.New(1, 1, 1)
local myTurtle = Entity.New()

print(boxSize:ToString())
print(myTurtle:ToString())
