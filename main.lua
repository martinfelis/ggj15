require ("strict")

-- useful global requires
Gamestate = require "hump.gamestate"

-- require States
local LevelBaseClass = require("states.levelbase")
local LevelOneClass = require("states.level1")
local MenuClass = require("states.menu")

-- newFooBar
newWall = require ("entities.wall")
newPlayer = require ("entities.player")

-- some global dicts
fonts = {}
states = {}

function love.load ()
	-- preload fonts
	fonts = {
		[12] = love.graphics.newFont(12),
		[20] = love.graphics.newFont(20),
	}
	love.graphics.setBackgroundColor(17,17,17)
	love.graphics.setFont(fonts[12])

	-- create all states
	states.menu = MenuClass:new()
	states.levelbase = LevelBaseClass:new ()
	states.levelone = LevelOneClass:new ()

	-- start initial state
    Gamestate.registerEvents()
    Gamestate.switch(states.levelone)

end

function love.draw ()

end

function love.update (dt)

end

function love.keypressed (key)

end
