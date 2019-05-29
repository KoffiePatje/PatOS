os.loadAPI('PatOS/API')

API.Load("PVector3")
API.Load("TrackedTurtle")

local boxSize = PVector3.New(1, 1, 1)
local myTurtle = TrackedTurtle.New()

print(boxSize:ToString())
print(myTurtle:ToString())

API.Load("Prefs")

Prefs.Set("BoxSize", textutils.serialize(boxSize))
Prefs.Set("Turtle", textutils.serialize(myTurtle))

Prefs.Save("BoxMiner")
Prefs.Load("BoxMiner")

local storedBoxSize = textutils.deserialize(Prefs.Get("BoxSize"))
local storedTurtle = textutils.deserialize(Prefs.Get("Turtle"))

print(storedBoxSize)
print(storedTurtle)
