local LevelBaseClass = require("states.levelbase")
local newPlayer = require ("entities.player")

local LevelOneClass = LevelBaseClass:new()

function LevelOneClass:new ()
	local newInstance = {}


	self.__index = self
	return setmetatable(newInstance, self)
end

function LevelOneClass:enter()
	LevelBaseClass.enter(self)

	self.player = newPlayer (self.world, 1, 10, 200)
	self.player2 = newPlayer (self.world, 2, 40, 200)
	self.wall = newWall(self.world, 50, 0, 40, 100)

end

function LevelOneClass:keypressed (key)
	LevelBaseClass.keypressed (self, key)

	print (key .. ' pressed, L1')
end


function LevelOneClass:draw()
	LevelBaseClass.draw(self)

	self.player:draw()
	self.player2:draw()
	self.wall:draw()

end

function LevelOneClass:update(dt)
	LevelBaseClass.update(self, dt)

	self.player:update (dt)
	self.player2:update(dt)
end

return LevelOneClass