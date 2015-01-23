require ("strict")
local newPlayer = require ("entities.player")
local LevelBaseClass = require("states.levelbase")
local LevelOneClass = require("states.level1")

local gui = require "Quickie"
local Gamestate = require "hump.gamestate"

local player_image = love.graphics.newImage ("player.png")
local player_pos = { x = 30, y = 30 }
local fonts = {}

local player = {}

local states = {}

function love.load ()
	print ("Loading!")

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

	player = newPlayer (10, 200)

	-- create all states
	-- states.menu =
	states.levelbase = LevelBaseClass:new ()
	states.levelone = LevelOneClass:new ()

	-- start initial state
    Gamestate.registerEvents()
    Gamestate.switch(states.levelone)
end

function love.draw ()
--	print ("Drawing")
	love.graphics.draw (player_image, player_pos.x, player_pos.y)
	gui.core.draw()

	player:draw()
end

function love.update (dt)
--	print (string.format ("dt = %f", dt))

	player:update (dt)


	player_pos.x = player_pos.x + dt * 30

	gui.group.push({grow = "down", pos = {100,33}})
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
	if gui.Button ({text = "Click Mich!"}) then
		print ("Was clicked!")
	end
	gui.group.pop()
end

function love.keypressed (key)
	print (string.format ("key %s was pressed", key))
end
