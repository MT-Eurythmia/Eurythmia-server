minetest.register_chatcommand("spawn", {
	description = "Teleport a player to the defined spawnpoint",
	func = function(name)
		local player = minetest.get_player_by_name(name)

		if minetest.setting_get_pos("static_spawnpoint") then
			minetest.chat_send_player(player:get_player_name(), "Teleporting to spawn...")
			player:setpos(minetest.setting_get_pos("static_spawnpoint"))
			minetest.log("action","Player ".. name .." respawned.")
			return true
		else
			minetest.chat_send_player(player:get_player_name(), "ERROR: No spawn point is set on this server!")
			return false
		end
	end
})
