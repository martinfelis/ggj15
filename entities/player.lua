local PLAYER_RADIUS = 32
local PLAYER_MOVE_FORCE = 150

local PLAYER_KEY_CONFIG = {
	{
		right = "right",
		left = "left",
		down = "down",
		up = "up"
	},
	{
		right = "d",
		left = "a",
		down = "s",
		up = "w"
	}
}

local function newPlayer (world, id,  x, y)
	local player = {
		image = love.graphics.newImage ("player.png"),
		id = id,
		keys = PLAYER_KEY_CONFIG[id]
	}

	-- physics
	player.body = love.physics.newBody(world, x, y, "dynamic")
	player.body:setLinearDamping(0.1)
	player.shape = love.physics.newCircleShape(PLAYER_RADIUS)
	player.fixture = love.physics.newFixture(player.body, player.shape)

	print (string.format ("Created new player at %f,%f", x, y))


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

		
		self.body:setLinearVelocity(vel.x, vel.y)
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
		love.graphics.draw (self.image, self.body:getX() - PLAYER_RADIUS, self.body:getY() - PLAYER_RADIUS)
		
		
		love.graphics.circle("line", self.body:getX(), self.body:getY(), self.shape:getRadius())
	end

	return player
end

return newPlayer
