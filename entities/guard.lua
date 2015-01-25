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
		image = "images/guard.png",
		
		cycle_phase = 0.,
		speed = 0.,

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
	guard.image = love.graphics.newImage(guard.image)

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

		local vel = vector (self.body:getLinearVelocity())

		self.angle = math.atan2(vel.y, vel.x)

		-- guard

		self.x, self.y = guard.body:getPosition()

		self.alert = false
		self.alerttime = self.alerttime + dt

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

		if self.cycle_phase > math.pi * 2 then
			self.cycle_phase = self.cycle_phase - math.pi * 2
		elseif self.cycle_phase < 0 then
			self.cycle_phase = self.cycle_phase + math.pi * 2
		end

		if self.speed > 0.1 then
			self.cycle_phase = self.cycle_phase + dt * self.speed / 30
		else
			self.speed = 0.
			vel.x, vel.y = 0., 0.
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

		if not self.alerted then
			love.graphics.setColor (10, 10, 255, 255)
		end
		local draw_angle = self.angle + math.pi * 0.5
		love.graphics.draw(self.image, self.body:getX(), self.body:getY(),draw_angle, 2,2,self.image:getWidth() /2, self.image:getHeight()/2)

		local arm_width = 20
		local shoulder_width = 38.
		local phase_mod = math.sin (self.cycle_phase)
		local arm_length = 20 + 30 * math.abs(phase_mod)
		local arm_center = vector(arm_width * 0.5 + shoulder_width, phase_mod * 10)

		local foot_width = 20
		local hip_width = 10.
		local phase_mod = math.sin (-self.cycle_phase)
		local foot_length = 30 + 20 * math.abs(phase_mod)
		local foot_center = vector(foot_width * 0.5 + hip_width, phase_mod * 10)

		love.graphics.push()
		love.graphics.translate (self.body:getX(), self.body:getY())
		love.graphics.rotate (draw_angle)
		love.graphics.setLineWidth (4.)
		
		-- arms
		love.graphics.rectangle ("line", 
			arm_center.x - arm_width * 0.5, 
			arm_center.y - arm_length * 0.5,
			arm_width, arm_length)
		love.graphics.rectangle ("line", 
			- arm_center.x - arm_width * 0.5, 
			-arm_center.y + arm_length * 0.5,
			arm_width, -arm_length)

			--[[
		love.graphics.rectangle ("line", 
			foot_center.x - foot_width * 0.5, 
			foot_center.y - foot_length * 0.5,
			foot_width, foot_length)
		love.graphics.rectangle ("line", 
			- foot_center.x - foot_width * 0.5, 
			-foot_center.y + foot_length * 0.5,
			foot_width, -foot_length)
			--]]

		love.graphics.pop()


	end

	return guard
end
return newGuard
