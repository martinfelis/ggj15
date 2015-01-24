
local function newOpenDoor(world, x, y, width, height, left)
	local door = {
		left = left,
		has_switch = false,
		opener = {}
	}

	-- move center
	x = x + width/2
	y = y + height/2

	door.body = love.physics.newBody(world, x, y, "dynamic")
	door.shape = love.physics.newRectangleShape(width, height)
	door.fixture = love.physics.newFixture(door.body, door.shape)

	if (width > height) then -- breit
		local jointy = y + height/2
		local left = x
		local right = x + width
		door.leftHinge = love.physics.newBody(world, left, jointy)
		door.rightHinge = love.physics.newBody(world, right, jointy)
		door.leftJoint = love.physics.newRevoluteJoint(door.body, door.leftHinge, left, jointy, false)
		door.rightJoint = love.physics.newRevoluteJoint(door.body, door.rightHinge, right, jointy, false)
	else -- hochkant
		local jointx = x
		local up = y - height/2
		local down = y + height - height/2
		door.upHinge = love.physics.newBody(world, jointx, up)
		door.downHinge = love.physics.newBody(world, jointx, down)
		door.upJoint = love.physics.newRevoluteJoint(door.body, door.upHinge, jointx, up, false)
		door.downJoint = love.physics.newRevoluteJoint(door.body, door.downHinge, jointx, down, false)
	end

	function door:draw()
		love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	end

	function door:open()
		if width > height then
			if (left) then
				door.leftJoint:destroy()
			else
				door.rightJoint:destroy()
			end
		else
			if (left) then
				door.upJoint:destroy()
			else
				door.downJoint:destroy()
				door.body:applyForce(100,0)
			end
		end
	end

	function door:openIfNoSwitch()
		if not self.has_switch then
			self:open()
		end
	end

	function door:canBeOpenedBy(switch)
		self.has_switch = true
		table.insert(self.opener, switch)
		switch:addObserver(self)
	end

	function door:notify(switch)
		local opendoor = true
		for k,v in pairs(self.opener) do
			if (not v.on) then
				opendoor = false
				break
			end
		end
		if (opendoor) then
			self:open()
		end

	end

	return door
end
return newOpenDoor