local function newSpotlight (x, y)
	local spot = {
		x = x,
		y = y,
		alert = false,
		radius = 100
	}

	function spot:update(dt, players)
		-- TODO MOVEMENT

		self.alert = false
		for k,player in pairs(players) do
			self.alert = self.alert or (self.x-player.body:getX())^2 + (self.y-player.body:getY())^2 < (self.radius+player.radius)^2
		end
	end

	function spot:draw()

		if (self.alert) then
			love.graphics.setColor(255,96,0,128)
		else
			love.graphics.setColor(255,255,0,128)
		end

		love.graphics.circle("fill", self.x, self.y, self.radius)

	end
	return spot
end
return newSpotlight