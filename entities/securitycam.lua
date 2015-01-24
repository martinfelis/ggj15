
local function newSecurityCam (x, y)
	local cam = {
		x = x,
		y = y,
		alert1 = false,
		alert2 = false,
		testingfor = 1,
		radius = 170
	}

	function cam:update(world, player1, player2)

		local function callback(fixture, x, y, xn, yn, fraction)
			print("callback %s",fixture:getUserData())
		

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
		if ((player1.body:getX()-self.x)^2+(player1.body:getY()-self.y)^2 > (self.radius+player1.radius) * (self.radius+player1.radius)) then 
			self.alert1 = false
		else
			self.alert1 = true
			self.testingfor = 1
			world:rayCast(self.x, self.y, player1.body:getX(), player1.body:getY(), callback)
		end

		if ((player2.body:getX()-self.x)^2+(player2.body:getY()-self.y)^2 > (self.radius+player2.radius) * (self.radius+player2.radius)) then 
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

	function cam:draw()

		if (self.alert1 or self.alert2) then
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