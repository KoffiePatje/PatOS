function WaitForKey( key )
    while true do
        local event, param = os.pullEvent( "key" )
        if ( event == "key" ) and ( param == key ) then
            break
        end
    end
end

function WaitForKeys( table_of_keys )
    while true do
        local event, param = os.pullEvent( "key" )
        for i=1,#table_of_keys do
            if param == table_of_keys[i] then
                return ( table_of_keys[i] )
            end
        end
    end
end

function GetNumberInput()
	return tonumber(read())
end

function GetInput()
	return read()
end