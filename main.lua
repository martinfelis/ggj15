require ("strict")

-- useful global requires
Gamestate = require "hump.gamestate"

-- require States
local LevelBaseClass = require("states.levelbase")
local LevelOneClass = require("states.level1")
local MenuClass = require("states.menu")
local ExampleMenuClass = require("states.examplemenu")
local Credits = require("states.credits")

vector = require("hump.vector")

-- newFooBar
newWall = require ("entities.wall")
newPlayer = require ("entities.player")

-- some global dicts
fonts = {}
states = {}
config = { sound = true }

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
	states.examplemenu = ExampleMenuClass:new()
	states.levelbase = LevelBaseClass:new ()
	states.levelone = LevelOneClass:new ()
	states.credits = Credits:new ()

	-- start initial state
    Gamestate.registerEvents()
    Gamestate.push(states.levelone)
    -- Gamestate.push(states.menu)
    -- Gamestate.push(states.credits)
end

function love.draw ()

end

function love.update (dt)

end

function love.keypressed (key)

end
