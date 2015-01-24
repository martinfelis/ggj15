local GUARD_REALIZE_TIME = 2
local GUARD_ROTATION_SPEED = 5
local function newGuard (x, y, world)
	-- TODO pass path to walk on
	local guard = {
		x = x,
		y = y,
		alert = false,
		alerttime = 0,
		testingfor = 1,
		radius = 170,
		angle = 1.,
		wishAngle = 0,
		fov = math.pi/2
	}
	guard.guide = love.physics.newBody(world, x, y, "dynamic")
	guard.body = love.physics.newBody(world, x, y+20, "dynamic")
	guard.shape = love.physics.newCircleShape(20)
	guard.fixture = love.physics.newFixture(guard.body, guard.shape)
	guard.body:setLinearDamping(5)
	guard.shape2 = love.physics.newCircleShape(20)
	guard.fixture2 = love.physics.newFixture(guard.guide, guard.shape2)


	guard.joint = love.physics.newRopeJoint(guard.guide, guard.body, 0,0,0,0, 1, false)

	function guard:update(dt, players, world, totalTime)

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

			if (math.abs (angle) < self.fov / 2.) then
				if ((player.body:getX()-self.x)^2+(player.body:getY()-self.y)^2 > (self.radius+player.radius) * (self.radius+player.radius)) then
				else
					self.alert = true
					self.testingfor = k
					world:rayCast(self.x, self.y, player.body:getX(), player.body:getY(), callback)
				end
			end
		end
	end

	function guard:draw()

		if (not self.alert) then
			self.alerttime = 0
		else
			if (self.alerttime >= GUARD_REALIZE_TIME) then
				-- TODO end game friendly
				print("a guard caught you")
				love.event.quit()
			end
		end

		love.graphics.setColor(255,(GUARD_REALIZE_TIME-self.alerttime)*(255/GUARD_REALIZE_TIME),0,128)
																		   -- fix löves wrong angle drawing
		love.graphics.arc("fill", self.x, self.y, self.radius, self.angle + self.fov*.5, self.angle - self.fov *.5)

--		local forward = vector (100., 0.)
--		forward:rotate_inplace(self.angle)
--		love.graphics.setColor (255, 0, 0, 255)
--		love.graphics.line (self.x, self.y, self.x + forward.x, self.y + forward.y)
	end

	return guard
end
return newGuard
