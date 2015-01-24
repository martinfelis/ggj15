local LevelBaseClass = require("states.levelbase")
local newPlayer = require ("entities.player")
local newChain = require("entities.chain")
local newSecurityCam = require("entities.securitycam")
local debugWorldDraw = require("debugWorldDraw")

local LevelOneClass = LevelBaseClass:new()

function LevelOneClass:new ()
	local newInstance = {}


	self.__index = self
	return setmetatable(newInstance, self)
end

function LevelOneClass:enter()
	LevelBaseClass.enter(self)

	self.player1 = newPlayer (self.world, 1, 80, 130)
	self.player2 = newPlayer (self.world, 2, 80, 250)
	self.chain = newChain(self.world, self.player1, self.player2)
	self.player1:init()
	self.player2:init()
	self.chain:init()
	self.cam = newSecurityCam(680, 420)
end

function LevelOneClass:keypressed (key)
	LevelBaseClass.keypressed (self, key)

	print (key .. ' pressed, L1')
end


function LevelOneClass:draw()
	LevelBaseClass.draw(self)

	self.player1:draw()
	self.player2:draw()
	self.chain:draw()
	self.cam:draw(self.player1, self.player2)
	-- debugWorldDraw(self.world, 0, 0, 800, 600)
end
function LevelOneClass:update(dt)
	LevelBaseClass.update(self, dt)

	self.player1:update(dt)
	self.player2:update(dt)
	self.cam:update(self.world, self.player1, self.player2)
end

return LevelOneClass
