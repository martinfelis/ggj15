local parseXml = require "utils.parsexml"
local serialize = require "utils.serialize"

local function loadPolygons (filename, layername)
	local polygons = {}

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
					table.insert (polygon, tonumber(x))
					table.insert (polygon, tonumber(y))
					path_args = string.sub (path_args, sl + 1)
				end
			end
		end

		assert (#polygon > 0)
		return polygon
	end

	local function find_layer (svg_data, layername)
		local layer_node = nil
		for k,v in pairs(svg_data[2]) do
			print ("ser ... ", k, serialize(v))
			if v.xarg then
				print ("v.xarg", v.xarg)

				if v.xarg.label then
					print (v.xarg.label, v.label, layername)
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

	local function svg2polygons (filename, layername)
		local polygons = {}

		local level_file = io.open (filename)
		local level_xml_string = level_file:read("*a")
		local svg_data = parseXml (level_xml_string)
		print (serialize (svg_data))
		assert (#svg_data == 2)

		local layer_data = find_layer (svg_data, layername)

		print (#layer_data)
		for k,v in ipairs (layer_data) do
			local polygon = get_node_polygon (v)
			table.insert (polygons, polygon)
		end

		level_file:close()

		return polygons
	end

	polygons = svg2polygons (filename, layername)

	return polygons
end

return loadPolygons
