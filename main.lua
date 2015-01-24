require ("strict")

-- useful global requires
Gamestate = require "hump.gamestate"
Camera = require "hump.camera"

-- require States
local LevelBaseClass = require("states.levelbase")
local LevelOneClass = require("states.level1")
local MenuClass = require("states.menu")
local ExampleMenuClass = require("states.examplemenu")
local Credits = require("states.credits")
local Story = require("states.story")

local AudioManager = require("audiomanager")

vector = require("hump.vector")
newPlayer = require ("entities.player")

-- some global dicts
fonts = {}
states = {}
config = { sound = true }
audio = AudioManager:new()

io.stdout:setvbuf("no")

function love.load ()
	love.window.setTitle("Prison Broke")

	-- preload fonts
	fonts = {
		[12] = love.graphics.newFont(12),
		[20] = love.graphics.newFont(20),
		tinet = love.graphics.newFont("fonts/tinet/TungusFont_Tinet.ttf", 30),
		sugar = love.graphics.newFont("fonts/softsugarplain/Softplain.ttf", 30),
	}
	love.graphics.setBackgroundColor(17,17,17)
	love.graphics.setFont(fonts[12])

	-- create all states
	states.menu = MenuClass:new()
	states.examplemenu = ExampleMenuClass:new()
	states.levelbase = LevelBaseClass:new ()
	states.levelone = LevelOneClass:new ()
	states.credits = Credits:new ()
	states.story = Story:new ()

	-- start initial state
    Gamestate.registerEvents()
    Gamestate.push(states.levelone)
    -- states.story:selectstories{"intro"}
    -- Gamestate.push(states.story)
    -- Gamestate.push(states.credits)
end

function love.draw ()

end

function love.update (dt)

end

function love.keypressed (key)

end
