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
	LevelBaseClass.enter(self)

	self.players = {}
	self.objects = {}

	for i=1,NUM_PLAYERS,1 do
		table.insert(self.players, newPlayer (self.world, i, 0,50*i))
		if (i ~= 1) then
			table.insert(self.objects, newChain(self.world, self.players[i-1], self.players[i]))
		end
	end

	for k,player in pairs(self.players) do
		player:init()
	end
	for k,chain in pairs(self.objects) do
		chain:init()
	end
	table.insert(self.objects, newSecurityCam(680, 420))
	table.insert(self.objects, newSpotlight(400,440))
	table.insert(self.objects, newGuard(200,220))
	local switch = newSwitch(50, 50)
	table.insert(self.objects, switch)
	local door = newOpenDoor(self.world,70,40,20,80, false)
	table.insert(self.objects, door)
	door:canBeOpenedBy(switch)

	-- self.door:open()

	local player_center =  vector(0, 0)
	for k,player in pairs(self.players) do
		player_center = player_center + vector(player.body:getPosition()) * (1/table.getn(self.players))
	end
	-- vector(self.player1.body:getPosition()) * 0.5 + vector (self.player2.body:getPosition()) * 0.5
	self.camera = Camera (player_center.x, player_center.y)
end

function LevelOneClass:keypressed (key)
	LevelBaseClass.keypressed (self, key)

	print (key .. ' pressed, L1')
end

function LevelOneClass:update(dt)
	LevelBaseClass.update(self, dt)
	for k,player in pairs(self.players) do
		player:update(dt)
	end

	for k,object in pairs(self.objects) do
		if (object.update ~= nil) then
			object:update(dt, self.players, self.world)
		end
	end

	-- self.cam:update(self.world, self.player1, self.player2)
	-- self.spot:update(self.player1, self.player2)
	-- self.guard:update(self.world, self.player1, self.player2)
end

function LevelOneClass:draw()
	local player_center =  vector(0, 0)
	for k,player in pairs(self.players) do
		player_center = player_center + vector(player.body:getPosition()) * (1/table.getn(self.players))
	end
	self.camera:lookAt (player_center.x, player_center.y)

	LevelBaseClass.preDraw(self)
	self.camera:attach()

	LevelBaseClass.draw(self)

	for k,player in pairs(self.players) do
		player:draw()
	end

	for k,object in pairs(self.objects) do
		object:draw()
	end

--	self.cam:draw()
--	self.spot:draw()
--	self.guard:draw()
	debugWorldDraw(self.world, 0, 0, 800, 600)
	-- debugWorldDraw(self.world, 0, 0, 800, 600)
	love.graphics.setColor(255, 255, 255, 255)

	self.camera:detach()
	LevelBaseClass.postDraw(self)
end

return LevelOneClass
