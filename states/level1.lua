local LevelBaseClass = require("states.levelbase")
local newPlayer = require ("entities.player")
local newChain = require("entities.chain")
local debugWorldDraw = require("debugWorldDraw")

local LevelOneClass = LevelBaseClass:new()

function LevelOneClass:new ()
	local newInstance = {}


	self.__index = self
	return setmetatable(newInstance, self)
end

function LevelOneClass:enter()
	LevelBaseClass.enter(self)

	self.player = newPlayer (self.world, 1, 80, 130)
	self.player2 = newPlayer (self.world, 2, 80, 250)
	self.chain = newChain(self.world, self.player, self.player2)
	self.player:init()
	self.player2:init()
	self.chain:init()

	local player_center = vector(self.player.body:getPosition()) * 0.5 + vector (self.player2.body:getPosition()) * 0.5
	self.camera = Camera (player_center.x, player_center.y)
end

function LevelOneClass:keypressed (key)
	LevelBaseClass.keypressed (self, key)

	print (key .. ' pressed, L1')
end


function LevelOneClass:draw()
	local player_center = vector(self.player.body:getPosition()) * 0.5 + vector (self.player2.body:getPosition()) * 0.5
	self.camera:lookAt (player_center.x, player_center.y)
	self.camera:attach()	

	LevelBaseClass.draw(self)

	self.player:draw()
	self.player2:draw()
	self.chain:draw()
	-- debugWorldDraw(self.world, 0, 0, 800, 600)
	debugWorldDraw(self.world, 0, 0, 800, 600)

	self.camera:detach()	
end
function LevelOneClass:update(dt)
	LevelBaseClass.update(self, dt)

	self.player:update (dt)
	self.player2:update(dt)
end

return LevelOneClass
