
local function newGuard (x, y)
	-- TODO pass path to walk on
	local guard = {
		x = x,
		y = y,
		alert = false,
		testingfor = 1,
		radius = 170,
		angle = math.pi/2,
		fov = math.pi/2
	}


	local function angleBetweenAngles(angle, angle1, angle2)

		-- a,b,c >= 0; a,b,c < 360; a <= c)
		--[[if (angle1 > angle2) then
			local tmp = angle1
			angle1 = angle2 

		-- make the angle from angle1 to angle2 to be <= 180 degrees
		local target = math.deg(angle)
		angle1 = math.deg(angle1)
		angle2 = math.deg(angle2)

		print(string.format("TARGET %f  (%f, %f)",target, angle1, angle2))

		local rAngle = ((angle2 - angle1) % 360 + 360) % 360;
		print(rAngle)
		if (rAngle >= 180) then
			local tmp = angle1
			angle1 = angle2
			angle2 = tmp
		end
	
		--(c - a) % 180 >=0;b >= a && b <= c

		return (angle2 - angle1) % 180 >= 0 and angle >= angle1 and angle <= angle2]]--
		
	end

	function guard:update(dt, players, world)

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
			local rel_angle = self.angle - math.atan2((player.body:getX()-self.x), (player.body:getY()-self.y))
			print(string.format("angle %d: %f",k, 180/(2*math.pi)*(rel_angle)))

			self.alert = angleBetweenAngles(rel_angle, 0,0)
		end
		-- cast rays
--[[
		local arc1 = math.atan2(player1.body:getX()-self.x,(player1.body:getY()-self.y))
		local outside1 = not angleBetweenAngles(arc1, self.angle1, self.angle2)

		if (outside1 or (player1.body:getX()-self.x)^2+(player1.body:getY()-self.y)^2 > (self.radius+player1.radius) * (self.radius+player1.radius)) then
			self.alert1 = false
		else
			self.alert1 = true
			self.testingfor = 1
			world:rayCast(self.x, self.y, player1.body:getX(), player1.body:getY(), callback)
		end

		local arc2 = math.atan2(player2.body:getX()-self.x, player2.body:getY()-self.y)
		local outside2 = true --angleBetweenAngles(arc2, self.angle1, self.angle2)

		if (outside2 or (player2.body:getX()-self.x)^2+(player2.body:getY()-self.y)^2 > (self.radius+player2.radius) * (self.radius+player2.radius)) then
			self.alert2 = false
		else
			self.alert2 = true
			self.testingfor = 2
			world:rayCast(self.x, self.y, player2.body:getX(), player2.body:getY(), callback)
		end


		if (self.alert1 or self.alert2) then
			-- TODO lose game?
		end
]]--
		--print(string.format("%s, %s",self.alert1, self.alert2))
	end


	function guard:draw()

		if (self.alert) then
			love.graphics.setColor(255,96,0,128)
		else
			love.graphics.setColor(255,255,0,128)
		end
																		   -- fix löves wrong angle drawing
		love.graphics.arc("fill", self.x, self.y, self.radius, self.angle + self.fov*.5, self.angle - self.fov *.5)
	end

	return guard
end
return newGuard