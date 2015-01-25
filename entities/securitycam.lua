local SECURITYCAM_REALIZE_TIME=4

local function newSecurityCam (x, y, radius)
	local cam = {
		x = x,
		y = y,

		alert = {},

		alerted = false,
		alertness = 0.,

		testingfor = 1,
		radius = radius,
		drawradius = 200,

		player_alert_start= {},
		detectortype = "securitycam",
	}

	function cam:update(dt, players, world)
		if self.alerted then
			self.alertness = math.min (1., self.alertness + dt * GVAR.alert_increase_rate)
		else
			self.alertness = math.max (0., self.alertness - dt * GVAR.alert_decrease_rate)
		end

		local function callback(fixture, x, y, xn, yn, fraction)
			if (fixture:getUserData() == "chain") then -- you can't hide behind your chains
				return -1
			end

			if (fixture:getUserData() == "player") then
				return -1
			end

			-- we hit something bad
			self.alert[self.testingfor] = false
			return 0 -- immediately cancel the ray
		end

		for k,player in pairs(players) do
			-- cast rays
			local visible = ((player.body:getX()-self.x)^2+(player.body:getY()-self.y)^2 < (self.radius+player.radius)^2)

			if visible then
				self.alert[k] = true
				self.testingfor = k
				world:rayCast(self.x, self.y, player.body:getX(), player.body:getY(), callback)
				visible = self.alert[k]
			end

			-- emit signals
			if visible and not self.player_alert_start[player] then
				Signals.emit ('alert-start', self, player)
				self.player_alert_start[player] = love.timer.getTime()
			end

			if not visible and self.player_alert_start[player] then
				Signals.emit ('alert-stop', self, player)
				self.player_alert_start[player] = nil
			end
		end

		if next (self.player_alert_start) then
			self.alerted = true
		else
			self.alerted = false
		end
	end

	function cam:draw()
		love.graphics.setColor(255,(1. - self.alertness) * 255, 0, 128)

		love.graphics.circle("fill", self.x, self.y, self.drawradius)

		if self.alerted then
			love.graphics.setColor (255, 0, 0, 128)
			love.graphics.setLineWidth (10.)
			love.graphics.circle("line", self.x, self.y, self.radius + math.sin(love.timer.getTime() * 10) * 10)
		end
	end

	return cam
end
return newSecurityCam
