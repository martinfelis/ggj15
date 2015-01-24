local function newSpotlight (x, y)
	local spot = {
		x = x,
		y = y,
		alert = false,
		alerttime = 0,
		detectortype = "spotlight",
		player_alert_start= {},
		radius = 100
	}

	function spot:update(dt, players)
		self.alerttime = self.alerttime + dt

		-- TODO MOVEMENT

		self.alert = false
		for k,player in pairs(players) do
			local alert = (self.x-player.body:getX())^2 + (self.y-player.body:getY())^2 < (self.radius+player.radius)^2

			if alert and not self.player_alert_start[player] then
				Signals.emit ('alert-start', self, player)
				self.player_alert_start[player] = love.timer.getTime()
			end

			if not alert and self.player_alert_start[player] ~= nil then
				Signals.emit ('alert-stop', self, player)
				self.player_alert_start[player] = nil 
			end

			if alert then
				self.alert = true
			end
		end

		if (not self.alert) then
			self.alerttime = 0
		end
	end

	function spot:draw()
		love.graphics.setColor(255,(GVAR.spotlight_realize_time-self.alerttime)*(255/GVAR.spotlight_realize_time),0,128)

		love.graphics.circle("fill", self.x, self.y, self.radius)
	end
	return spot
end
return newSpotlight
