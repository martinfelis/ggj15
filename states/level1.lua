local LevelBaseClass = require("states.levelbase")
local newPlayer = require ("entities.player")
local newChain = require("entities.chain")
local newSecurityCam = require("entities.securitycam")
local newSpotlight = require("entities.spotlight")
local newGuard = require("entities.guard")
local newOpenDoor = require("entities.opendoor")
local newSwitch = require("entities.switch")
local debugWorldDraw = require("debugWorldDraw")

NUM_PLAYERS = 2

local LevelOneClass = LevelBaseClass:new()

function LevelOneClass:new ()
	local newInstance = {}

	self.__index = self
	return setmetatable(newInstance, self)
end

function LevelOneClass:enter()
end

function LevelOneClass:keypressed (key)
	LevelBaseClass.keypressed (self, key)

	print (key .. ' pressed, L1')
end

function LevelOneClass:update(dt)
end

function LevelOneClass:draw()
	LevelBaseClass.draw(self)
end

return LevelOneClass
