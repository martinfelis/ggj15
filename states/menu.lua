local MenuClass = {}

function MenuClass:new ()
	local newInstance = {
		imageobject = love.graphics.newImage("images/story/moon.jpg"),
		first = true
	}

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
		love.graphics.getHeight() * 0.4} })
		if gui.Button ({text = "Play!"}) then
				Gamestate.push(states.selectplayers)
--				states.story:selectstories{"intro"}
--				Gamestate.switch(states.game)
--				Gamestate.push(states.story)
--				Timer.add(5, function()
--					if(Gamestate.current() == states.story) then
--						Gamestate.pop()
--						audio:configureCurrentMusic{}
--					end
--				end)
		end
		if gui.Button ({text = "Credits!"}) then
			Gamestate.push(states.credits)
		end
		if gui.Button ({text = "Quit!"}) then
			os.exit()
		end

		if gui.Checkbox{checked = config.sound, text = "Sound", size = {"tight"}} then
			config.sound = not config.sound
		end


		gui.group.pop()
	end

function MenuClass:draw(dt)
	gui.group.default.size[1] = 150 
	gui.group.default.size[2] = 50
	gui.group.default.spacing = 20
	
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

function MenuClass:keypressed(key, code)
	gui.keyboard.pressed(key)
	if key=="f12" then
		Gamestate.switch(states.game)
	end
end

-- LÖVE 0.9
function MenuClass:textinput(str)
	gui.keyboard.textinput(str)
end

return MenuClass

