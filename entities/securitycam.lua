
local function newSecurityCam (x, y)
	local cam = {
		x = x,
		y = y,
		alert = {},
		onealert = false,
		testingfor = 1,
		radius = 170
	}

	function cam:update(dt, players, world)

		local function callback(fixture, x, y, xn, yn, fraction)
			print("callback %s",fixture:getUserData())
		

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
			if ((player.body:getX()-self.x)^2+(player.body:getY()-self.y)^2 > (self.radius+player.radius) * (self.radius+player.radius)) then 
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

		print(string.format("%s, %s",self.alert1, self.alert2))
	end

	function cam:draw()

		if (self.onealert) then
			love.graphics.setColor(255,96,0,128)
		else
			love.graphics.setColor(255,255,0,128)
		end

		love.graphics.circle("fill", self.x, self.y, self.radius)
--[[	love.graphics.setColor(255,255,255,255)

		love.graphics.circle("fill", self.nonAlert1X, self.nonAlert1Y, 5)

		if (self.alert1) then
			love.graphics.setColor( 255,0,0,255)
			love.graphics.circle("fill", self.alert1X, self.alert1Y, 5)
			love.graphics.circle("fill", self.alert1X + 10*self.alert1NX, self.alert1Y + 10*self.alert1NY, 3)
		end
		love.graphics.line(x,y,player1.body:getPosition())
		love.graphics.setColor(255,255,255,255)
		if (self.alert2) then
			love.graphics.setColor( 255,0,0,255)
			love.graphics.circle("fill", self.alert2X, self.alert2Y, 5)
			love.graphics.circle("fill", self.alert2X + 10*self.alert2NX, self.alert2Y + 10*self.alert2NY, 3)
		end
		
		love.graphics.line(x,y,player2.body:getPosition())
		love.graphics.setColor(255,255,255,255) ]]--
	end

	return cam
end
return newSecurityCam