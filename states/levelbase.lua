local LevelBaseClass = {}

function LevelBaseClass:new ()
  local newInstance = {}
  self.__index = self
  return setmetatable(newInstance, self)
end

function LevelBaseClass:enter ()
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 0, true) -- no gravity

end

function LevelBaseClass:draw ()
end

function LevelBaseClass:update (dt)
	self.world:update(dt)

end

function LevelBaseClass:keypressed (key)
	print (key .. ' pressed')
end

return LevelBaseClass