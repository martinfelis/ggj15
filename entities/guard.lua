local GUARD_REALIZE_TIME = 2
local function newGuard (x, y)
	-- TODO pass path to walk on
	local guard = {
		x = x,
		y = y,
		alert = false,
		alerttime = 0,
		testingfor = 1,
		radius = 170,
		angle = 1.,
		fov = math.pi/2
	}

	function guard:update(dt, players, world, totalTime)

		-- walk
		if self.pathpoints then
			self.x, self.y = pathfunctions.walk(self.pathpoints, totalTime, self.speed)
		end

		self.alert = false
		self.alerttime = self.alerttime + dt
		self.angle = self.angle + dt * 0.4
		if self.angle > 2*math.pi then
			self.angle = self.angle - 2*math.pi
		elseif self.angle < 0 then
			self.angle= self.angle + 2*math.pi
		end
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

		local forward = vector (100., 0.)
		forward:rotate_inplace(self.angle)
		love.graphics.setColor (255, 0, 0, 255)
		love.graphics.line (self.x, self.y, self.x + forward.x, self.y + forward.y)
	end

	return guard
end
return newGuard
