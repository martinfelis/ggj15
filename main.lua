require ("strict")

local gui = require "Quickie"
local Gamestate = require "hump.gamestate"

local parseXml = require "utils.parsexml"
local serialize = require "utils.serialize"

local newPlayer = require ("entities.player")
local LevelBaseClass = require("states.levelbase")
local LevelOneClass = require("states.level1")

newWall = require ("entities.wall")
newPlayer = require ("entities.player")
newLevel = require ("level")

local player_image = love.graphics.newImage ("player.png")
local player_pos = { x = 30, y = 30 }
local fonts = {}

local world = {}
local player = {}
local player2 = {}
local wall = {}

local states = {}
local level = {}

function love.load ()
	print ("Loading!")
	level = newLevel ("level.svg")

	-- preload fonts
	fonts = {
		[12] = love.graphics.newFont(12),
		[20] = love.graphics.newFont(20),
	}
	love.graphics.setBackgroundColor(17,17,17)
	love.graphics.setFont(fonts[12])

	-- group defaults
	gui.group.default.size[1] = 150
	gui.group.default.size[2] = 25
	gui.group.default.spacing = 5


	-- create all states
	-- states.menu =
	states.levelbase = LevelBaseClass:new ()
	states.levelone = LevelOneClass:new ()

	-- start initial state
    Gamestate.registerEvents()
    Gamestate.switch(states.levelone)

	-- physics
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true) -- no gravity


	player = newPlayer (world, 1, 10, 200)
	player2 = newPlayer (world, 2, 40, 200)
	wall = newWall(world, 50, 0, 40, 100)

end

function love.draw ()
--	print ("Drawing")
	love.graphics.draw (player_image, player_pos.x, player_pos.y)
	gui.core.draw()

	for i,p in ipairs (level.walls) do
		love.graphics.polygon ("fill", p)
	end

	player:draw()
	player2:draw()
	wall:draw()
end

function love.update (dt)
	world:update(dt)




--	print (string.format ("dt = %f", dt))

	player:update (dt)
	player2:update(dt)

	player_pos.x = player_pos.x + dt * 30

	gui.group.push({grow = "down", pos = {100,33}})
	if gui.Button ({text = "Click Mich!"}) then
		print ("Was clicked!")
	end
	gui.group.pop()
end

function love.keypressed (key)
	print (string.format ("key %s was pressed", key))
end
