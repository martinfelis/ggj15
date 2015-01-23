local CHAIN_PART_WIDTH = 10
local CHAIN_PART_HEIGHT = 5
local SPACE_BETWEEN_PARTS = 2;

local function newChain (world, player1, player2)
	local chain = {
		player1 = player1,
		player2 = player2,
		parts = {}
	}
	
	-- create chain parts
	
	for i = 1, 5, 1 do	
		local part = {}
		part.body = love.physics.newBody(world, 0, 0, "dynamic")	
		part.shape = love.physics.newRectangleShape(CHAIN_PART_WIDTH, CHAIN_PART_HEIGHT)
		part.fixture = love.physics.newFixture(part.body, part.shape)
		
		table.insert(chain.parts, part)
		
		if (i>1) then
			love.physics.newRopeJoint(chain.parts[i-1].body, chain.parts[i].body, CHAIN_PART_WIDTH, CHAIN_PART_HEIGHT/2, 0, CHAIN_PART_HEIGHT/2, SPACE_BETWEEN_PARTS, true)
		end
	end
	
	-- first and last rope
	love.physics.newRopeJoint(player1.body, chain.parts[1].body,  32,  32, 0, CHAIN_PART_HEIGHT/2, SPACE_BETWEEN_PARTS, true)
	
	love.physics.newRopeJoint(chain.parts[5].body, player2.body, CHAIN_PART_WIDTH, CHAIN_PART_HEIGHT/2,  32, 32, SPACE_BETWEEN_PARTS, true)
	
	
	return chain
end

return newChain
