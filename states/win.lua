local gui = require "Quickie"

local WinState = {}

function WinState:new ()
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

function WinState:enter()
	self.zoombase = math.max(
		love.graphics.getWidth() / self.imageobject:getWidth(),
		love.graphics.getHeight() / self.imageobject:getHeight()
		)

	self.bustedlabel = {x = love.window.getWidth(), y = 0, scale = 20}
	Timer.tween (0.5, self.bustedlabel, {x = love.window.getWidth() / 5., y = love.window.getHeight() / 2.5, scale = 1})
	Timer.add (0.5, function() Sound.static.punch:play() end)
	Sound.static.whip:play()
	Sound.static.yeehaa:play()
end

function WinState:update (dt)
	local prev_state = Gamestate.prev()
	if prev_state then
		prev_state:update(dt)
	end

	gui.group.push({grow = "down", pos = {
			love.graphics.getWidth() * 0.7,
			love.graphics.getHeight() * 0.7} })
	if gui.Button ({text = "Continue!"}) then
		Gamestate.pop()
	end
	if gui.Button ({text = "Quit!"}) then
		os.exit()
	end
	if gui.Button ({text = "Credits!"}) then
		Gamestate.push(states.credits)
	end

	if gui.Checkbox{checked = config.sound, text = "Sound", size = {"tight"}} then
		config.sound = not config.sound
	end

	gui.group.pop()
end

function WinState:draw(dt)
	local prev_state = Gamestate.prev()
	if prev_state then
		prev_state:draw()
	end

	love.graphics.setColor (10, 250, 50, 128)
	love.graphics.rectangle ('fill', 0, 0, love.window.getWidth(), love.window.getHeight())

--	love.graphics.draw(self.imageobject,
--		love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0,
--		self.zoombase, self.zoombase,
--		self.imageobject:getWidth()/2, -- offset x
--		self.imageobject:getHeight()/2) -- offset y


	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.setFont(fonts.megalarge)
	love.graphics.print("Freedom!!",
			self.bustedlabel.x, self.bustedlabel.y,
--			love.window.getWidth() / 2., love.window.getHeight() / 2.,
			-0.2,
			self.bustedlabel.scale, self.bustedlabel.scale
			)
	love.graphics.setColor({255, 255, 255, 255})

	love.graphics.setFont(fonts.sugarsmall)
	gui.core.draw()
end

function WinState:keypressed(key, code)
	gui.keyboard.pressed(key)
end

-- LÖVE 0.9
function WinState:textinput(str)
	gui.keyboard.textinput(str)
end


return WinState

