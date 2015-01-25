local GUARD_ROTATION_SPEED = 5
local function newGuard (x, y, world)
	-- TODO pass path to walk on
	local guard = {
		x = x,
		y = y,
		alert = false,
		alerttime = 0,
		testingfor = 1,
		guy_radius = 35,
		busting_radius = 170,
		view_radius = 400,
		angle = 1.,
		wishAngle = 0,

		alerted = false,
		alertness = 0.,
		image = "images/guard.png",
		
		cycle_phase = 0.,
		speed = 0.,

		detectortype = "guard",
		player_alert_start= {},
		view_fov = math.pi/2,
		busted_fov = math.pi * 0.9
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


		for k,player in pairs(players) do
			local player_pos = vector (player.body:getX(), player.body:getY())
			local in_view_fov = self:pointInView (player_pos.x, player_pos.y, self.view_fov)
			local in_busted_fov= self:pointInView (player_pos.x, player_pos.y, self.busted_fov)
			local alert = false

			if in_view_fov or in_busted_fov then
				local distance = player_pos:dist (vector (self.x, self.y)) - player.radius

				if distance < self.view_radius then
					alert = true
				end

				if distance < self.busting_radius then
					Signals.emit ('busted', self, player)
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

	function guard:pointInView (x, y, fov)
		local rel_pos = vector(x - self.x, y - self.y)
		local angle = rel_pos:rotate_inplace (-self.angle):angleTo()

		if (math.abs (angle) < fov / 2.) then
			local ray_reach_target = true
			local function callback(fixture, x, y, xn, yn, fraction)
				if (fixture:getUserData() == "chain") then
					return -1
				end
				if (fixture:getUserData() == "player") then
					return 1
				end
				
				ray_reach_target = false

				return 0
			end
		
			local x, y, fraction = world:rayCast(self.x, self.y, x, y, callback)
			return ray_reach_target
		end

		return false
	end

	function guard:draw()
		love.graphics.circle("line", self.x, self.y, self.guy_radius)

		love.graphics.setColor(200, 00, 00, 128)
		love.graphics.arc("fill", self.x, self.y, self.busting_radius, self.angle + self.busted_fov*.5, self.angle - self.busted_fov *.5)

		love.graphics.setColor(255,(1. - self.alertness) * 255, 0, 64)
		love.graphics.arc("line", self.x, self.y, self.view_radius, self.angle + self.view_fov*.5, self.angle - self.view_fov *.5)

		if self.alerted then
			love.graphics.setColor (255, 0, 0, 128)
			love.graphics.setLineWidth (10.)
			love.graphics.arc("line", self.x, self.y, self.view_radius + math.sin(love.timer.getTime() * 10) * 5, self.angle + self.view_fov*.5, self.angle - self.view_fov *.5)
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
