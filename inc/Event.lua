-------------------------
-- PatOS - Event Class --
-------------------------

local Event = {
	Invoke = function(self)
		for i=1, #self.listeners do
			if self.listeners[i] == nil then
				print('nil listener found at index '..i)
				break;
			end
			
			self.listeners[i]();
		end
	end
	
	Subscribe = function(self, listener)
		if not self.listeners[listener] then 
			table.insert(self.listeners, listener)
		end
	end
	
	Unsubscribe = function(self, listener)
		for i=1, #self.listeners do
			if self.listeners[i] == listener then
				table.remove(self.listeners, i)
				return true
			end
		end
		
		return false
	end
}

local EventMetatable {
	__index = Event
	--__add = Subscribe
	--__sub = Unsubscribe
}

local New() {	
	local e = {
		listeners = {}
	}
	setmetatable(e, EventMetatable)
	return e
}