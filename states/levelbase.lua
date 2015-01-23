local LevelBaseClass = {}

function LevelBaseClass:new ()
  local newInstance = {}
  self.__index = self
  return setmetatable(newInstance, self)
end

function LevelBaseClass:enter ()

end

function LevelBaseClass:update (dt)

end

function LevelBaseClass:keypressed (key)
	print (key .. ' pressed')
end

return LevelBaseClass