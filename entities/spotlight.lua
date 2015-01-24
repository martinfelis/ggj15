local function newSpotlight (x, y)
	local spot = {
		x = x,
		y = y,
		alert1 = false,
		alert2 = false,
		radius = 170
	}

	function spot:update(player1, player2)
		-- TODO MOVEMENT

		self.alert1 = (self.x-player1.body:getX())^2 + (self.y-player1.body:getY())^2 < (self.radius+player1.radius)^2
		self.alert2 = (self.x-player2.body:getX())^2 + (self.y-player2.body:getY())^2 < (self.radius+player2.radius)^2

	end

	function spot:draw()

		if (self.alert1 or self.alert2) then
			love.graphics.setColor(255,96,0,128)
		else
			love.graphics.setColor(255,255,0,128)
		end

		love.graphics.circle("fill", self.x, self.y, self.radius)

	end
	return spot
end
return newSpotlight