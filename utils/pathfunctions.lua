
local pathfunctions = {}

function pathfunctions.walk(path, time, speed)
	-- path is path in x1, y1, x2, y2, ...

	local posx, posy = path[1], path[2]

	local lastx, lasty = path[1], path[2]
	local len = 0
	if not path.length then
		table.insert(path, posx) -- close path
		table.insert(path, posy)
		for i = 3, #path, 2 do
			local dx, dy = lastx - path[i], lasty - path[i+1]
			len = len + math.sqrt(dx*dx + dy*dy)
			lastx, lasty = path[i], path[i+1]
		end
		path.length = len
		--print ("sf " ..path.length)
	end

	local remaining = (time * speed) % path.length
	--print(remaining)
	-- skipped segments
	local running = true
	local i = 3
	lastx, lasty = path[1], path[2]
	while running do

		local dx, dy = lastx - path[i], lasty - path[i+1]
		local segmentlength = math.sqrt(dx*dx + dy*dy)
		if segmentlength > remaining then
			-- print(i .. "  " .. remaining .. "  " .. segmentlength)
			running = false
			posx = lastx - dx * (remaining / segmentlength)
			posy = lasty - dy * (remaining / segmentlength)
		end
		remaining = remaining - segmentlength
		lastx, lasty = path[i], path[i+1]

		i = i + 2
		if i > #path then
			running = false
		end
	end


	return posx, posy
end



return pathfunctions