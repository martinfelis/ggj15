require ("strict")

-- useful global requires
Gamestate = require "hump.gamestate"
Camera = require "hump.camera"
matrix = require "utils.matrix"
Signals = require "hump.signal"
Timer = require "hump.timer"
pathfunctions = require "utils.pathfunctions"
newInputMapper = require "InputMapper"
gui = require "Quickie"

-- require States
local GameStateClass = require("states.game")
local MenuStateClass = require("states.menu")
local BustedState = require("states.busted")
local WinState = require("states.win")
local SelectNumPlayersState = require("states.select_num_players")
local PauseState = require("states.pause")
local ExampleMenuStateClass = require("states.examplemenu")
local Credits = require("states.credits")
local Story = require("states.story")

local AudioManager = require("audiomanager")

vector = require("hump.vector")
newPlayer = require ("entities.player")

sketch_shader = {}
noise_texture = {}

local function Proxy(f)
	return setmetatable({}, {__index = function(t,k)
		local v = f(k)
		t[k] = v
		return v
	end})
end

Sound = {
	static = Proxy(function(path) return love.audio.newSource('sounds/'..path..'.ogg', 'static') end),
	stream = Proxy(function(path) return love.audio.newSource('music/'..path..'.ogg', 'stream') end)
}

-- some global dicts
fonts = {}
states = {}
config = {
	sound = true,
	numplayer = 2
}
audio = AudioManager:new()
sounds = { }
levels = { "tutorial1.svg", "tutorial2.svg", "tutorial3.svg", "tutorial4.svg", "level1.svg", "level_out.svg"}
step_sounds = {}
input_mapper = {}

-- game design parameters
GVAR = {
	alert_realize_time=2,
	alert_increase_rate=0.5,
	alert_decrease_rate=0.3,
	guard_hunt_speed=200,
	guard_hunt_timeout=2.,
	guard_hunt_look_timeout = 5.,
}

io.stdout:setvbuf("no")

function love.load ()
	love.window.setTitle("Prison Broke")

	input_mapper = newInputMapper()

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
	love.graphics.setFont(fonts.sugarlarge)

	-- create all states
	states.menu = MenuStateClass:new()
	states.examplemenu = ExampleMenuStateClass:new()
	states.game = GameStateClass:new ()
	states.credits = Credits:new ()
	states.story = Story:new ()
	states.busted = BustedState:new ()
	states.win = WinState:new()
	states.pause = PauseState:new()
	states.selectplayers = SelectNumPlayersState:new()

	step_sounds = {
		Sound.static.footstep1,
		Sound.static.footstep2,
		Sound.static.footstep3,
		Sound.static.footstep4
	}

	-- start initial state
	Gamestate.registerEvents()
			Gamestate.push(states.menu)
 	--Gamestate.push(states.game)
	-- states.story:selectstories{"intro"}
	-- Gamestate.push(states.story)
	-- Gamestate.push(states.credits)
	--Gamestate.switch (states.menu)
	-- Gamestate.push(states.menu)

	Sound.stream.theme:play()
	Sound.stream.theme:setLooping (true)

	gui.group.default.size[1] = 150
	gui.group.default.size[2] = 10
	gui.group.default.spacing = 5
end

function love.draw ()
end

function love.update (dt)
	Timer.update (dt)
--	print(input_mapper:query (1, "right"))
end

function love.keypressed (key)

end
