
local function newSecurityCam (x, y)
	local cam = {
		x = x,
		y = y,
		alert1 = false,
		alert2 = false,
		alert1X = 0,
		alert1Y = 0,
		alert2X = 0,
		alert2Y =0
	}

	function cam:update(world, player1, player2)
		self.alert1 = false
		self.alert2 = false
		local function callback(fixture, x, y, xn, yn, fraction)
			print("callback %s",fixture:getUserData())

			if (fixture:getUserData() == "player1") then
				-- the security cam can see the player
				self.alert1 = true
				self.alert1X = x
				self.alert1Y = y

				--love.event.quit()
			end
			if (fixture:getUserData() == "player2") then
				self.alert2 = true
				self.alert2X = x
				self.alert2Y = y
			end
			return 0 -- imediately cancel the ray
		end

		-- cast rays
		world:rayCast(self.x, self.y, player1.body:getX(), player1.body:getY(), callback)
		world:rayCast(self.x, self.y, player2.body:getX(), player2.body:getY(), callback)

		print(string.format("%s, %s",self.alert1, self.alert2))
	end

	function cam:draw(player1, player2)
		love.graphics.setColor(255,255,255,255)
		if (self.alert1) then
			love.graphics.setColor( 255,0,0,255)
			love.graphics.circle("fill", self.alert1X, self.alert1Y, 5)
		end
		love.graphics.line(x,y,player1.body:getPosition())
		love.graphics.setColor(255,255,255,255)
		if (self.alert2) then
			love.graphics.setColor( 255,0,0,255)
			love.graphics.circle("fill", self.alert2X, self.alert2Y, 5)
		end
		
		love.graphics.line(x,y,player2.body:getPosition())
		love.graphics.setColor(255,255,255,255)
	end

	return cam
end
return newSecurityCam