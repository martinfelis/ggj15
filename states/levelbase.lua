local LevelBaseClass = {}
loadWalls = require ("utils.svgloader")

function LevelBaseClass:new ()
  local newInstance = {}
  self.__index = self
  return setmetatable(newInstance, self)
end

function LevelBaseClass:enter ()
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 0, true) -- no gravity
	self.walls = loadWalls ("level.svg")

end

function LevelBaseClass:draw ()
	for i,p in ipairs (self.walls) do
		love.graphics.polygon ("fill", p)
	end

end

function LevelBaseClass:update (dt)
	self.world:update(dt)

end

function LevelBaseClass:keypressed (key)
	print (key .. ' pressed')
end

return LevelBaseClass