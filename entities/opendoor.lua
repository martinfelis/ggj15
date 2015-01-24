
local function newOpenDoor(world, x, y, width, height, left)
	local door = {
		left = left
	}

	-- move center
	x = x + width/2
	y = y + height/2
	
	door.body = love.physics.newBody(world, x, y, "dynamic")
	door.shape = love.physics.newRectangleShape(width, height)
	door.fixture = love.physics.newFixture(door.body, door.shape)
	
	if (width > height) then
		local left = x - width/2 + height/2
		local right = x + width/2 - height/2
		door.leftHinge = love.physics.newBody(world, left, y)
		door.rightHinge = love.physics.newBody(world, right, y)
		door.leftJoint = love.physics.newRevoluteJoint(door.body, door.leftHinge, left, y, false)
		door.rightJoint = love.physics.newRevoluteJoint(door.body, door.rightHinge, right, y, false)
	else
		local up = x - height/2 + width/2
		local down = x + height/2 - width/2
		door.upHinge = love.physics.newBody(world, up, y)
		door.downHinge = love.physics.newBody(world, down, y)
		door.upJoint = love.physics.newRevoluteJoint(door.body, door.upHinge, x, up, false)
		door.downJoint = love.physics.newRevoluteJoint(door.body, door.downHinge, x, down, false)
	end
	function door:draw()
		love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	end

	function door:open() 
		if (width > height) then
			if (left) then
				self.leftJoint:destroy()
			else
				self.rightJoint:destroy()
			end
		else
			if (left) then
				self.upJoint:destroy()
			else
				self.downJoint:destroy()
			end
		end
	end

	function door:canBeOpenedBy(switch)
	end

	return door
end
return newOpenDoor