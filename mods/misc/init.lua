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

--[[
Admin chatcommand: players IPs
]]

minetest.register_chatcommand("ip", {
	description = "Get player IP",
	params = "<player>",
	privs = { kick=true },
	func = function(name, params)
		local player = params:match("%S+")
		if not player then
			return false, "Invalid usage"
		end
		
		if not ipnames.data[player] then
			minetest.chat_send_player(name, "The player '"..player.."' did not join yet.")
			return
		end
		
		local ip = ipnames.data[player][1]
		
		return true, ip
	end,
})

--[[
XDecor chair: avoid "flying" usebug
]]
minetest.override_item("xdecor:chair", {
	on_rightclick = function() end
})
minetest.override_item("xdecor:cushion", {
	on_rightclick = function() end
})

--[[
Fishing baitball: change its craft
]]
minetest.clear_craft({output = "fishing:baitball"})
minetest.register_craft({
	type = "shapeless",
	output = "fishing:baitball 20",
	recipe = {"farming:flour", "farming:wheat", "bucket:bucket_water"},
	replacements = {{ "bucket:bucket_water", "bucket:bucket_empty"}}
})

--[[
Natural hive: don't allow inventory put if the area is protected (don't do this for artificial hives)
]]
minetest.override_item("mobs:beehive", {
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		print(minetest.is_protected(pos, player:get_player_name()))
		if minetest.is_protected(pos, player:get_player_name()) and listname == "beehive" then
			return 0
		end
		return stack:get_count()
	end
})

--[[
Lava bucket: place only in areas protected by the placing player (not at unprotected areas)
]]
local old_bucket_lava_on_place = minetest.registered_items["bucket:bucket_lava"].on_place
minetest.override_item("bucket:bucket_lava", {
	on_place = function(itemstack, user, pointed_thing)
		if next(areas:getAreasAtPos(pointed_thing.under)) == nil then
			local name = user:get_player_name()
			minetest.log("action", (name ~= "" and name or "A mod") .. " tried to place a lava bucket at an unprotected position")
			return
		end
		old_bucket_lava_on_place(itemstack, user, pointed_thing)
	end
})

--[[
Moderator command: /error, useful to reboot the server
]]
minetest.register_chatcommand("error", {
	description = "Raise an error to make the server to crash with an error exit status, and the run.sh script to reboot it",
	params = "",
	privs = { ban=true },
	func = function(name, params)
		error("/error chatcommand")
		return true
	end,
})

--[[
Unbreakable nodes: add unbreakable obsidian glass and unbreakable stonebrick slab to maptools
]]

minetest.register_node(":maptools:obsidian_glass", {
	description = "Unbreakable Obsidian Glass",
	drawtype = "glasslike_framed_optional",
	tiles = {"default_obsidian_glass.png", "default_obsidian_glass_detail.png"},
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	range = 12,
	stack_max = 10000,
	drop = "",
	groups = {unbreakable = 1, not_in_creative_inventory = maptools.creative},
})
minetest.register_node(":maptools:slab_stonebrick", {
	description = "Unbreakable Stone Brick Slab",
	drawtype = "nodebox",
	tiles = {"default_stone_brick.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {unbreakable = 1, not_in_creative_inventory = maptools.creative},
	sounds = default.node_sound_stone_defaults(),
	range = 12,
	stack_max = 10000,
	drop = "",
	node_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0, 0.5},
	},
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return itemstack
		end

		-- If it's being placed on an another similar one, replace it with
		-- a full block
		local slabpos = nil
		local slabnode = nil
		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local n0 = minetest.get_node(p0)
		local n1 = minetest.get_node(p1)
		local param2 = 0
			local n0_is_upside_down = (n0.name == "stairs:slab_stonebrick" and
				n0.param2 >= 20)
			if n0.name == "stairs:slab_stonebrick" and not n0_is_upside_down and
				p0.y + 1 == p1.y then
			slabpos = p0
			slabnode = n0
		elseif n1.name == "stairs:slab_stonebrick" then
			slabpos = p1
			slabnode = n1
		end
		if slabpos then
			-- Remove the slab at slabpos
			minetest.remove_node(slabpos)
			-- Make a fake stack of a single item and try to place it
			local fakestack = ItemStack(recipeitem)
			fakestack:set_count(itemstack:get_count())
				pointed_thing.above = slabpos
			local success
			fakestack, success = minetest.item_place(fakestack, placer,
				pointed_thing)
			-- If the item was taken from the fake stack, decrement original
			if success then
				itemstack:set_count(fakestack:get_count())
			-- Else put old node back
			else
				minetest.set_node(slabpos, slabnode)
			end
			return itemstack
		end
		
		-- Upside down slabs
		if p0.y - 1 == p1.y then
			-- Turn into full block if pointing at a existing slab
			if n0_is_upside_down  then
				-- Remove the slab at the position of the slab
				minetest.remove_node(p0)
				-- Make a fake stack of a single item and try to place it
				local fakestack = ItemStack(recipeitem)
				fakestack:set_count(itemstack:get_count())
					pointed_thing.above = p0
				local success
				fakestack, success = minetest.item_place(fakestack, placer,
					pointed_thing)
				-- If the item was taken from the fake stack, decrement original
				if success then
					itemstack:set_count(fakestack:get_count())
				-- Else put old node back
				else
					minetest.set_node(p0, n0)
				end
				return itemstack
			end
				-- Place upside down slab
			param2 = 20
		end
		-- If pointing at the side of a upside down slab
		if n0_is_upside_down and p0.y + 1 ~= p1.y then
			param2 = 20
		end
		return minetest.item_place(itemstack, placer, pointed_thing, param2)
	end,
})
