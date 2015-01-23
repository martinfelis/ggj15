require ("strict")

Gamestate = require "hump.gamestate"

local parseXml = require "utils.parsexml"
local serialize = require "utils.serialize"

local LevelBaseClass = require("states.levelbase")
local LevelOneClass = require("states.level1")
local MenuClass = require("states.menu")

newWall = require ("entities.wall")
newPlayer = require ("entities.player")

local fonts = {}

states = {}

function love.load ()
	print ("Loading!")

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
--	print (string.format ("dt = %f", dt))

end

function love.keypressed (key)
	print (string.format ("key %s was pressed", key))
end
