function IsKeyPressed(key)
	local event, param = os.pullEvent( "key" )
	return (( event == "key" ) and ( param == key ))
end

function IsKeysPressed(keys)
	local event, param = os.pullEvent( "key" )
	
	if ( event == "key" ) then
		for i=1, #keys do 
			if param == keys[i] then 
				return true 
			end
		end
	end
	
	return false
end

function WaitForKey( key )
	local isPressed = false
	repeat
		isPressed = IsKeyPressed(key)
	until isPressed
end

function WaitForKeys( keys )
	local isPressed = false
	repeat
		isPressed = IsKeysPressed(keys)
	until isPressed
end

function GetNumberInput()
	return tonumber(read())
end

function GetInput()
	return read()
end