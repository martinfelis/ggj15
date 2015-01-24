local SPOTLIGHT_REALIZE_TIME=1.5

local function newSpotlight (x, y)
	local spot = {
		x = x,
		y = y,
		alert = false,
		alerttime = 0,
		radius = 100
	}

	function spot:update(dt, players)
		self.alerttime = self.alerttime + dt

		-- TODO MOVEMENT

		self.alert = false
		for k,player in pairs(players) do
			self.alert = self.alert or (self.x-player.body:getX())^2 + (self.y-player.body:getY())^2 < (self.radius+player.radius)^2
		end
	end

	function spot:draw()
		if (not self.alert) then
			self.alerttime = 0
		else
			if (self.alerttime >= SPOTLIGHT_REALIZE_TIME) then
				print("you were caught by a spotlight")
				-- TODO end game friendly
				love.event.quit()
			end
		end

		love.graphics.setColor(255,(SPOTLIGHT_REALIZE_TIME-self.alerttime)*(255/SPOTLIGHT_REALIZE_TIME),0,128)

		love.graphics.circle("fill", self.x, self.y, self.radius)

	end
	return spot
end
return newSpotlight