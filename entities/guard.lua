
local function newGuard (x, y)
	-- TODO pass path to walk on
	local guard = {
		x = x,
		y = y,
		alert1 = false,
		alert2 = false,
		testingfor = 1,
		radius = 170,
		angle1 = math.rad(90),
		angle2 = math.rad(180)
	}


	local function angleBetweenAngles(angle, angle1, angle2)
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
	--]]	    std::swap(angle1, angle2);
		end
		-- check if it passes through zero
		if (angle1 <= angle2) then
			return target >= angle1 and target <= angle2;
		else
			return target >= angle1 or target <= angle2;
		end

--[[		local a = math.deg(angle1)
		local b = math.deg(angle)
		local c = math.deg(angle2)

		if (c > a) then
			local tmp = c
			c = a
			a = tmp
		end

		return (c - a) % 180 >=0 and b >= a and b <= c]]--
	end

	function guard:update(world, player1, player2)

		local function callback(fixture, x, y, xn, yn, fraction)

			if (fixture:getUserData() == "chain") then -- you can't hide behind your chains
				return -1
			end

			if (fixture:getUserData() == "player1") then
				return -1
			end
			if (fixture:getUserData() == "player2") then
				return -1
			end


			-- we hit something bad
			if (self.testingfor == 1) then
				self.alert1 = false
				return 0
			end
			if (self.testingfor == 2) then
				self.alert2 = false
				return 0
			end
			
			return 0 -- immediately cancel the ray
		end

		-- cast rays

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

		print(string.format("%s, %s",self.alert1, self.alert2))
	end


	function guard:draw()

		if (self.alert1 or self.alert2) then
			love.graphics.setColor(255,96,0,128)
		else
			love.graphics.setColor(255,255,0,128)
		end

		love.graphics.arc("fill", self.x, self.y, self.radius, self.angle1, self.angle2)
	end

	return guard
end
return newGuard