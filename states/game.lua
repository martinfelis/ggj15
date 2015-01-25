local GameStateClass = {}
loadShapes = require ("utils.svgloader")
local newPlayer = require ("entities.player")
local newChain = require("entities.chain")
local newSpotlight = require("entities.spotlight")
local newGuard = require("entities.guard")
local newOpenDoor = require("entities.opendoor")
local newPolygonWall = require("entities.wall")
local newSwitch = require("entities.switch")
local debugWorldDraw = require("debugWorldDraw")
local newSecurityCam = require("entities.securitycam")

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
	print ("Loading level", filename)
	self.camera = Camera (0,0)

	love.physics.setMeter(64)
	self.totalTime = 0

	self.world = love.physics.newWorld(0, 0, true) -- no gravity

	self.alerts = {}
	self.alertcount = 0
	self.busted = false
	self.win = false
	self.currentlevel = filename
	self.levelindex = 1
	for i,v in ipairs (levels) do
		if v == filename then
			self.levelindex = i
		end
	end

	self.SVGdoors = loadShapes ( filename, "Doors")
	self.SVGguards = loadShapes ( filename, "Guards")
	self.SVGplayers = loadShapes (filename, "Players")
	self.SVGpaths = loadShapes (filename, "Paths")
	self.SVGswitches = loadShapes (filename, "Switches")
	self.SVGtargets = loadShapes (filename, "Target")
	self.SVGground = loadShapes (filename, "Ground")
	self.SVGwalls = loadShapes (filename, "Walls")
	self.SVGboxes = loadShapes (filename, "Boxes")
	self.SVGspotlights = loadShapes (filename, "Spotlights")
	self.SVGsecuritycams = loadShapes (filename, "Securitycams")

	self.chains = {}
	self.doors = {}
	self.guards = {}
	self.players = {}
	self.securitycameras = {}
	self.switches = {}
	self.target = {center_x = 0, center_y = 0, radius = 0}
	self.grounds = {} -- list of {points={...}, color=...}
	self.walls = {}
	self.boxes = {} -- gets svg table
	self.spotlights = {}

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
		local switch = newSwitch(svgswitch.x, svgswitch.y, svgswitch.r)
		switch.id = svgswitch.id
		table.insert(self.switches, switch)
	end

	-- DOORS: id: doorX_left:true_openby:sw1_openby2:sw2_openby3:sw4
	for _, svgdoor in pairs(self.SVGdoors.polygons) do
		local rl = (svgdoor.config.left=="true") or false
		local door = newOpenDoor(self.world, svgdoor.x, svgdoor.y,
								svgdoor.width, svgdoor.height, rl,
								svgdoor.color)
		if svgdoor.config.openby then
			for _, switch in pairs(self.switches) do
				if switch.id == svgdoor.config.openby then
					door:canBeOpenedBy (switch)
				end
			end
		end
		if svgdoor.config.openby1 then
			for _, switch in pairs(self.switches) do
				if switch.id == svgdoor.config.openby1 then
					door:canBeOpenedBy (switch)
				end
			end
		end		if svgdoor.config.openby2 then
			for _, switch in pairs(self.switches) do
				if switch.id == svgdoor.config.openby2 then
					door:canBeOpenedBy (switch)
				end
			end
		end
		if svgdoor.config.openby3 then
			for _, switch in pairs(self.switches) do
				if switch.id == svgdoor.config.openby3 then
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



	-- WALLS: add walls to the world
	for _, svgwall in ipairs (self.SVGwalls.all) do
		-- print ("adding wall", #w)
		if svgwall.type == "polygon" then --and svgwall.id == "rect5386" then
			local wall = newPolygonWall(self.world, svgwall.points, svgwall.color)
			wall.svgwall = svgwall
			table.insert(self.walls, wall)
		elseif svgwall.type == "circle" then
			print("Circle walls currently not supported. extend wall.lua")
		end

	end

	-- BOXES: add boxes to the world
	for i,svgbox in ipairs (self.SVGboxes.polygons) do
		svgbox.body = love.physics.newBody (self.world,0* svgbox.width/2,0* svgbox.height/2, "dynamic")
		svgbox.shape = love.physics.newPolygonShape (unpack(svgbox.points))
		svgbox.fixture = love.physics.newFixture (svgbox.body, svgbox.shape)
		svgbox.body:setMass(0.5)
		svgbox.body:setLinearDamping(100)
		svgbox.body:setAngularDamping(55)
		svgbox.draw = function(self)
			love.graphics.setColor(self.color)
			love.graphics.polygon ("fill", self.body:getWorldPoints(self.shape:getPoints()))
		end
		table.insert(self.boxes, svgbox)
	end

	-- SPOTLIGHTS
	for _, svgspotlight in pairs(self.SVGspotlights.circles) do

		local spotlight = newSpotlight(svgspotlight.x, svgspotlight.y, svgspotlight.r)
		spotlight.svgspotlight = svgspotlight

		-- search path for spotlight
		for i, svgpath in ipairs(self.SVGpaths.polygons) do
			if svgpath.id == svgspotlight.config.path then
				spotlight.pathpoints = svgpath.points
				spotlight.speed = svgspotlight.config.speed or 200
			end
		end

		table.insert(self.spotlights, spotlight)
	end


	-- SECURITY CAMS
	for _, svgseccam in pairs(self.SVGsecuritycams.circles) do
		local seccam = newSecurityCam(svgseccam.x, svgseccam.y, svgseccam.r)
		seccam.svgseccam = svgseccam
		table.insert(self.securitycameras, seccam)
	end

	--	self:loadTestObjects()
	self.camera:zoom(0.6)


	Signals.clear_pattern (".*")

	Signals.register ('alert-start', function (source, player)
		print (string.format ("A %s (%s) spotted player %s", source.detectortype, tostring(source), tostring (player)))
		if not self.alerts[player] then
			self.alerts[player] = {}
		end

		self.alerts[player][source] = love.timer.getTime() - GVAR.alert_realize_time * source.alertness
		self.alertcount = self.alertcount + 1
	end)

	Signals.register ('alert-stop', function (source, player)
		print (string.format ("A %s (%s) lost player %s", source.detectortype, tostring(source), tostring (player)))
		self.alerts[player][source] = nil
		self.alertcount = self.alertcount - 1
	end)

	Signals.register ('busted', function (source, player)
		if not self.busted then
			print (string.format ("Player %s got busted by a %s (%s)", tostring(player), source.detectortype, tostring(source)))
			self.busted = true
			Timer.tween (1, self.camera, {x = source.x, y = source.y, scale = 1.})
			Gamestate.push(states.busted)
		end
	end)

	Signals.register ('busted-retry', function ()
		print ("Retrying level " .. self.currentlevel)
	end)

	Signals.register ('win', function ()
		if not self.win then
			Gamestate.push(states.win)
			self.win = true
		end
	end)
end

function GameStateClass:resume ()
	if self.busted then
		print ("Renturned from busted screen...")
		self:loadLevel (self.currentlevel)
	elseif self.win then
		self.levelindex = self.levelindex + 1
		print ("next level: ", self.levelindex)
		if self.levelindex <= #levels then
			self:loadLevel (levels[self.levelindex])
		else
			Gamestate.switch(states.credits)
		end
	end
	if self.pause then
		print ("RESUME")
		self.pause = false
	end
end

function GameStateClass:enter ()
	self.camera = Camera (0,0)

	self:loadLevel ("level_out.svg")
	self:initTextures()

	self.totalTime = 0
end

function GameStateClass:loadTestObjects()
	table.insert(self.securitycameras, newSecurityCam(1400, 2520))
	table.insert(self.spotlights, newSpotlight(1000,1220))
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

local function draw_items (items)
	for i,v in ipairs (items) do
		v:draw()
	end
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

	love.graphics.setLineWidth (8.)
	draw_items(self.walls)
	draw_items(self.boxes)
	draw_items(self.players)
	draw_items(self.guards)

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
	love.graphics.setColor (20, 20, 120, 255)
	love.graphics.draw(self.ground_texture, self.background_quad, 0, 0)

	self.camera:attach()
	self:drawGround()

	love.graphics.setColor (100, 100, 255, 255)
	draw_items (self.walls)
	draw_items (self.players)
	draw_items (self.boxes)
	draw_items (self.securitycameras)
	draw_items (self.spotlights)
	draw_items (self.guards)
	draw_items (self.switches)
	draw_items (self.chains)
	draw_items (self.doors)
	love.graphics.setColor (255, 255, 255, 255)

	self.camera:detach()

	self:postDraw()
end

function GameStateClass:checkAlerts ()
	for pi,player in pairs(self.alerts) do
		for source,spot_time in pairs(player) do
			if love.timer.getTime() - spot_time > GVAR.alert_realize_time then
				Signals.emit ('busted', source, player)
			end
		end
	end

	if self.busted then
		self.alerts = {}
	end
end

function GameStateClass:update (dt)
	self.world:update(dt)
	self.totalTime = self.totalTime + dt

	if self.busted or self.win then
		return
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
	update_items (self.guards, dt, self.players, self.world)
	update_items (self.players, dt)
	update_items (self.securitycameras, dt, self.players, self.world)
	update_items (self.spotlights, dt, self.players, self.totalTime)
	update_items (self.switches, dt, self.players)

	self:checkWin()
	self:checkAlerts()
end

function GameStateClass:keyreleased (key)
	if key=="escape" and not self.pause then
		self.pause = true
		Gamestate.push(states.pause)
	end
--	print (key .. ' pressed')
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
			Signals.emit ('win')
		end
	end
end

return GameStateClass
