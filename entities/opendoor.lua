
local function newDoor(world, x, y, width, height)
	local door = {}

	-- move center
	x = x + width/2
	y = y + height/2
	
	door.body = love.physics.newBody(world, x, y, "dynamic")
	door.shape = love.physics.newRectangleShape(width, height)
	door.fixture = love.physics.newFixture(door.body, door.shape)
	
	door.hinge = love.physics.newBody(world, x, y + width/2)

	local joint = love.physics.newRevoluteJoint(door.body, door.hinge, x, y - height/2 + width/2, false)

	function door:draw()
		love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	end

	return door
end
return newDoor