--[[
Fire: flint_and_steel places fire:permanent_flame instead of fire:basic_flame
]]

minetest.override_item("fire:flint_and_steel", {
	on_use = function(itemstack, user, pointed_thing)
		local player_name = user:get_player_name()
		local pt = pointed_thing

		if pt.type == "node" and minetest.get_node(pt.above).name == "air" then
			itemstack:add_wear(1000)
			local node_under = minetest.get_node(pt.under).name

			if minetest.get_item_group(node_under, "flammable") >= 1 then
				if not minetest.is_protected(pt.above, player_name) then
					minetest.set_node(pt.above, {name = "fire:permanent_flame"})
				else
					minetest.chat_send_player(player_name, "This area is protected")
				end
			end
		end

		if not minetest.setting_getbool("creative_mode") then
			return itemstack
		end
	end
})

--[[
Mapgen: add all mt_game tress to the mapgen
]]

local old_register_mgv6_decorations = default.register_mgv6_decorations
function default.register_mgv6_decorations()
	old_register_mgv6_decorations()
	
	-- Aspen tree: everywhere
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = "default:dirt_with_grass",
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.003,	-- Tree Density
			spread = {x=100, y=100, z=100},
			seed = 25694,
			octaves = 3,
			persist = 0.5
		},
		y_min = 1,
		y_max = 31000,
		schematic = minetest.get_modpath("default").."/schematics/aspen_tree_from_sapling.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Acacia tree: lower heights
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = "default:dirt_with_grass",
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.002,
			spread = {x=100, y=100, z=100},
			seed = 61089,
			octaves = 3,
			persist = 0.5
		},
		y_min = 1,
		y_max = 12,
		schematic = minetest.get_modpath("default").."/schematics/acacia_tree_from_sapling.mts",
		flags = "place_center_x, place_center_z",
	})

	-- Pine tree: higher heights
	minetest.register_decoration({
		deco_type = "schematic",
		place_on = "default:dirt_with_grass",
		sidelen = 16,
		noise_params = {
			offset = 0,
			scale = 0.002,
			spread = {x=100, y=100, z=100},
			seed = 24073,
			octaves = 3,
			persist = 0.5
		},
		y_min = 12,
		y_max = 31000,
		schematic = minetest.get_modpath("default").."/schematics/pine_tree_from_sapling.mts",
		flags = "place_center_x, place_center_z",
	})
end
