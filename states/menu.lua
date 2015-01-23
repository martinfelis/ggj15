local gui = require "Quickie"

local MenuClass = {}

function MenuClass:new ()
	local newInstance = {}

	-- group defaults
	gui.group.default.size[1] = 150
	gui.group.default.size[2] = 25
	gui.group.default.spacing = 5

	self.__index = self
	return setmetatable(newInstance, self)
end


function MenuClass:update (dt)
	gui.group.push({grow = "down", pos = {
			love.graphics.getWidth() * 0.7,
			love.graphics.getHeight() * 0.7} })
	if gui.Button ({text = "Play!"}) then
		Gamestate.switch(states.levelone)
	end
	if gui.Button ({text = "Quit!"}) then
		os.exit()
	end
	if gui.Button ({text = "Credits!"}) then
		os.exit()
	end

	if gui.Checkbox{checked = config.sound, text = "Sound", size = {"tight"}} then
        config.sound = not config.sound
    end


	gui.group.pop()
end

function MenuClass:draw(dt)
	gui.core.draw()
end


return MenuClass

