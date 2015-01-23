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
	gui.group.push({grow = "down", pos = {100,33}})
	if gui.Button ({text = "Level1!"}) then
		Gamestate.switch(states.levelone)
		print ("Was clicked!")
	end
	if gui.Button ({text = "Click Mich!"}) then
		print ("Was clicked!")
	end
	if gui.Button ({text = "Click Mich!"}) then
		print ("Was clicked!")
	end
	if gui.Button ({text = "Click Mich!"}) then
		print ("Was clicked!")
	end
	if gui.Button ({text = "Click Mich!"}) then
		print ("Was clicked!")
	end
	gui.group.pop()
end

function MenuClass:draw(dt)
	gui.core.draw()
end


return MenuClass

