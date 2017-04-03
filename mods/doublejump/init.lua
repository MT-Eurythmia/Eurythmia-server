local sneaking_players = {}
minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()
	for _, player in ipairs(players) do
		if player:get_player_control().sneak and not sneaking_players[player] then
			local physics = player:get_physics_override()
			if physics.jump == 1 then -- Check if it's the default value. Don't change it otherwise.
				sneaking_players[player] = true
				physics.jump = 1.4
				player:set_physics_override(physics)
			end
		elseif not player:get_player_control().sneak and sneaking_players[player] then
			sneaking_players[player] = nil
			local physics = player:get_physics_override()
			if physics.jump == 1.4 then -- If some other mod didn't change the value while the player was sneaking
				physics.jump = 1
				player:set_physics_override(physics)
			end
		end
	end
end)
