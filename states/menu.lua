local gui = require "Quickie"

local MenuClass = {}

function MenuClass:new ()
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

function MenuClass:enter()
	self.zoombase = math.max(
		love.graphics.getWidth() / self.imageobject:getWidth(),
		love.graphics.getHeight() / self.imageobject:getHeight()
		)
end

function MenuClass:update (dt)
	gui.group.push({grow = "down", pos = {
			love.graphics.getWidth() * 0.7,
			love.graphics.getHeight() * 0.7} })
	if gui.Button ({text = "Play!"}) then
		Gamestate.switch(states.game)
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

function MenuClass:draw(dt)

	love.graphics.draw(self.imageobject,
		love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0,
		self.zoombase, self.zoombase,
		self.imageobject:getWidth()/2, -- offset x
		self.imageobject:getHeight()/2) -- offset y


	love.graphics.setColor({255, 255, 255, 255})
	love.graphics.setFont(fonts.sugarlarge)
	love.graphics.print("PRISON BROKE",
			60,
			480,
			0,
			1, 1)
	love.graphics.setColor({255, 255, 255, 255})

	love.graphics.setFont(fonts.sugarsmall)
	gui.core.draw()

end


return MenuClass

