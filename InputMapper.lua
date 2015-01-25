deepcopy = require ("utils.deepcopy")

function newInputMapper ()
	local mapping = {
		players = {}
	}

	mapping.keyboard_defaults = {
		{
			right = "right",
			left = "left",
			up = "up",
			down = "down",
		},
		{
			up = "w",
			left = "a",
			down = "s",
			right = "d",
		},
		{
			right = "l",
			left = "j",
			down = "k",
			up = "i"
		},
	}

	mapping.joystick_defaults = {
		right = {
			{ axis = 1 },
			{ hat = 1, char = "r" },
		},
		left = {
			{ axis = 1 },
			{ hat = 1, char = "l" },
		},
		up = {
			{ axis = 2 },
			{ hat = 1, char = "u" },
		},
		down = {
			{ axis = 2 },
			{ hat = 1, char = "u" },
		},
	}

	for i,v in pairs(love.joystick.getJoysticks()) do
		local joystick_mapping = deepcopy (mapping.joystick_defaults)
		joystick_mapping.controller_type = "joystick"
		joystick_mapping.joystick = v
		table.insert (mapping.players, joystick_mapping)
	end

	for i,v in pairs(mapping.keyboard_defaults) do
		local keyboard_mapping = deepcopy (v)
		keyboard_mapping.controller_type = "keyboard"
		table.insert (mapping.players, keyboard_mapping)
	end

	function mapping.query (self, player_id, key)
		if self.players[player_id].controller_type == "keyboard" then
			if self.players[player_id][key] then
				return love.keyboard.isDown (self.players[player_id][key]) and 1. or 0. 
			end
		elseif self.players[player_id].controller_type == "joystick" then
		end

		return 0
	end

	return mapping
end

return newInputMapper
