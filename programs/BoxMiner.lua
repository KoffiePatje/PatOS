os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("TrackedTurtle")

local boxSize = PVector3.New(3, 4, 5)
local myTurtle = TrackedTurtle.New(PVector3.New(3, 2, 1), PVector3.New(1, 0, 0))
local myTurtle2 = TrackedTurtle.New(PVector3.New(4, 5, 6), PVector3.New(0, 1, 0))

print(boxSize:ToString())
print(myTurtle:ToString())

API.Load("Prefs")

Prefs.Set("BoxSize", boxSize)
Prefs.Set("Turtle", myTurtle)
Prefs.Set("Turtle2", myTurtle2)

Prefs.Save("BoxMiner")
Prefs.Load("BoxMiner")

local storedBoxSize = PVector3.FromTable(Prefs.Get("BoxSize"))
local storedTurtle = TrackedTurtle.FromTable(Prefs.Get("Turtle"))
local storedTurtle2 = TrackedTurtle.FromTable(Prefs.Get("Turtle2"))

print(storedBoxSize:ToString())
print(storedTurtle:ToString())
print(storedTurtle2:ToString())