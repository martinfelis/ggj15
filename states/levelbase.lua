local LevelBaseClass = {}
loadPolygons = require ("utils.svgloader")
geometry = require ("utils.geometry")

function LevelBaseClass:new ()
  local newInstance = {}
  self.__index = self
  return setmetatable(newInstance, self)
end

function LevelBaseClass:enter ()
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 0, true) -- no gravity
	self.walls = loadPolygons ("level.svg", "Walls")

	-- add walls to the world
	for i,w in ipairs (self.walls) do
		print ("adding wall", #w)
		local body = love.physics.newBody (self.world, 0, 0, "static")
		local shape = love.physics.newPolygonShape (unpack(w))
		local fixture = love.physics.newFixture (body, shape)
	end
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
