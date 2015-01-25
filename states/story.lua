local gui = require "Quickie"

local Story = {}

local CREDIT_LINE_DISTANCE = 70
local IMAGE_DEFAULT_ZOOM_SPEED = 0.004

local STORY_SCREEN_CONFIG = {
	intro = {
		filename = "images/story/infrontofprison.jpg",
		imageobject = nil,
		backgroundmusic = nil, --{filename = "audio/testbg.mp3"}, -- {filename, loop, volume}
		foregroundmusic = nil,
		text = "San Quentin State Prison, Saturday Night\n",
		color = {30, 30, 30, 255},
		time = 10,
		text_pos = {120, 510},
		text_zoom = 1
	}
}

function Story:new ()
	local newInstance = {}

	newInstance.zoom = 1
	newInstance.zoomspeed = IMAGE_DEFAULT_ZOOM_SPEED
	newInstance.audiosources = {}
	newInstance.sourcesplaying = {}

	self.__index = self
	return setmetatable(newInstance, self)
end

function Story:selectstories(storyids)
	self.stories = storyids
	self:nextstoryscreen()
end

function Story:nextstoryscreen()
	self.current = STORY_SCREEN_CONFIG[table.remove(self.stories, 1)]
	self:loadaudio()
	if not self.current.imageobject then
		self.current.imageobject = love.graphics.newImage(self.current.filename)
	end
end

function Story:loadaudio()
	audio:loadAudio(self.current.foregroundmusic)
	audio:loadAudio(self.current.backgroundmusic)
end

function Story:start()
	local fgm = self.current.foregroundmusic
	local bgm = self.current.backgroundmusic
	audio:configureCurrentMusic({fgm and fgm.filename or nil,
								 bgm and bgm.filename or nil})
	self.zoom = 1
	self.zoombase = math.max(
		love.graphics.getWidth() / self.current.imageobject:getWidth(),
		love.graphics.getHeight() / self.current.imageobject:getHeight()
		)
	self.zoom = self.zoombase;
end

function Story:enter()
	self:start()
end

function Story:update (dt)
	self.zoom = self.zoom + self.zoomspeed * dt
end

function Story:draw(dt)
	love.graphics.draw(self.current.imageobject,
		love.graphics.getWidth()/2, love.graphics.getHeight()/2, 0,
		self.zoom, self.zoom,
		self.current.imageobject:getWidth()/2, -- offset x
		self.current.imageobject:getHeight()/2) -- offset y

	love.graphics.setColor(self.current.color)
	love.graphics.setFont(fonts.sugar)
	love.graphics.print(self.current.text,
			self.current.text_pos[1],
			self.current.text_pos[2],
			0, self.current.text_zoom, self.current.text_zoom)
	love.graphics.setColor({255, 255, 255, 255})
end

function Story:keypressed(key, code)

	if key == "return" or key == " " then
		if #self.stories > 0 then
			self:nextstoryscreen()
		else
			Gamestate.pop()
   			audio:configureCurrentMusic{}
		end
	end
end

-- LÖVE 0.9
function Story:textinput(str)
	gui.keyboard.textinput(str)
end

return Story

