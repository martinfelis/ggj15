local SECURITYCAM_REALIZE_TIME=4

local function newSecurityCam (x, y)
	local cam = {
		x = x,
		y = y,
		alert = {},
		alerttime = 0,
		onealert = false,
		testingfor = 1,
		radius = 170
	}

	function cam:update(dt, players, world)
		self.alerttime = self.alerttime + dt
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
			if ((player.body:getX()-self.x)^2+(player.body:getY()-self.y)^2 > (self.radius+player.radius)^2) then
				self.alert[k] = false
			else
				self.alert[k] = true
				self.testingfor = k
				world:rayCast(self.x, self.y, player.body:getX(), player.body:getY(), callback)
			end
		end


		self.onealert = false
		for k,a in pairs(self.alert) do
			if (a) then
				self.onealert = true
				break
			end
		end

		if (self.onealert) then
			-- TODO lose game?
		end

	end

	function cam:draw()

		if (not self.onealert) then
			self.alerttime = 0
		else
			if (self.alerttime >= SECURITYCAM_REALIZE_TIME) then
				print("you were caught on tape by a security camera")
				-- TODO end game friendly
				love.event.quit()
			end
		end

		love.graphics.setColor(255,(SECURITYCAM_REALIZE_TIME-self.alerttime)*(255/SECURITYCAM_REALIZE_TIME),0,128)
		if (self.onealert) then
			love.graphics.setColor(255,96,0,128)
		else
			love.graphics.setColor(255,255,0,128)
		end

		love.graphics.circle("fill", self.x, self.y, self.radius)
	end

	return cam
end
return newSecurityCam
