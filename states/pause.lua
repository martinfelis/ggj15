local gui = require "Quickie"

local PauseState = {}

function PauseState:new ()
	local newInstance = {
		imageobject = love.graphics.newImage("images/story/moon.jpg")
	}

	-- group defaults
	gui.group.default.size[1] = 150
	gui.group.default.size[2] = 25
	gui.group.default.spacing = 5

	self.__index = self
	return setmetatable(newInstance, self)
end

function PauseState:enter()
	self.zoombase = math.max(
		love.graphics.getWidth() / self.imageobject:getWidth(),
		love.graphics.getHeight() / self.imageobject:getHeight()
		)

	self.bustedlabel = {x = love.window.getWidth(), y = 0, scale = 20}
	Timer.tween (0.5, self.bustedlabel, {x = love.window.getWidth() / 5., y = love.window.getHeight() / 2.5, scale = 1})
	Sound.static.whip:play()
end

function PauseState:update (dt)
	local prev_state = Gamestate.prev()
	if prev_state then
		-- prev_state:update(dt)
	end

	gui.group.push({grow = "down", pos = {
			love.graphics.getWidth() * 0.4,
			love.graphics.getHeight() * 0.4} })



	if gui.Button ({text = "Resume"}) then
		Gamestate.pop()
	end

	if gui.Button ({text = "Retry!"}) then
		prev_state.busted = true
		Gamestate.pop()
	end
    gui.Label{text = "", size = {"tight"}}

	if gui.Button ({text = "Menu"}) then
		states.game.levelindex = 1
		Gamestate.switch(states.menu)
	end

	if gui.Checkbox{checked = config.sound, text = "Sound", size = {"tight"}} then
		config.sound = not config.sound
	end

	gui.group.pop()
end

function PauseState:draw(dt)
	gui.group.default.size[1] = 150 
	gui.group.default.size[2] = 50
	gui.group.default.spacing = 20

	local prev_state = Gamestate.prev()
	if prev_state then
		prev_state:draw()
	end

	love.graphics.setColor (0, 0, 0, 178)
	love.graphics.rectangle ('fill', 0, 0, love.window.getWidth(), love.window.getHeight())

	love.graphics.setFont(fonts.sugarsmall)
	gui.core.draw()
end

function PauseState:keyreleased(key)
	if key=="escape" and not self.pause then
		Gamestate.pop()
	end
end

function PauseState:keypressed(key, code)
	gui.keyboard.pressed(key)
end

-- LÖVE 0.9
function PauseState:textinput(str)
	gui.keyboard.textinput(str)
end

return PauseState

