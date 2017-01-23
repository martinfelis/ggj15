local SelectNumPlayersClass = {}

function SelectNumPlayersClass:new ()
	local newInstance = {
		imageobject = love.graphics.newImage("images/story/moon.jpg"),
		first = true
	}

	self.__index = self
	return setmetatable(newInstance, self)
end

function SelectNumPlayersClass:leave()
	gui.group.default.size[1] = 150
	gui.group.default.size[2] = 10
	gui.group.default.spacing = 5
end

function SelectNumPlayersClass:enter()

	self.zoombase = math.max(
		love.graphics.getWidth() / self.imageobject:getWidth(),
		love.graphics.getHeight() / self.imageobject:getHeight()
		)
end

function SelectNumPlayersClass:update (dt)
	gui.group.push({grow = "right", pos = {
		love.graphics.getWidth() * 0.15,
		love.graphics.getHeight() * 0.4} })
		config.numplayer = 0

		if gui.Button ({text = "2"}) then
			config.numplayer = 2
		elseif gui.Button ({text = "3"}) then
			config.numplayer = 3
		elseif gui.Button ({text = "4"}) then
			config.numplayer = 4
		end

		if config.numplayer ~= 0 then
				states.story:selectstories{"intro"}
				Gamestate.switch(states.game)
				Gamestate.push(states.story)
				Timer.add(5, function()
					if(Gamestate.current() == states.story) then
						Gamestate.pop()
						audio:configureCurrentMusic{}
					end
				end)
		end
	gui.group.pop()

	if gui.Button ({text = "Back", size={150, 50}, pos = {
		love.graphics.getWidth() * 0.7,
		love.graphics.getHeight() * 0.8}}) then
		Gamestate.pop()
	end
end

function SelectNumPlayersClass:draw(dt)
	gui.group.default.size[1] = 150
	gui.group.default.size[2] = 180
	gui.group.default.spacing = 50

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

	local font = fonts.sugarlarge
	love.graphics.setFont(font)
	local str = "Select Number of Prisoners"
	local width = font:getWidth (str)
	local height = font:getHeight (str)
	love.graphics.print ("Select Number of Prisoners", love.graphics.getWidth() * 0.5 - width * 0.5, love.graphics.getHeight() * 0.3)
	gui.core.draw()
end

function SelectNumPlayersClass:keypressed(key, code)
	gui.keyboard.pressed(key)
	if key=="f12" then
		Gamestate.switch(states.game)
	end
end

-- LÖVE 0.9
function SelectNumPlayersClass:textinput(str)
	gui.keyboard.textinput(str)
end

return SelectNumPlayersClass

