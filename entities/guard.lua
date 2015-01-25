local GUARD_ROTATION_SPEED = 5
local function newGuard (x, y, world)
	-- TODO pass path to walk on
	local guard = {
		x = x,
		y = y,
		alert = false,
		alerttime = 0,
		testingfor = 1,
		radius = 300,
		guy_radius = 35,
		angle = 1.,
		wishAngle = 0,

		alerted = false,
		alertness = 0.,

		detectortype = "guard",
		player_alert_start= {},
		fov = math.pi/1.6
	}
	guard.guide = love.physics.newBody(world, x, y, "dynamic")
	guard.body = love.physics.newBody(world, x+20, y, "dynamic")
	guard.shape = love.physics.newCircleShape(20)
	guard.fixture = love.physics.newFixture(guard.body, guard.shape)
	guard.body:setLinearDamping(5)
	guard.shape2 = love.physics.newCircleShape(guard.guy_radius)
	guard.fixture2 = love.physics.newFixture(guard.guide, guard.shape2)


	guard.joint = love.physics.newRopeJoint(guard.guide, guard.body, 0,0,0,0, 20, false)

	function guard:update(dt, players, world, totalTime)
		if self.alerted then
			self.alertness = math.min (1., self.alertness + dt * GVAR.alert_increase_rate)
		else
			self.alertness = math.max (0., self.alertness - dt * GVAR.alert_decrease_rate)
		end

		-- walk
		if self.pathpoints then
			--self.body:setPosition()
			local aimx,aimy= pathfunctions.walk(self.pathpoints, totalTime, self.speed)

			self.body:setLinearVelocity(aimx-self.x,aimy-self.y)
			-- self.body:setLinearVelocity(vel.x, vel.y)
			local startX, startY = pathfunctions.walk(self.pathpoints, totalTime, self.speed)
			local endX, endY = pathfunctions.walk(self.pathpoints, totalTime+dt, self.speed)
			 -- self.angle = math.atan2(endY-startY, endX-startX)
		end


		--[[if self.wishAngle > 2*math.pi then
			self.wishAngle = self.wishAngle - 2*math.pi
		elseif self.angle < 0 then
			self.wishAngle= self.wishAngle + 2*math.pi
		end

		print(string.format("%f <> %f", self.wishAngle, self.angle))

		if (self.wishAngle > self.angle) then
			print("greater")
			self.angle = self.angle + dt * GUARD_ROTATION_SPEED
		end
		if (self.wishAngle < self.angle) then
			print("smaller")
			self.angle = self.angle - dt * GUARD_ROTATION_SPEED
		end ]]--
		local vel= {}
		vel.x, vel.y = self.body:getLinearVelocity()
		self.angle = math.atan2(vel.y, vel.x)

		-- guard

		self.x, self.y = guard.body:getPosition()

		self.alert = false
		self.alerttime = self.alerttime + dt
		-- self.angle = self.angle + dt * 0.4
	

		-- TODO NEEDED?

--		if self.angle > 2*math.pi then
--			self.angle = self.angle - 2*math.pi
--		elseif self.angle < 0 then
--			self.angle= self.angle + 2*math.pi
--		end
		local function callback(fixture, x, y, xn, yn, fraction)

			if (fixture:getUserData() == "chain") then -- you can't hide behind your chains
				return -1
			end
			if (fixture:getUserData() == "player") then
				return -1
			end


			-- we hit something bad
			self.alert = false
			return 0 -- immediately cancel the ray
		end


		for k,player in pairs(players) do
			local rel_pos = vector(player.body:getX() - self.x, player.body:getY() - self.y)
			local angle = rel_pos:rotate_inplace (-self.angle):angleTo()

			local alert = false
			if (math.abs (angle) < self.fov / 2.) then
				alert = ((player.body:getX()-self.x)^2+(player.body:getY()-self.y)^2 < (self.radius+player.radius) * (self.radius+player.radius))

				if alert then
					-- check whether we are acually seen
					self.alert = true
					self.testingfor = k
					world:rayCast(self.x, self.y, player.body:getX(), player.body:getY(), callback)
					alert = self.alert
				end
			end

			-- emit signals 
			if alert and not self.player_alert_start[player] then
				Signals.emit ('alert-start', self, player)
				self.player_alert_start[player] = love.timer.getTime()
			end

			if not alert and self.player_alert_start[player] then
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

	function guard:draw()
		love.graphics.setColor(255, 255, 255, 255)
		love.graphics.circle("line", self.x, self.y, self.guy_radius)

		love.graphics.setColor(255,(1. - self.alertness) * 255, 0, 128)
																		   -- fix löves wrong angle drawing
		love.graphics.arc("fill", self.x, self.y, self.radius, self.angle + self.fov*.5, self.angle - self.fov *.5)

		if self.alerted then
			love.graphics.setColor (255, 0, 0, 128)
			love.graphics.setLineWidth (10.)
			love.graphics.arc("line", self.x, self.y, self.radius + math.sin(love.timer.getTime() * 10) * 10, self.angle + self.fov*.5, self.angle - self.fov *.5)
		end
	end

	return guard
end
return newGuard
