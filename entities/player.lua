local function newPlayer (x, y)
	local player = {
		x = x,
		y = y,
		image = love.graphics.newImage ("player.png")
	}

	print (string.format ("Created new player at %f,%f", player.x, player.y))

	function player.update (self, dt)
		self.x = self.x + dt * 30
	end

	function player:draw ()
		love.graphics.draw (self.image, self.x, self.y)
	end

	return player
end

return newPlayer
