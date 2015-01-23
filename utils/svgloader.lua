local parseXml = require "utils.parsexml"
local serialize = require "utils.serialize"

local function loadWalls (filename)
	local level = {
		walls = { }
	}

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
			print (path_args)
			while (got_values) do
				prev_x = x
				prev_y = y
				si, sl, x, y = string.find (path_args, "(-?[%d]+%.?[%d]*),(-?[%d]+%.?[%d]*)%s+")
				if not sl then
					got_values = false
				else
					x = x + prev_x
					y = y + prev_y
					table.insert (polygon, x)
					table.insert (polygon, y)
					path_args = string.sub (path_args, sl + 1)
				end
			end
		end

		assert (#polygon > 0)
		return polygon
	end

	local function svg2polygons (filename)
		local polygons = {}

		local level_file = io.open (filename)
		local level_xml_string = level_file:read("*a")
		local svg_data = parseXml (level_xml_string)
		-- print (serialize (svg_data))
		assert (#svg_data == 2)

		local graphics_node = nil
		for k,v in pairs(svg_data[2]) do
			if v.label and v.label == "g" then
				graphics_node = v
			end
		end

		print (#graphics_node)
		for k,v in ipairs (graphics_node) do
			local polygon = get_node_polygon (v)
			table.insert (polygons, polygon)
		end

		level_file:close()

		return polygons
	end

	level.walls = svg2polygons (filename)

	return level.walls
end

return loadWalls
