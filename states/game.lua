local GameStateClass = {}
loadShapes = require ("utils.svgloader")
local newPlayer = require ("entities.player")
local newChain = require("entities.chain")
local newSpotlight = require("entities.spotlight")
local newGuard = require("entities.guard")
local newOpenDoor = require("entities.opendoor")
local newSwitch = require("entities.switch")
local debugWorldDraw = require("debugWorldDraw")
local newSecurityCam = require("entities.securitycam")

NUM_PLAYERS = 1

function GameStateClass:new ()
  local newInstance = {}
	newInstance.canvas = love.graphics.newCanvas()
	newInstance.canvas:setFilter ("nearest", "nearest")
	newInstance.camera = Camera (0,0)
	newInstance.totalTime = 0
  self.__index = self
  return setmetatable(newInstance, self)
end

function GameStateClass:loadLevel (filename) 
	love.physics.setMeter(64)
	self.totalTime = 0

	self.world = love.physics.newWorld(0, 0, true) -- no gravity

	self.boxes = loadShapes (filename, "Boxes")
	self.chains = {}
	self.doors = {}
	self.guards = {}
	self.players = {}
	self.securitycameras = {}
	self.spotlightpaths = loadShapes (filename, "SpotlightPaths")
	self.spotlights = loadShapes (filename, "Spotlights")
	self.switches = {}
	self.walls = loadShapes (filename, "Walls")

	-- Players and chains
	for i=1,NUM_PLAYERS,1 do
		table.insert(self.players, newPlayer (self.world, i, 0,50*i))
		if (i ~= 1) then
			table.insert(self.objects, newChain(self.world, self.players[i-1], self.players[i]))
		end
	end

	for k,player in pairs(self.players) do
		player:init()
	end
	for k,chain in pairs(self.chains) do
		chain:init()
	end

	self:loadTestObjects()

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
	-- associate spotlights with paths
	for i, s in ipairs(self.spotlights.circles) do
		for i, sp in ipairs(self.spotlightpaths.polygons) do
			-- print (sp.id)
			if sp.id == s.config.path then
				s.pathpoints = sp.points
			end
		end
	end
	-- print (serialize(self.spotlights))
end

function GameStateClass:enter ()
	self:loadLevel ("leveldefinitions/level.svg")
end

function GameStateClass:loadTestObjects()
	table.insert(self.securitycameras, newSecurityCam(680, 420))
	table.insert(self.spotlights, newSpotlight(400,420))
	table.insert(self.guards, newGuard(200,200))

	local switch = newSwitch(50, 50)
	local door = newOpenDoor(self.world,70,39,80,20, false)
	door.canBeOpenedBy (switch)
	table.insert(self.switches, switch)
	table.insert(self.doors, door)
end

function GameStateClass:preDraw()
	love.graphics.setCanvas (self.canvas)
	self.canvas:clear()
end

function GameStateClass:postDraw()
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

function GameStateClass:draw ()
	local player_center =  vector(0, 0)
	for k,player in pairs(self.players) do
		player_center = player_center + vector(player.body:getPosition()) * (1/table.getn(self.players))
	end
	self.camera:lookAt (player_center.x, player_center.y)

	self:preDraw()
	self.camera:attach()

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
	local oldr, oldg, oldb, olda = love.graphics.getColor()
	love.graphics.setColor({210,200, 13, 180})
	for i, c in ipairs (self.spotlights.circles) do
		love.graphics.circle( "fill", c.x, c.y, c.r, 50 )
	end
	love.graphics.setColor(oldr, oldg, oldb, olda)


	local function draw_items (items)
		for i,v in ipairs (items) do
			v:draw()
		end
	end

	draw_items (self.players)
	draw_items (self.securitycameras)
	draw_items (self.spotlights)
	draw_items (self.guards)
	love.graphics.setColor (255, 255, 255, 255)

--	for k,object in pairs(self.objects) do
--		object:draw()
--	end

	self.camera:detach()

	self:postDraw()
end

function GameStateClass:update (dt)
	self.world:update(dt)
	self.totalTime = self.totalTime + dt

	for i, c in ipairs (self.spotlights.circles) do
		c.x, c.y = pathfunctions.walk(c.pathpoints, self.totalTime, c.config.speed)
	end

	local function update_items (items, dt, arg1, arg2)
		for i,v in ipairs (items) do
			v:update (dt, arg1, arg2)
		end
	end

	update_items (self.boxes, dt)
	update_items (self.chains, dt)
	update_items (self.guards, dt, self.players)
	update_items (self.players, dt)
	update_items (self.securitycameras, dt, self.players, self.world)
	update_items (self.spotlights, dt, self.players)
	update_items (self.switches, dt, self.players)
end

function GameStateClass:keypressed (key)
	print (key .. ' pressed')
end

return GameStateClass
