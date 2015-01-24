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

		for key, value in string.gmatch(stylestring, "([%w-_]+)[:]([%w%d_-\\#]+)") do
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

	local function parse_transform(transformstring, x, y, w, h)
		-- transform = "matrix(0.86912819,0.49458688,-0.49458688,0.86912819,0,0)"
		-- returns the angle
		assert (transformstring:sub(1, 7) == "matrix(")
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
			{{x, y, 0}}, {{x+w, y, 0}}, {{x+w, y+h, 0}}, {{x, y+h, 0}}
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
		return angle, resultingpointlist
	end



	local function get_color(styleargs)
		local color = styleargs.fill and styleargs.fill or "#000000"
		local r, g, b, a = 0, 0, 0, 0

		if #color >= 7 then
			r = tonumber(color:sub(2, 3), 16)
			g = tonumber(color:sub(4, 5), 16)
			b = tonumber(color:sub(6, 7), 16)
			a = 255
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
		-- print (serialize(polygon))
		return polygon
	end


	local function get_node_rect(node)
		local rect = node.xarg -- has x, y, height, width
		rect.colorhex, rect.color = get_color(parse_style(node.xarg.style))
		rect.config = parse_id(node.xarg.id)
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
		circle.x = node.xarg.cx
		circle.y = node.xarg.cy
		circle.rx = node.xarg.rx
		circle.ry = node.xarg.ry


		--[[if node.xarg.transform then
			local angle, points
			angle, points = parse_transform(node.xarg.transform, circle.rx, circle.ry, 1, 1)
			circle.rx, circle.ry = points[1], points[2]
		end]]--
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
				 table.insert (shapes.circles, circle)
				 table.insert (shapes.all, circle)
			end
		end

		level_file:close()

		return shapes
	end

	shapes = svg2shapes (filename, layername)

	return shapes
end

return loadShapes
