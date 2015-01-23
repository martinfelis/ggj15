LevelBaseClass = require("states.levelbase")

local LevelOneClass = LevelBaseClass:new()

function LevelOneClass:new ()
	local newInstance = {}


	self.__index = self
	return setmetatable(newInstance, self)
end


function LevelOneClass:keypressed (key)
	LevelBaseClass.keypressed (self, key)

	print (key .. ' pressed, L1')
end


return LevelOneClass