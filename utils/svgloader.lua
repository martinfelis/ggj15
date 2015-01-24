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
			args[key] = value
		end
		return args
	end

	local function get_color(styleargs)
		local color = styleargs.fill and styleargs.fill or "#000000"
		local r, g, b, a

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

		local polygon = {}
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
			table.insert (polygon, x)
			table.insert (polygon, y)
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
					table.insert (polygon, tonumber(x))
					table.insert (polygon, tonumber(y))
					path_args = string.sub (path_args, sl + 1)
				end
			end
		end

		assert (#polygon > 0)
		polygon.colorhex, polygon.color = get_color(parse_style(node.xarg.style))
		polygon.config = parse_id(node.xarg.id)
		-- print (serialize(polygon))
		return polygon
	end


	local function get_node_rect(node)
		local rect = node.xarg -- has x, y, height, width
		rect.colorhex, rect.color = get_color(parse_style(node.xarg.style))
		rect.config = parse_id(node.xarg.id)
		print (serialize(rect))


		return rect
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
			if v.label == "path" then
				 local polygon = get_node_polygon (v)
				 polygon.type = "polygon"
				 table.insert (shapes.polygons, polygon)
				 table.insert (shapes.all, polygon)
			end
			if v.label == "rect" then
				 local rect = get_node_rect (v)
				 rect.type = "rect"
				 table.insert (shapes.rects, rect)
 				 table.insert (shapes.all, rect)
			end

		end

		level_file:close()

		return shapes
	end

	shapes = svg2shapes (filename, layername)

	return shapes
end

return loadShapes
