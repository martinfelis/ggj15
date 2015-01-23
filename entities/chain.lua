local CHAIN_PART_WIDTH = 20
local CHAIN_PART_HEIGHT = 10
local SPACE_BETWEEN_PARTS = 5;
local CHAIN_PART_COUNT = 10

local function newChain (world, player1, player2)
	local chain = {
		player1 = player1,
		player2 = player2,
		parts = {}
	}
	
	-- create chain parts
	
	for i = 1, CHAIN_PART_COUNT, 1 do	
		local part = {}
		part.body = love.physics.newBody(world, 0, 0, "dynamic")	
		part.shape = love.physics.newRectangleShape(CHAIN_PART_WIDTH, CHAIN_PART_HEIGHT)
		part.fixture = love.physics.newFixture(part.body, part.shape)
		
		part.fixture:setGroupIndex(-1)
		part.fixture:setMask(1,2);
		
		table.insert(chain.parts, part)
		
		if (i>1) then
			love.physics.newWeldJoint(chain.parts[i-1].body, chain.parts[i].body, CHAIN_PART_WIDTH/2, 0, -CHAIN_PART_WIDTH/2, 0, false)
		end
	end
	
	-- first and last rope
	love.physics.newRopeJoint(player1.body, chain.parts[1].body, 0,0, -CHAIN_PART_WIDTH/2, 0, SPACE_BETWEEN_PARTS +32, false)
	
	love.physics.newRopeJoint(chain.parts[CHAIN_PART_COUNT].body, player2.body, CHAIN_PART_WIDTH/2, 0,  0, 0, SPACE_BETWEEN_PARTS +32, false)
	
	
	return chain
end

return newChain
