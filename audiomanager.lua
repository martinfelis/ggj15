
local AudioManager = {}


--[[
	For backgroundmusic etc.
	Unterbrechungsfreies spielen beim statewechsel
]]--

function AudioManager:new ()
	local newInstance = {
	}

	newInstance.audios = {}

	self.__index = self
	return setmetatable(newInstance, self)
end


function AudioManager:loadAudio(config) -- {key (opt), filename, volume, loop}
	if not config then
		return
	end
	local key = config["key"] and config.key or config.filename
	if self.audios[key] == nil then
		self.audios[key] = {}
		self.audios[key].source = love.audio.newSource(config.filename)
	end
	self.audios[key].volume = config["volume"] and config.volume or 100
	self.audios[key].loop = config["loop"] and config.loop or false
end

function AudioManager:configureCurrentMusic(musictoplay_astable)
	self.current = musictoplay_astable

	-- stop all audio if its not playing now
	for key, audio in pairs(self.audios) do
		if musictoplay_astable[key] == nil and audio.source:isPlaying() then
			audio.source:stop()
			audio.source:rewind()
		end
	end

	-- start audio if not started yet
	for _, key in pairs(musictoplay_astable) do
		if not self.audios[key].source:isPlaying() then
			self.audios[key].source:setVolume(self.audios[key].volume)
			self.audios[key].source:setLooping(self.audios[key].loop)
			self.audios[key].source:play()
		end
	end
end

function AudioManager:push(key)
	self.current[#self.current] = key
	self.configureCurrentMusic(self.current)
end


return AudioManager