local LevelBaseClass = {}
loadShapes = require ("utils.svgloader")

function LevelBaseClass:new ()
  local newInstance = {}
  self.__index = self
	self.canvas = love.graphics.newCanvas()
	self.canvas:setFilter ("nearest", "nearest")
	self.camera = Camera (0,0)
  return setmetatable(newInstance, self)
end

function LevelBaseClass:enter ()
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 0, true) -- no gravity
	self.walls = loadShapes ("leveldefinitions/level.svg", "Walls")
	self.boxes = loadShapes ("leveldefinitions/level.svg", "Boxes")

	-- add walls to the world
	for i,w in ipairs (self.walls.all) do
		-- print ("adding wall", #w)
		w.body = love.physics.newBody (self.world, 0, 0, "static")
		if w.type == "polygon" then
			w.shape = love.physics.newPolygonShape (unpack(w.points))
		elseif w.type == "circle" then
			w.shape = love.physics.newCircleShape( w.x, w.y, w.r )
		end
		if w.shape then
			w.fixture = love.physics.newFixture (w.body, w.shape)
		end
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

function LevelBaseClass:preDraw()
	love.graphics.setCanvas (self.canvas)
	self.canvas:clear()
end

function LevelBaseClass:postDraw()
	love.graphics.setCanvas ()

	--
	love.graphics.setShader (sketch_shader)
	sketch_shader:send("noise_texture", noise_texture)
	sketch_shader:send("noise_amp", 0.004)
	sketch_shader:send("screen_center_x", self.camera.x / love.window.getWidth())
	sketch_shader:send("screen_center_y", self.camera.y / love.window.getHeight())
	love.graphics.draw (self.canvas, 0, 0, 0)

	sketch_shader:send("noise_texture", noise_texture)
	sketch_shader:send("noise_amp", 0.005)
	love.graphics.draw (self.canvas, 0, 0, 0)

	-- further draws with shifted noise
	sketch_shader:send("noise_texture", noise_texture)
	sketch_shader:send("noise_amp", 0.006)
	sketch_shader:send("screen_center_x", 0.1 + (self.camera.x / love.window.getWidth()))
	sketch_shader:send("screen_center_y", 0.13 + (self.camera.y / love.window.getHeight()))
	love.graphics.draw (self.canvas, 0, 0, 0)

	sketch_shader:send("noise_texture", noise_texture)
	sketch_shader:send("noise_amp", 0.006)
	love.graphics.draw (self.canvas, 0, 0, 0)

	-- default drawing of the filtered canvas
	love.graphics.setShader ()
	love.graphics.draw (self.canvas, 0, 0, 0)
end

function LevelBaseClass:draw ()
	for i,p in ipairs (self.walls.polygons) do
		love.graphics.polygon ("line", unpack(p.points))
	end
	for i,c in ipairs (self.walls.circles) do
		love.graphics.circle( "line", c.x, c.y, c.r, 50 )
	end
	for i,p in ipairs (self.boxes) do
--		love.graphics.polygon ("fill", p)
		love.graphics.polygon ("line", p.body:getWorldPoints(p.shape:getPoints()))
	end
end

function LevelBaseClass:update (dt)
	self.world:update(dt)
end

function LevelBaseClass:keypressed (key)
	print (key .. ' pressed')
end

return LevelBaseClass
