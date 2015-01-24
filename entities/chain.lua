local CHAIN_PART_WIDTH = 20
local CHAIN_PART_HEIGHT = 10
local SPACE_BETWEEN_PARTS = 5;
local CHAIN_PART_COUNT = 10

local function newChain (world, player1, player2)
	local chain = {
		player1 = player1,
		player2 = player2,
		parts = {},
		image = love.graphics.newImage("images/chain.png")
	}
	
	-- create chain parts
	
	for i = 1, CHAIN_PART_COUNT, 1 do	
		local part = {}
		part.body = love.physics.newBody(world, 0, 0, "dynamic")	
		part.shape = love.physics.newRectangleShape(CHAIN_PART_WIDTH, CHAIN_PART_HEIGHT)
		part.fixture = love.physics.newFixture(part.body, part.shape)
		part.fixture:setUserData("chain")
		part.body:setPosition(i*CHAIN_PART_WIDTH,0)
		part.body:setLinearDamping(10)

		-- chainparts should not collide with itself
		part.fixture:setGroupIndex(-1)
		--part.fixture:setMask(1,2);
		
		table.insert(chain.parts, part)
		
		if (i>1) then
			--love.physics.newWeldJoint(chain.parts[i-1].body, chain.parts[i].body, CHAIN_PART_WIDTH/2, 0, -CHAIN_PART_WIDTH/2, 0, false)
			local joint = love.physics.newRevoluteJoint(chain.parts[i-1].body, chain.parts[i].body, i*CHAIN_PART_WIDTH - CHAIN_PART_WIDTH/2, 0, false)
		end
	end
	
	-- first and last rope
	love.physics.newRopeJoint(player1.body, chain.parts[1].body, 0,0, CHAIN_PART_WIDTH-CHAIN_PART_WIDTH/2, 0, player1.radius, true)
	
	love.physics.newRopeJoint(chain.parts[CHAIN_PART_COUNT].body, player2.body, CHAIN_PART_COUNT * CHAIN_PART_WIDTH +CHAIN_PART_WIDTH/2, 0,  0, 0, player2.radius, true)
	

	-- changes the position of the chain to be linear between the players
	function chain:init()
		local startX, startY = player1.body:getPosition()
		local aimX, aimY = player2.body:getPosition()
		for i = 1, CHAIN_PART_COUNT, 1 do
			local chainX = startX + (i/CHAIN_PART_COUNT) * aimX
			local chainY = startY + (i/CHAIN_PART_COUNT) * aimY
			self.parts[i].body:setPosition(chainX, chainY)
		end

	end

	function chain:draw()
		for i = 1, CHAIN_PART_COUNT, 1 do
			love.graphics.draw(self.image, self.parts[i].body:getX(), self.parts[i].body:getY(), self.parts[i].body:getAngle(), 1,1,self.image:getWidth() /2, self.image:getHeight()/2)
		end
	end
	
	return chain
end

return newChain
