os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("TrackedTurtle")

local boxSize = PVector3.New(1, 1, 1)
local myTurtle = TrackedTurtle.New()

print(boxSize:ToString())
print(myTurtle:ToString())

API.Load("Prefs")

Prefs.Set("BoxSize", boxSize)
Prefs.Set("Turtle", myTurtle)

Prefs.Save("BoxMiner")
Prefs.Load("BoxMiner")

local storedBoxSize = Prefs.Get("BoxSize")
local storedTurtle = Prefs.Get("Turtle")

setmetatable(storedBoxSize, PVector3Metatable)
setmetatable(storedTurtle, TrackedTurtleMetatable)

print(storedBoxSize)
print(storedTurtle)
