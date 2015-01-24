function newSwitch(x, y)
	local switch = {
		x = x,
		y = y,
		radius = 10,
		on = false
	}
	function switch:update(dt, players)
		if (self.on) then -- do not turn the switch back off
			return
		end
		for k,player in pairs(players) do
			if (self.x-player.body:getX())^2 + (self.y-player.body:getY())^2 < (self.radius+player.radius)^2 then
				self.on = true
				-- TODO open doors
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

	return switch
end
return newSwitch