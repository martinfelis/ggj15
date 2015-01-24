require ("strict")

-- useful global requires
Gamestate = require "hump.gamestate"
Camera = require "hump.camera"
matrix = require "utils.matrix"
Signals = require "hump.signal"
Timer = require "hump.timer"
pathfunctions = require "utils.pathfunctions"

-- require States
local GameStateClass = require("states.game")
local MenuStateClass = require("states.menu")
local BustedState = require("states.busted")
local ExampleMenuStateClass = require("states.examplemenu")
local Credits = require("states.credits")
local Story = require("states.story")

local AudioManager = require("audiomanager")

vector = require("hump.vector")
newPlayer = require ("entities.player")

sketch_shader = {}
noise_texture = {}

-- some global dicts
fonts = {}
states = {}
config = { sound = true }
audio = AudioManager:new()

-- game design parameters
GVAR = {
	spotlight_realize_time=1.5
}

io.stdout:setvbuf("no")

function love.load ()
	love.window.setTitle("Prison Broke")

	-- setup of the sketching shader
	sketch_shader = love.graphics.newShader ("shader/sketch.fs")
	noise_texture = love.image.newImageData(50, 50)
	noise_texture:mapPixel(function(x,y)
		local l = love.math.noise (x,y) * 255 
		return l,l,l,l
	end)
	noise_texture = love.graphics.newImage(noise_texture)
	noise_texture:setWrap ("repeat", "repeat")
	noise_texture:setFilter("linear", "linear")
	noise_texture:setFilter("nearest", "nearest")
	sketch_shader:send("noise_texture", noise_texture)

	-- preload fonts
	fonts = {
		[12] = love.graphics.newFont(12),
		[20] = love.graphics.newFont(20),
		tinet = love.graphics.newFont("fonts/tinet/TungusFont_Tinet.ttf", 30),
		sugar = love.graphics.newFont("fonts/softsugarplain/Softplain.ttf", 30),
		sugarlarge = love.graphics.newFont("fonts/softsugarplain/Softplain.ttf", 50),
		megalarge = love.graphics.newFont("fonts/softsugarplain/Softplain.ttf", 150),
		sugarsmall = love.graphics.newFont("fonts/softsugarplain/Softplain.ttf", 18),
	}
	love.graphics.setBackgroundColor(17,17,17)
	love.graphics.setFont(fonts[12])

	-- create all states
	states.menu = MenuStateClass:new()
	states.examplemenu = ExampleMenuStateClass:new()
	states.game = GameStateClass:new ()
	states.credits = Credits:new ()
	states.story = Story:new ()
	states.busted = BustedState:new ()

	-- start initial state
    Gamestate.registerEvents()
    Gamestate.push(states.game)
    -- states.story:selectstories{"intro"}
    -- Gamestate.push(states.story)
    -- Gamestate.push(states.credits)
    -- Gamestate.push(states.menu)
end

function love.draw ()
end

function love.update (dt)
	Timer.update (dt)
end

function love.keypressed (key)

end
