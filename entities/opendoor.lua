
local function newOpenDoor(world, x, y, width, height, jointLeft, doorLeft)
	print("CREATE DOOR " .. (jointLeft and 1 or 0) .. "" .. (doorLeft and 1 or 0))
	local door = {
		left = jointLeft,
		doorLeft = doorLeft,
		has_switch = false,
		opener = {},
		isopen = false
	}
	local leftX = x
	local upY = y

	-- move center
	x = x + width/2
	y = y + height/2

	door.body = love.physics.newBody(world, x, y, "dynamic")
	door.shape = love.physics.newRectangleShape(width, height)
	door.fixture = love.physics.newFixture(door.body, door.shape)

	if (width > height) then -- breit
		local jointy = y -- + height/2
		local left = x - width/2 + height/2 --x
		local right = x + width/2 - height/2 --x + width
		door.leftHinge = love.physics.newBody(world, left, jointy)
		door.rightHinge = love.physics.newBody(world, right, jointy)
		door.leftJoint = love.physics.newRevoluteJoint(door.body, door.leftHinge, left, jointy, false)
		door.rightJoint = love.physics.newRevoluteJoint(door.body, door.rightHinge, right, jointy, false)
		door.leftJoint:setLimitsEnabled(true)
		door.rightJoint:setLimitsEnabled(true)

		door.leftJoint:setLimits(-math.pi/2, math.pi/2)
		door.rightJoint:setLimits(-math.pi/2, math.pi/2)

		-- if (doorLeft) then
		-- 	door.leftJoint:setLimits(0, math.pi/2)
		-- 	door.rightJoint:setLimits(math.pi, 1.5*math.pi)
		-- else
		-- 	door.leftJoint:setLimits(1.5*math.pi, 2*math.pi)	
		-- 	door.rightJoint:setLimits(0, math.pi/2)
		-- end

	else -- hochkant
		local jointx = x
		local up = y - height/2 + width/2 --y - height/2
		local down = y + height/2 - width/2 --y + height - height/2
		door.upHinge = love.physics.newBody(world, jointx, up)
		door.downHinge = love.physics.newBody(world, jointx, down)
		door.upJoint = love.physics.newRevoluteJoint(door.body, door.upHinge, jointx, up, false)
		door.downJoint = love.physics.newRevoluteJoint(door.body, door.downHinge, jointx, down, false)
		door.upJoint:setLimitsEnabled(true)
		door.downJoint:setLimitsEnabled(true)
		door.upJoint:setLimits(-math.pi/2, math.pi/2)
		door.downJoint:setLimits(-math.pi/2, math.pi/2)
		-- if (doorLeft) then
		-- 	door.upJoint:setLimits(-math.pi/2, 0)
		-- 	door.downJoint:setLimits(0, math.pi/2)
		-- else			
		-- 	door.upJoint:setLimits(0, math.pi/2)
		-- 	door.downJoint:setLimits(-math.pi/2, 0)
		-- end
	end

	function door:draw()
		love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
		if (self.isopen) then
			love.graphics.setLineWidth(2)
			if (width > height) then
				if (self.left) then
					love.graphics.arc("line", leftX, upY + height/2, width, -math.pi/2, math.pi/2)
--						love.graphics.arc("line", leftX, upY+height, width > height and width or height, 1.5*math.pi, 2*math.pi)
--						love.graphics.arc("line", leftX, upY, width > height and width or height, 0, math.pi/2)
				else
					love.graphics.arc("line", leftX + width, upY + height/2, width, math.pi/2, 1.5*math.pi)	
						--love.graphics.arc("line", leftX+width, upY, width > height and width or height, math.pi, 1.5*math.pi)
						--love.graphics.arc("line", leftX+width, upY, width > height and width or height, math.pi/2, math.pi)
				end
			else
				if (self.left) then
					love.graphics.arc("line", leftX + width/2, upY, height, 0, math.pi)
						--love.graphics.arc("line", leftX+width, upY, width > height and width or height, math.pi/2, math.pi)
						--love.graphics.arc("line", leftX, upY, width > height and width or height, 0, math.pi/2)
				else
					love.graphics.arc("line", leftX + width/2, upY + height, height, math.pi, 2*math.pi)
						--love.graphics.arc("line", leftX+width, upY+height, width > height and width or height, math.pi, 1.5*math.pi)
						--love.graphics.arc("line", leftX, upY+height, width > height and width or height, 1.5*math.pi, 2*math.pi)
				end
			end
		end
	end

	function door:open()
		self.isopen = true
		if width > height then
			if (self.left) then
				door.rightJoint:destroy()				
			else
				door.leftJoint:destroy()
			end
		else
			if (self.left) then
				door.downJoint:destroy()
			else
				door.upJoint:destroy()
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