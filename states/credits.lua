local gui = require "Quickie"

local Credits = {}

local CREDIT_LINE_DISTANCE = 70
local CREDIT_SPEED = 10

function Credits:new ()
	local newInstance = {}

	newInstance.credits = {
		"All credits\n belong to",
		"These fantastic people",
		"in mystic order",
		"",
		"asd"
	}

	self.__index = self
	return setmetatable(newInstance, self)
end


function Credits:enter()
	self.pos = 0
end

function Credits:update (dt)
	self.pos = self.pos - dt*CREDIT_SPEED
end

function Credits:draw(dt)
	love.graphics.setFont(fonts[20])
	for i = 1, #self.credits do

		love.graphics.print(self.credits[i],
						200,
						self.pos + i * CREDIT_LINE_DISTANCE)
	end
end

function Credits:keypressed(key)
	if key=="escape" then
		Gamestate.pop()
	end
end


return Credits

