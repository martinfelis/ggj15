local PLAYER_MOVE_FORCE = 150*4
local PLAYER_RADIUS = 40

local PLAYER_CONFIG = {
	{
		keys = {
			right = "right",
			left = "left",
			down = "down",
			up = "up"
		},
		image = "images/player.png",
		radius = PLAYER_RADIUS,
		center_x = 2,
		center_y = -3
	},
	{
		keys = {
			right = "d",
			left = "a",
			down = "s",
			up = "w"
		},
		image = "images/player.png",
		radius = PLAYER_RADIUS,
		center_x = 2,
		center_y = -3
	},
	{
		keys = {
			right = "l",
			left = "j",
			down = "k",
			up = "i"
		},
		image = "images/player.png",
		radius = PLAYER_RADIUS,
		center_x = 2,
		center_y = -3
	},
	{
		keys = {
			right = "l",
			left = "j",
			down = "k",
			up = "i"
		},
		image = "images/player.png",
		radius = PLAYER_RADIUS,
		center_x = 2,
		center_y = -3
	},
	{
		keys = {
			right = "l",
			left = "j",
			down = "k",
			up = "i"
		},
		image = "images/player.png",
		radius = PLAYER_RADIUS,
		center_x = 2,
		center_y = -3
	}
}

local function newPlayer (world, id, x, y)
	local player = {
		id = id,
		x = x,
		y = y,
		image = love.graphics.newImage(PLAYER_CONFIG[id].image),
		keys = PLAYER_CONFIG[id].keys,
		radius = PLAYER_CONFIG[id].radius,
		center_x = PLAYER_CONFIG[id].center_x,
		center_y = PLAYER_CONFIG[id].center_y,
		angle = 0, -- needed so the player does not turn wildly at slow speed
		cycle_phase = 0.,
		speed = 0.,
	}

	-- physics
	player.body = love.physics.newBody(world, 0, 0, "dynamic")
	player.body:setLinearDamping(5)
	player.shape = love.physics.newCircleShape(player.radius)
	player.fixture = love.physics.newFixture(player.body, player.shape)
	player.fixture:setUserData("player")
	player.body:setMass (0.1)
	-- so that the rope does not colllide with players
	player.fixture:setCategory(id+1)  -- category 1 is for everyone

	print (string.format ("Created new player at %f,%f", x, y))

	-- changes the position of the player to the right
	function player:init()
		player.body:setPosition(self.x, self.y);
	end

	function player:update (dt)
		local velX, velY = self.body:getLinearVelocity()
		local vel = vector(velX, velY)

		local right = love.keyboard.isDown(player.keys.right) and 1 or 0
		local left = love.keyboard.isDown(player.keys.left) and 1 or 0
		if (right==1 or left==1) then
			vel.x = (right-left)*PLAYER_MOVE_FORCE
		end

		local up = love.keyboard.isDown(player.keys.up) and 1 or 0
		local down = love.keyboard.isDown(player.keys.down) and 1 or 0
		if (up==1 or down==1) then
			vel.y = (down-up)*PLAYER_MOVE_FORCE
		end

		if (up==1 or down==1 or left == 1 or right == 1) then
			vel:normalize_inplace()
			vel = vel * PLAYER_MOVE_FORCE
		end

		self.speed = vel:len()

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

		if not up and not down and not left and not right then
			self.cycle_phase = self.cycle_phase * self.speed
		end

		self.body:setLinearVelocity(vel.x, vel.y)

		self.body:setAngle(math.atan2(vel.x, -vel.y))
	--	self.body:setAngle()
--[[		if (love.keyboard.isDown("right")) then
			self.body:setLinearVelocity(PLAYER_MOVE_FORCE, 0)
		end
		if (love.keyboard.isDown("up")) then
			self.body:setLinearVelocity(0, -PLAYER_MOVE_FORCE)
		end
		if (love.keyboard.isDown("down")) then
			self.body:setLinearVelocity(0, PLAYER_MOVE_FORCE)
		end]]--
	end

	function player:draw ()
		local x,y = self.body:getLinearVelocity()

		if (math.abs(x)+math.abs(y)>100) then
			self.angle = math.atan2(x, -y)
--			print(string.format("angle %f (%f, %f)",self.angle,x,y))
		end

		love.graphics.draw(self.image, self.body:getX(), self.body:getY(),self.angle, 2,2,self.image:getWidth() /2, self.image:getHeight()/2)
--		love.graphics.circle("line", self.body:getX(), self.body:getY(), self.shape:getRadius())

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
		love.graphics.rotate (self.angle)
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

	return player
end

return newPlayer
