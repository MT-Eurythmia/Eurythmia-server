local WEAR_PER_SECOND_LEVEL1 = 65535 / 10
local GRAVITY_FACTOR_LEVEL1 = 1/3

local WEAR_PER_SECOND_LEVEL2 = 65535 / 20
local GRAVITY_FACTOR_LEVEL2 = 1/4

local players = {}

for level = 1, 2 do
	minetest.register_tool("gravitysuit:gravitysuit_"..level, {
		description = "Gravity Suit Level "..level.." (Click to activate/deactivate)",
		groups = {},
		inventory_image = "gravitysuit_suit"..level..".png",
		on_use = function(itemstack, user, pointed_thing)
			local name = user:get_player_name()
			if not players[name] then
				players[name] = level
				user:set_physics_override({gravity = user:get_physics_override().gravity * (level == 1 and GRAVITY_FACTOR_LEVEL1 or GRAVITY_FACTOR_LEVEL2)})
				minetest.log("action", name .. " activates a gravity suit of level " .. level .. " at " .. minetest.pos_to_string(user:get_pos()))
			else
				if players[name] ~= level then
					-- This doesn't detect if the player tries to activate another gravity suit of the same level, but it doesn't matter ;-)
					minetest.chat_send_player(name, "You're already using another gravity suit.")
					return
				end
				players[name] = nil
				user:set_physics_override({gravity = user:get_physics_override().gravity / (level == 1 and GRAVITY_FACTOR_LEVEL1 or GRAVITY_FACTOR_LEVEL2)})
				minetest.log("action", name .. " deactivates a gravity suit of level " .. level .. " at " .. minetest.pos_to_string(user:get_pos()))
			end
		end
	})
end

minetest.register_craft({
	output = "gravitysuit:gravitysuit_1",
	recipe = {{"default:mese"},
	          {"default:diamond"},
	          {"default:mese"}}
})


minetest.register_craft({
	type = "shapeless",
	output = "gravitysuit:gravitysuit_2",
	recipe = {"gravitysuit:gravitysuit_1", "default:diamondblock"}
})

local dtime_count = 0
minetest.register_globalstep(function(dtime)
	dtime_count = dtime_count + dtime
	if dtime_count < 1 then
		return
	end

	dtime_count = dtime_count - 1

	for name, level in pairs(players) do
		local player = minetest.get_player_by_name(name)
		local wear = level == 1 and WEAR_PER_SECOND_LEVEL1 or WEAR_PER_SECOND_LEVEL2
		local inv = player:get_inventory()
	        local stack
	        local index
	        for i = 1, inv:get_size("main") do
			stack = inv:get_stack("main", i);
			if stack:get_name() == "gravitysuit:gravitysuit_"..level then
	        		index = i;
				break
			end
		end
		if index then
			if 65535 - stack:get_wear() <= wear then
				players[name] = nil
				player:set_physics_override({gravity = player:get_physics_override().gravity / (level == 1 and GRAVITY_FACTOR_LEVEL1 or GRAVITY_FACTOR_LEVEL2)})
				inv:set_stack("main", index, nil)
			else
				stack:add_wear(wear)
				inv:set_stack("main", index, stack);
			end
		else
			players[name] = nil
			player:set_physics_override({gravity = player:get_physics_override().gravity / (level == 1 and GRAVITY_FACTOR_LEVEL1 or GRAVITY_FACTOR_LEVEL2)})
		end
	end
end)

minetest.register_on_leaveplayer(function(player)
	players[player:get_player_name()] = nil
end)
