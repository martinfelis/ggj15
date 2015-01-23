local function newWall (world, x, y, width, height)
	local wall = {}
	-- move center
	x = x + width/2
	y = y + height/2
	
	wall.body = love.physics.newBody(world, x, y, "static")
	wall.shape = love.physics.newRectangleShape(width, height);
	wall.fixture = love.physics.newFixture(wall.body, wall.shape)
	
	function wall:draw()
		love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	end
	
	return wall
end
return newWall
