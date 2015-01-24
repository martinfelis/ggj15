
local pathfunctions = {}

function pathfunctions.walk(path, time, speed)
	-- path is path in x1, y1, x2, y2, ...

	local posx, posy = path[1], path[2]

	local lastx, lasty = path[1], path[2]
	local len = 0

	-- EINMALIG: Gesamtpfaglänge berechnen
	if not path.length then
		-- EINMALIG: Pfad schließen
		table.insert(path, posx)
		table.insert(path, posy)
		-- Länge
		for i = 3, #path, 2 do
			local dx, dy = lastx - path[i], lasty - path[i+1]
			len = len + math.sqrt(dx*dx + dy*dy)
			lastx, lasty = path[i], path[i+1]
		end
		path.length = len
		--print ("sf " ..path.length)
	end

	-- remaining = derzeitige position auf pfad vom aktuellen knoten (=pfadbeginn) aus
	local remaining = (time * speed) % path.length


	-- skipped segments
	local running = true
	local i = 3
	lastx, lasty = path[1], path[2]
	-- immer ein segment weiter und länge abziehen, bis das segment gefunden ist,
	-- auf dem wir uns befinden
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

function pathfunctions.transform(path, dx, dy)
	for i = 1, #path, 2 do
		path[i] = path[i] + dx
		path[i+1] = path[i+1] + dy
	end
	return path
end


function pathfunctions.getDimensions(path)
	local minx, miny = 1000000, 1000000
	local maxx, maxy = -1000000, -1000000
	for i = 1, #path, 2 do
		minx = math.min(path[i], minx)
		maxx = math.max(path[i], maxx)
		miny = math.min(path[i+1], miny)
		maxy = math.max(path[i+1], maxy)
	end
	return maxx - minx, maxy - miny
end

return pathfunctions