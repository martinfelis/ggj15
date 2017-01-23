local gui = require "Quickie"

local Credits = {}

local CREDIT_LINE_DISTANCE = 40
local CREDIT_SPEED = 10

function Credits:new ()
	local newInstance = {}

	newInstance.credits = {
		"Prison Broke",
		" - Global Game Jam 2015",
		"",
		"SimonPtr",
		"",
		"Phaiax (invisibletower.de)",
		"",
		"fysx (fysx.org)",
		"",
		"bitowl"
	}

	self.__index = self
	return setmetatable(newInstance, self)
end


function Credits:enter()
	self.pos = 0
end

function Credits:update (dt)
--	self.pos = self.pos - dt*CREDIT_SPEED
	if gui.Button ({text = "Back", size={150, 50}, pos = {
		love.graphics.getWidth() * 0.7,
		love.graphics.getHeight() * 0.8}}) then
		Gamestate.pop()
	end
end

function Credits:draw(dt)
	love.graphics.setFont(fonts.sugarlarge)
	for i = 1, #self.credits do
		love.graphics.print(self.credits[i],
		love.graphics.getWidth() * 0.1,
		self.pos + i * CREDIT_LINE_DISTANCE)
	end
	gui.core.draw()
end

function Credits:keypressed(key)
	if key=="escape" or key==" " then
		Gamestate.switch(states.menu)
	end
end

return Credits

