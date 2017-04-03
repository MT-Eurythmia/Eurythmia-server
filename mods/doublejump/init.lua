local sneaking_players = {}
minetest.register_globalstep(function(dtime)
	local players = minetest.get_connected_players()
	for _, player in ipairs(players) do
		local name = player:get_player_name()
		if player:get_player_control().sneak and not sneaking_players[name] then
			print(player:get_physics_override().jump, name)
			if player:get_physics_override().jump == 1.0 then -- Check if it's the default value. Don't change it otherwise.
				print(player:get_physics_override().jump, name)
				sneaking_players[name] = true
				player:set_physics_override({jump = 1.4})
			end
		elseif not player:get_player_control().sneak and sneaking_players[name] then
			print("not", player:get_physics_override().jump, name)
			sneaking_players[name] = nil
			 -- If some other mod didn't change the value while the player was sneaking
			 -- There's a bug that makes that this value is not exactly 1.4 (it is more close to 1.3999999761581)
			if player:get_physics_override().jump > 1.3 and player:get_physics_override().jump < 1.5 then
				print("not", player:get_physics_override().jump, name)
				player:set_physics_override({jump = 1.0})
			end
		end
	end
end)
