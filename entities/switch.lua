function newSwitch(x, y, radius)
	local switch = {
		x = x,
		y = y,
		radius = radius,
		on = false,
		observers = {}
	}
	function switch:update(dt, players)
		if (self.on) then -- do not turn the switch back off
			return
		end
		for k,player in pairs(players) do
			if (self.x-player.body:getX())^2 + (self.y-player.body:getY())^2 < (self.radius+player.radius)^2 then
				self.on = true

				-- notify the doors
				for k,observer in pairs(self.observers) do
					observer:notify(self)
				end
			end
		end
	end
	function switch:draw() 
		if (self.on) then
			love.graphics.setColor(0, 255, 0, 255)
		else 
			love.graphics.setColor(64, 128, 64, 128)
		end
		love.graphics.circle("fill", self.x, self.y, self.radius)
		love.graphics.setColor(255, 255, 255, 255)
	end

	function switch:addObserver(observer)
		table.insert(self.observers, observer)
	end

	return switch
end
return newSwitch