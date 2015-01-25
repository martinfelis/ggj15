local parseXml = require "utils.parsexml"
local serialize = require "utils.serialize"


-- howto add config:
-- set id to something like:
--    switch123_door:door123_delay:13
-- this will make
-- shapes.polygons[i].config = {door = door123,
--								delay = 13 }
--       .rects[i]   .
--       .circles[i] .
-- There is also the color attribute

local function loadShapes (filename, layername)
	local shapes = {}

	local function parse_style(stylestring)
		local start, end_, key, value = 0, 0
		local args = {}

		for key, value in string.gmatch(stylestring, "([%w-_]+)[:]([%w%d_-\\#\\.]+)") do
			args[key] = value
		end
		return args
	end

	local function parse_id(idstring)
		local start, end_, key, value = 0, 0
		local args = {}

		for key, value in string.gmatch(idstring, "[_]([%w]+)[:]([%w%d]+)") do
			args[key] = tonumber(value) or value

		end
		return args
	end


	local function split(str, delim)
	   local res = { }
	   local pattern = string.format("([^%s]+)%s()", delim, delim)
	   local line, pos = "", 0
	   while (true) do
	      line, pos = str:match(pattern, pos)
	      if line == nil then break end
	      table.insert(res, line)
	   end
	   return res
	end

	local function search_and_parse_description(node, args)
		for n, subnode in pairs(node) do
			if tonumber(n) and subnode.label=="desc" then
				if subnode[1] then
					-- print ("Node" .. node.xarg.id .. " has desc conf")
					local desc = subnode[1] .. "\n"
					if desc:find("_") then
						print("NO _ in description config in svg")
						assert(false)
					end

					local lines = split(desc, "\n")
					-- print(serialize(lines))
					for _, line in pairs(lines) do
						for key, value in string.gmatch(line, "([%w]+)[:]([%w%d]+)") do
							args[key] = tonumber(value) or value
						end
					end


				end
			end
		end


		return args
	end


	local function parse_transform(transformstring, x, y, w, h)
		-- transform = "matrix(0.86912819,0.49458688,-0.49458688,0.86912819,0,0)"
		-- returns the angle
		if not (transformstring:sub(1, 10) == "translate("
				or transformstring:sub(1, 7) == "matrix(") or transformstring:find(" ") then
			print ("UNSUPPORTED TRANSFORMATION: " .. transformstring)
			return 0, {x, y, x+w, y, x+w, y+h, x, y+h}, 0, 0
		end

		if transformstring:sub(1, 10) == "translate(" then
			-- translate(59.9105,52.272683)
			transformstring = transformstring:sub(11, #transformstring - 1)
			local nums = {}
			for n in string.gmatch(transformstring, "([%d-.]+)") do
				table.insert(nums, tonumber(n))
			end
			 return 0, { nums[1] + x, nums[2] + y,
						 nums[1] + x+w, nums[2] + y,
						 nums[1] + x+w, nums[2] + y+h,
						 nums[1] + x, nums[2] + y+h }, nums[1], nums[2]
		end

		-- else MATRIX:

		transformstring = transformstring:sub(8, #transformstring - 1)
		assert (nil == transformstring:find(" ")) -- no spaces aka no other fancy stuff like rotate

		local nums = {}
		for n in string.gmatch(transformstring, "([%d-.]+)") do
			table.insert(nums, tonumber(n))
		end

		-- Rotate
		--
		-- cos(a)   -sin(a)  0
		-- sin(a)    cos(a)  0
		--      0        0   1
		--
		-- Reihenfolge
		-- a1  c3  e5
		-- b2  d4  f6
		-- 0   0   1

		-- assert (nums[5] == 0 and nums[6] == 0) -- assert is only rotation

		local angle = math.asin(nums[2])

		local transformmatrix = matrix:new(3, 3, 0)
		transformmatrix[1] = {nums[1], nums[3], nums[5]}
		transformmatrix[2] = {nums[2], nums[4], nums[6]}
		transformmatrix[3] = {0, 0, 1}

		local resultingpointlist = {}

		local untransformedpoints = {
			{{x, y, 1}}, {{x+w, y, 1}}, {{x+w, y+h, 1}}, {{x, y+h, 1}}
		}

		for _, untransformedvertex in pairs(untransformedpoints) do
			--print(serialize(transformmatrix))
			--print(serialize(untransformedvertex))
			local transformed = matrix.mul(transformmatrix, matrix.transpose(untransformedvertex))
			--local transformed2 = matrix.mul(untransformedvertex, transformmatrix)
			--print(serialize(transformed))
			table.insert(resultingpointlist, transformed[1][1])
			table.insert(resultingpointlist, transformed[2][1])
		end

		--print(serialize(nums))
		--print(serialize(resultingpointlist))
		--print (angle)
		return angle, resultingpointlist, nums[5], nums[6] -- die nuller sind die dx, dy bei transform() (nicht matrix())
	end



	local function get_color(styleargs)
		local color = styleargs.fill and styleargs.fill or "#000000"
		--print(serialize(styleargs))
		local r, g, b, a = 0, 0, 0, (tonumber(styleargs["fill-opacity"] or 1))*255
		if #color >= 7 then
			r = tonumber(color:sub(2, 3), 16)
			g = tonumber(color:sub(4, 5), 16)
			b = tonumber(color:sub(6, 7), 16)
			-- a = 255
		end
		if #color == 9 then
			a = tonumber(color:sub(8, 9), 16)
		end

		return color, {r, g, b, a}
	end


	local function get_node_polygon (node)
		local path_args = ""

		for k,v in pairs (node) do
			--			print ("node ", k, v)
			if k == "xarg" then
				path_args = v.d
				--				print (path_args)
			end
		end

		local points = {}
		if path_args ~= "" then
			local got_values = true
			local x = 0.
			local y = 0.
			local prev_x = 0.
			local prev_y = 0.
			local si = 0.
			local sl = 0.
			path_args = string.sub (path_args, 1)
			si, sl, x, y = string.find (path_args, "(-?[%d]+%.?[%d]*),(-?[%d]+%.?[%d]*)%s+")
			table.insert (points, x)
			table.insert (points, y)
			path_args = string.sub (path_args, sl + 1)
			-- print (path_args)
			while (got_values) do
				prev_x = x
				prev_y = y
				si, sl, x, y = string.find (path_args, "(-?[%d]+%.?[%d]*),(-?[%d]+%.?[%d]*)%s+")
				if not sl then
					got_values = false
				else
					x = x + prev_x
					y = y + prev_y
					table.insert (points, tonumber(x))
					table.insert (points, tonumber(y))
					path_args = string.sub (path_args, sl + 1)
				end
			end
		end

		assert (#points > 0)
		local polygon = {points = points}
		polygon.colorhex, polygon.color = get_color(parse_style(node.xarg.style))
		polygon.config = parse_id(node.xarg.id)
		polygon.config = search_and_parse_description(node, polygon.config)
		-- print (serialize(polygon))
		return polygon
	end


	local function get_node_rect(node)
		local rect = node.xarg -- has x, y, height, width
		rect.x, rect.y = tonumber(rect.x), tonumber(rect.y)
		rect.height, rect.width = tonumber(rect.height), tonumber(rect.width)
		rect.colorhex, rect.color = get_color(parse_style(node.xarg.style))
		rect.config = parse_id(node.xarg.id)
		rect.config = search_and_parse_description(node, rect.config)
		rect.angle = 0
		rect.points = {rect.x, rect.y,
					   rect.x+rect.width, rect.y,
					   rect.x+rect.width, rect.y+rect.height,
					   rect.x, rect.y+rect.height}
		if node.xarg.transform then
			rect.angle, rect.points = parse_transform(node.xarg.transform, rect.x, rect.y, rect.width, rect.height)
		end
		-- print (serialize(rect))

		return rect
	end

	local function get_node_circle(node)
		local circle = {}
		circle.colorhex, circle.color = get_color(parse_style(node.xarg.style))
		circle.config = parse_id(node.xarg.id)
		circle.config = search_and_parse_description(node, circle.config)
		circle.x = node.xarg.cx
		circle.y = node.xarg.cy
		circle.rx = node.xarg.rx
		circle.ry = node.xarg.ry


		if node.xarg.transform then
			local angle, points, ty, tx

			angle, points, tx, ty = parse_transform(node.xarg.transform, circle.x, circle.y, circle.rx, circle.ry)

			circle.rx, circle.ry = pathfunctions.getDimensions(points) --
			circle.x, circle.y = points[1], points[2]-- circle.x + tx, circle.y + ty
		end
		circle.r = math.sqrt(node.xarg.rx * node.xarg.rx + node.xarg.ry * node.xarg.ry)


		return circle
	end




	local function find_layer (svg_data, layername)
		local layer_node = nil
		for k,v in pairs(svg_data[2]) do
			--print ("ser ... ", k, serialize(v))
			if v.xarg then
				--print ("v.xarg", v.xarg)

				if v.xarg.label then
					--print (v.xarg.label, v.label, layername)
				end
			end

			if v.label and v.label == "g"
				and v.xarg and type(v.xarg) == "table"
				and v.xarg.label and v.xarg.label == layername then

				if v.xarg.transform then
					print ("UNSUPPORTED global TRANSFORM at Layer " .. layername)
				end

				return v
			end
		end

		print ("did not find bla.... ")
	end

	local function svg2shapes (filename, layername)
		local shapes = {
			polygons = {},
			rects = {},
			circles = {},
			all = {}
		}

		local level_file = io.open (filename)
		local level_xml_string = level_file:read("*a")
		local svg_data = parseXml (level_xml_string)
		-- print (serialize (svg_data))
		assert (#svg_data == 2)

		local layer_data = find_layer (svg_data, layername)

		--print (serialize(layer_data))
		if layer_data then
			for k,v in ipairs (layer_data) do
				if v.label == "path" and not v.xarg.type then
					 local polygon = get_node_polygon (v)
					 polygon.id = v.xarg.id
					 polygon.type = "polygon"
					 table.insert (shapes.polygons, polygon)
					 table.insert (shapes.all, polygon)
				end
				if v.label == "rect" then  -- is converted into polygon
					 local rect = get_node_rect (v)
					 rect.type = "polygon"
					 table.insert (shapes.polygons, rect)
	 				 table.insert (shapes.all, rect)
				end
				if v.label == "path" and v.xarg.type == "arc" then
					 local circle = get_node_circle (v)
					 circle.type = "circle"
					 circle.id = v.xarg.id
					 table.insert (shapes.circles, circle)
					 table.insert (shapes.all, circle)
				end
			end
		end --if
		level_file:close()

		return shapes
	end

	shapes = svg2shapes (filename, layername)

	return shapes
end

return loadShapes
