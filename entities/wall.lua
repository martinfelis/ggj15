local function newPolygonWall (world, points, color)
	local wall = {}
	-- move center
	wall.x = points[1]
	wall.y = points[2]
	wall.width, wall.height = pathfunctions.getDimensions(points)


	wall.points = pathfunctions.transform(points,
							-wall.x, -wall.y)

	wall.body = love.physics.newBody(world, wall.x, wall.y, "static")
	-- wall.shape = love.physics.newRectangleShape(width, height)
	wall.shape = love.physics.newPolygonShape (unpack(wall.points))
	wall.fixture = love.physics.newFixture(wall.body, wall.shape)


	function wall:draw()
		love.graphics.polygon("line", self.body:getWorldPoints(self.shape:getPoints()))
		--love.graphics.setColor(200, 0, 0, 255)
		--love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
		--love.graphics.setColor(255, 255, 255, 255)
	end

	return wall
end


return newPolygonWall
