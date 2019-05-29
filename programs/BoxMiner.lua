os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("TrackedTurtle")

local boxSize = PVector3.New(3, 4, 5)
local myTurtle = TrackedTurtle.New(PVector.New(3, 2, 1), PVector3.New(1, 0, 0))

print(boxSize:ToString())
print(myTurtle:ToString())

API.Load("Prefs")

Prefs.Set("BoxSize", boxSize)
Prefs.Set("Turtle", myTurtle)

Prefs.Save("BoxMiner")
Prefs.Load("BoxMiner")

local storedBoxSize = PVector3.FromTable(Prefs.Get("BoxSize"))
local storedTurtle = TrackedTurtle.FromTable(Prefs.Get("Turtle"))

print(storedBoxSize)
print(storedTurtle)