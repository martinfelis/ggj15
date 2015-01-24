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

  self.__index = self
  return setmetatable(newInstance, self)
end

function GameStateClass:initTextures ()
	self.canvas = love.graphics.newCanvas()
	self.canvas:setFilter ("nearest", "nearest")

	self.ground_texture= love.image.newImageData(40, 40)
	self.ground_texture:mapPixel(function(x,y)
		local l = love.math.noise (x,y) * 4 + 120
		return l,l,l,l
	end)
	self.ground_texture = love.graphics.newImage(self.ground_texture)
	self.ground_texture:setWrap ("repeat", "repeat")
	self.ground_texture:setFilter("linear", "linear")
	self.ground_texture:setFilter("nearest", "nearest")

--	self.background_quad = love.graphics.newQuad (0, 0, love.window.getWidth(), love.graphics.getHeight(), love.window.getWidth(), love.graphics.getHeight())
	self.background_quad = love.graphics.newQuad (0, 0, love.window.getWidth(), love.graphics.getHeight(), 400, 400)
end

function GameStateClass:loadLevel (filename)
	love.physics.setMeter(64)
	self.totalTime = 0

	self.world = love.physics.newWorld(0, 0, true) -- no gravity

	self.SVGdoors = loadShapes ( filename, "Doors")
	self.SVGguards = loadShapes ( filename, "Guards")
	self.SVGplayers = loadShapes (filename, "Players")
	self.SVGpaths = loadShapes (filename, "Paths")
	self.SVGswitches = loadShapes (filename, "Switches")
	self.SVGtargets = loadShapes (filename, "Target")
	self.SVGground = loadShapes (filename, "Ground")
	self.boxes = loadShapes (filename, "Boxes")
	self.spotlights = loadShapes (filename, "Spotlights")

	self.chains = {}
	self.doors = {}
	self.guards = {}
	self.players = {}
	self.securitycameras = {}
	self.switches = {}
	self.target = {center_x = 0, center_y = 0, radius = 0}
	self.walls = loadShapes (filename, "Walls")
	self.grounds = {} -- list of {points={...}, color=...}

	-- PLAYER and CHAINS
	for _, player in pairs(self.SVGplayers.circles) do
		table.insert(self.players, newPlayer (self.world, #self.players + 1,
											  player.x, player.y))
		if (#self.players ~= 1) then
			table.insert(self.chains, newChain(self.world,
												self.players[#self.players-1],
												self.players[#self.players]))
		end
	end

	-- init of PLAYER and CHAINS
	for k,player in pairs(self.players) do
		player:init()
	end
	for k,chain in pairs(self.chains) do
		chain:init()
	end

	-- GUARDS -- guardid: guardX_path:gpathY_speed:200
	for _, svgguard in pairs(self.SVGguards.circles) do
		local guard = newGuard(svgguard.x, svgguard.y, self.world)
		table.insert(self.guards, guard)

		-- search path for guard
		for i, svgpath in ipairs(self.SVGpaths.polygons) do
			if svgpath.id == svgguard.config.path then
				guard.pathpoints = svgpath.points
				guard.speed = svgguard.config.speed or 200
			end
		end

	end

	-- SWITCHES
	for _, svgswitch in pairs(self.SVGswitches.circles) do
		local switch = newSwitch(svgswitch.x, svgswitch.y)
		switch.id = svgswitch.id
		table.insert(self.switches, switch)
	end

	-- DOORS: id: doorX_left:true
	for _, svgdoor in pairs(self.SVGdoors.polygons) do
		local rl = (svgdoor.config.left=="true") or false
		local door = newOpenDoor(self.world, svgdoor.x + 60, svgdoor.y + 50,
								svgdoor.width, svgdoor.height, true)
		if svgdoor.config.openby then
			for _, switch in pairs(self.switches) do
				if switch.id == svgdoor.config.openby then
					door:canBeOpenedBy (switch)
				end
			end
		end
		table.insert(self.doors, door)
	end

	-- open all doors without switches
	for _, door in pairs(self.doors) do
		door:openIfNoSwitch()
	end

	-- TARGET
	if self.SVGtargets.circles[1] then
		local c = self.SVGtargets.circles[1]
		self.target = {center_x = c.x, center_y = c.y, radius = c.r}
	end

	-- GROUND (colored)
	self.grounds = self.SVGground.polygons

	-- associate spotlights with paths
	for i, s in ipairs(self.spotlights.circles) do
	end
	self.camera:zoom(0.6)




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
	--for i, s in ipairs(self.spotlights.circles) do
	--	for i, sp in ipairs(self.spotlightpaths.polygons) do
	--		-- print (sp.id)
	--		if sp.id == s.config.path then
	--			s.pathpoints = sp.points
	--		end
	--	end
	--end
	-- print (serialize(self.spotlights))
end

function GameStateClass:enter ()
	self.camera = Camera (0,0)

	self:loadLevel ("level1.svg")
	self:initTextures()
--	self:loadLevel ("leveldefinitions/level.svg")

	self.totalTime = 0
end

function GameStateClass:loadTestObjects()
--	table.insert(self.securitycameras, newSecurityCam(680, 420))
	table.insert(self.spotlights, newSpotlight(400,420))
	table.insert(self.guards, newGuard(200,200, self.world))

	local switch = newSwitch(50, 50)
	local door = newOpenDoor(self.world,70,40,20,80, false)
	door:canBeOpenedBy (switch)
	table.insert(self.switches, switch)
	table.insert(self.doors, door)
end

function GameStateClass:preDraw()
	love.graphics.setCanvas (self.canvas)
	self.canvas:clear()
end

function GameStateClass:drawGround()

	local oldr, oldg, oldb, olda = love.graphics.getColor()
	for _, ground in pairs(self.grounds) do
		if ground.config.hide == nil or ground.config.hide ~= "true" then
			love.graphics.setColor(ground.color)
			love.graphics.polygon("fill", unpack(ground.points))
		end
	end
	love.graphics.setColor(oldr, oldg, oldb, olda)
end

function GameStateClass:postDraw()
	love.graphics.setCanvas ()

	--
	love.graphics.setShader (sketch_shader)

	-- further draws with shifted noise
	love.graphics.setCanvas (self.canvas)
	sketch_shader:send("noise_texture", noise_texture)
	sketch_shader:send("noise_amp", 0.004)
	sketch_shader:send("screen_center_x", (self.camera.scale * self.camera.x / love.window.getWidth()))
	sketch_shader:send("screen_center_y", (self.camera.scale * self.camera.y / love.window.getHeight()))
	love.graphics.draw (self.canvas, 0, 0, 0)

	sketch_shader:send("noise_amp", 0.002 )
	sketch_shader:send("screen_center_x", 0.01 * self.camera.scale + (self.camera.scale * self.camera.x / love.window.getWidth()))
	sketch_shader:send("screen_center_y", 0.03 * self.camera.scale + (self.camera.scale * self.camera.y / love.window.getHeight()))
	love.graphics.draw (self.canvas, 0, 0, 0)

	-- default drawing of the filtered canvas
	love.graphics.setShader ()
	love.graphics.setCanvas ()
	love.graphics.draw (self.canvas, 0, 0, 0)

	self.camera:attach()
	love.graphics.setColor (255, 255, 255 ,255)
	for i,p in ipairs (self.walls.polygons) do
		love.graphics.polygon ("line", unpack(p.points))
	end
	for i,p in ipairs (self.players) do
		p:draw()
	end

	self.camera:detach()
end

function GameStateClass:draw ()

	local player_center =  vector(0, 0)
	for k,player in pairs(self.players) do
		player_center = player_center + vector(player.body:getPosition()) * (1/table.getn(self.players))
	end

	self:preDraw()

	self.camera:lookAt (player_center.x, player_center.y)

	self.background_quad:setViewport (self.camera.scale * player_center.x, self.camera.scale * player_center.y, love.window.getWidth(), love.window.getHeight())
	love.graphics.draw(self.ground_texture, self.background_quad, 0, 0)

	self.camera:attach()
	self:drawGround()

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
	draw_items (self.switches)
	draw_items (self.chains)
	draw_items (self.doors)
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

	local function update_items (items, dt, arg1, arg2, arg3)
		for i,v in ipairs (items) do
			if v.update then
				v:update (dt, arg1, arg2, arg3)
			end
		end
	end

	update_items (self.boxes, dt)
	update_items (self.chains, dt)
	update_items (self.guards, dt, self.players, self.world, self.totalTime)
	update_items (self.players, dt)
	update_items (self.securitycameras, dt, self.players, self.world)
	update_items (self.spotlights, dt, self.players)
	update_items (self.switches, dt, self.players)

	self:checkWin()
end

function GameStateClass:keypressed (key)
	print (key .. ' pressed')
end

function GameStateClass:resize(x, y)
	self.camera = Camera (self.camera.x, self.camera.y)
	self.canvas = love.graphics.newCanvas()
	self.canvas:setFilter ("nearest", "nearest")
end

function GameStateClass:checkWin()
	for _, player in pairs(self.players) do
		local dx, dy = player.body:getX() - self.target.center_x, player.body:getY() - self.target.center_y
		local distancetotarget = math.sqrt(dx*dx + dy*dy)
		if distancetotarget < self.target.radius then
			print ("WIN")
		end
	end
end

return GameStateClass
