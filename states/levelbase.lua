local LevelBaseClass = {}
loadShapes = require ("utils.svgloader")

function LevelBaseClass:new ()
  local newInstance = {}
  self.__index = self
  return setmetatable(newInstance, self)
end

function LevelBaseClass:enter ()
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 0, true) -- no gravity
	self.walls = loadShapes ("leveldefinitions/level.svg", "Walls")
	self.boxes = loadShapes ("leveldefinitions/level.svg", "Boxes")

	-- add walls to the world
	for i,w in ipairs (self.walls.polygons) do
		-- print ("adding wall", #w)
		w.body = love.physics.newBody (self.world, 0, 0, "static")
		w.shape = love.physics.newPolygonShape (unpack(w))
		w.fixture = love.physics.newFixture (w.body, w.shape)
	end
	for i,w in ipairs (self.walls.rects) do
		print "RECT"
	end
	-- add boxes to the world
	for i,b in ipairs (self.boxes) do
		print ("adding box", #b)
		b.body = love.physics.newBody (self.world, 0, 0, "dynamic")
		b.shape = love.physics.newPolygonShape (unpack(b))
		b.fixture = love.physics.newFixture (b.body, b.shape)
		b.body:setLinearDamping(20)
		b.body:setAngularDamping(150)
	end
end

function LevelBaseClass:draw ()
	for i,p in ipairs (self.walls.polygons) do
		love.graphics.polygon ("fill", unpack(p))
	end

	for i,p in ipairs (self.boxes) do
--		love.graphics.polygon ("fill", p)
		love.graphics.polygon ("fill", p.body:getWorldPoints(p.shape:getPoints()))
	end
end

function LevelBaseClass:update (dt)
	self.world:update(dt)
end

function LevelBaseClass:keypressed (key)
	print (key .. ' pressed')
end

return LevelBaseClass
