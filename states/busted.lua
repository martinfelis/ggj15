local gui = require "Quickie"

local BustedState = {}

function BustedState:new ()
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

function BustedState:enter()
	self.zoombase = math.max(
		love.graphics.getWidth() / self.imageobject:getWidth(),
		love.graphics.getHeight() / self.imageobject:getHeight()
		)

	self.bustedlabel = {x = love.graphics.getWidth(), y = 0, scale = 20}
	Timer.tween (0.5, self.bustedlabel, {x = love.graphics.getWidth() / 5., y = love.graphics.getHeight() / 2.5, scale = 1})
	Timer.add (0.5, function() Sound.static.punch:play() end)
	Sound.static.whip:play()
end

function BustedState:update (dt)
	local prev_state = Gamestate.prev()
	if prev_state then
		prev_state:update(dt)
	end

	gui.group.push({grow = "down", pos = {
			love.graphics.getWidth() * 0.7,
			love.graphics.getHeight() * 0.7} })
	if gui.Button ({text = "Retry!"}) then
		Signals.emit ('busted-retry')
		Gamestate.pop()
	end
	if gui.Button ({text = "Quit!"}) then
		os.exit()
	end

	if gui.Checkbox{checked = config.sound, text = "Sound", size = {"tight"}} then
		config.sound = not config.sound
	end

	gui.group.pop()
end

function BustedState:draw(dt)
	local prev_state = Gamestate.prev()
	if prev_state then
		prev_state:draw()
	end

	love.graphics.setColor (255, 0, 0, 128)
	love.graphics.rectangle ('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

--	love.graphics.draw(self.imageobject,
--		love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0,
--		self.zoombase, self.zoombase,
--		self.imageobject:getWidth()/2, -- offset x
--		self.imageobject:getHeight()/2) -- offset y


	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.setFont(fonts.megalarge)
	love.graphics.print("BUSTED!!",
			self.bustedlabel.x, self.bustedlabel.y,
--			love.graphics.getWidth() / 2., love.graphics.getHeight() / 2.,
			-0.2,
			self.bustedlabel.scale, self.bustedlabel.scale
			)
	love.graphics.setColor({255, 255, 255, 255})

	love.graphics.setFont(fonts.sugarsmall)
	gui.core.draw()
end

function BustedState:keypressed(key, code)
	gui.keyboard.pressed(key)
end

-- LÖVE 0.9
function BustedState:textinput(str)
	gui.keyboard.textinput(str)
end

return BustedState

