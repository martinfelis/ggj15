local function newSpotlight (x, y, r)
	local spot = {
		x = x,
		y = y,
		alert = false,
		alerttime = 0,
		detectortype = "spotlight",
		player_alert_start= {},

		alerted = false,
		alertness = 0.,

		radius = r
	}

	function spot:update(dt, players, totalTime)

		if self.pathpoints then
			self.x, self.y = pathfunctions.walk(self.pathpoints, totalTime, self.speed)
		end

		self.alerttime = self.alerttime + dt

		if self.alerted then
			self.alertness = math.min (1., self.alertness + dt * GVAR.alert_increase_rate)
		else
			self.alertness = math.max (0., self.alertness - dt * GVAR.alert_decrease_rate)
		end

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

		if next (self.player_alert_start) then
			self.alerted = true
		else
			self.alerted = false
		end
	end

	function spot:draw()
		love.graphics.setColor(255,(1. - self.alertness) * 255, 0, 128)

		love.graphics.circle("fill", self.x, self.y, self.radius)

		if self.alerted then
			love.graphics.setColor (255, 0, 0, 128)
			love.graphics.setLineWidth (10.)
			love.graphics.circle("line", self.x, self.y, self.radius + math.sin(love.timer.getTime() * 10) * 10)
		end

	end
	return spot
end
return newSpotlight
