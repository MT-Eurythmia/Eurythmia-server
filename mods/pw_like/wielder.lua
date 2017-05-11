local function set_formspec(meta)
	-- We use the same formspec as the chest
	meta:set_string("formspec",
		"size[8,9]" ..
		default.gui_bg ..
		default.gui_bg_img ..
		default.gui_slots ..
		"list[current_name;main;0,0.3;8,4;]" ..
		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[current_name;main]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.85))
end

local rules = {{x=0, y=0, z=1},{x=0, y=0, z=-1},{x=1, y=0, z=0},{x=-1, y=0, z=0},
	{x=0, y=1, z=1},{x=0, y=1, z=-1},{x=1, y=1, z=0},{x=-1, y=1, z=0},
	{x=0, y=-1, z=1},{x=0, y=-1, z=-1},{x=1, y=-1, z=0},{x=-1, y=-1, z=0},
	{x=0, y=1, z=0}, {x=0, y=-1, z=0}}


local function register(name, description, action, texture_stateful, ghost_pick)
	local tiles = {on = {}, off = {}}
	for _, state in ipairs({"on", "off"}) do
		for _, face in ipairs({ "top", "bottom", "side2", "side1", "back", "front" }) do
			table.insert(tiles[state], "pipeworks_"..name.."_"..face..(texture_stateful[face] and "_"..state or "")..".png")
		end
	end


	mesecon.register_node("pw_like:"..name, {
		description = description,
		paramtype2 = "facedir",
		on_construct = function(pos)
			local meta = minetest.get_meta(pos)
			set_formspec(meta)
			local inv = meta:get_inventory()
			inv:set_size("main", 8*4)
			if ghost_pick then
				inv:set_size("ghost_pick", 1)
			end
			meta:set_string("infotext", description)
		end,
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", placer:get_player_name() or "")
		end,
	}, {
		tiles = tiles.off,
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, mesecon = 2},
		mesecons = {effector = {
			rules = rules,
			action_on = function(pos, node)
				minetest.swap_node(pos, {name = "pw_like:"..name.."_on", param2 = node.param2})

				local meta = minetest.get_meta(pos)
				local inv = meta:get_inventory()
				local wieldindex, wieldstack
				local wield_inv_name = "main"
				for i, stack in ipairs(inv:get_list("main")) do
					if not stack:is_empty() then
						wieldindex = i
						wieldstack = stack
						break
					end
				end
				if not wieldindex then
					if not ghost_pick then return end
					wield_inv_name = "ghost_pick"
					inv:set_stack(wield_inv_name, 1, ItemStack("default:pick_mese"))
					wieldindex = 1
					wieldstack = inv:get_stack(wield_inv_name, 1)
				end

				local dir = minetest.facedir_to_dir(node.param2)
				local under_pos = vector.subtract(pos, dir)
				local above_pos = vector.subtract(under_pos, dir)
				local pitch
				local yaw
				if dir.z < 0 then
					yaw = 0
					pitch = 0
				elseif dir.z > 0 then
					yaw = math.pi
					pitch = 0
				elseif dir.x < 0 then
					yaw = 3*math.pi/2
					pitch = 0
				elseif dir.x > 0 then
					yaw = math.pi/2
					pitch = 0
				elseif dir.y > 0 then
					yaw = 0
					pitch = -math.pi/2
				else
					yaw = 0
					pitch = math.pi/2
				end
				local pointed_thing = { type="node", under=under_pos, above=above_pos }

				local function delay(x)
					return (function() return x end)
				end
				local virtplayer = {
					get_inventory_formspec = delay(meta:get_string("formspec")),
					get_look_dir = delay(vector.multiply(dir, -1)),
					get_look_pitch = delay(pitch),
					get_look_yaw = delay(yaw),
					get_player_control = delay({ jump=false, right=false, left=false, LMB=false, RMB=false, sneak=false, aux1=false, down=false, up=false }),
					get_player_control_bits = delay(0),
					get_player_name = delay(meta:get_string("owner") or ":pw_like:"..name..""),
					is_player = delay(true),
					is_fake_player = true,
					set_inventory_formspec = delay(),
					getpos = delay(pos),
					get_hp = delay(20),
					get_inventory = delay(inv),
					get_wielded_item = delay(wieldstack),
					get_wield_index = delay(wieldindex),
					get_wield_list = delay(wield_inv_name),
					moveto = delay(),
					punch = delay(),
					remove = delay(),
					right_click = delay(),
					setpos = delay(),
					set_hp = delay(),
					set_properties = delay(),
					set_wielded_item = function(self, item)
						wieldstack = item
						inv:set_stack(wield_inv_name, wieldindex, item)
					end,
					set_animation = delay(),
					set_attach = delay(),
					set_detach = delay(),
					set_bone_position = delay(),
					hud_change = delay(),
					get_breath = delay(11),
					-- TODO "implement" all these
					-- set_armor_groups
					-- get_armor_groups
					-- get_animation
					-- get_attach
					-- get_bone_position
					-- get_properties
					-- get_player_velocity
					-- set_look_pitch
					-- set_look_yaw
					-- set_breath
					-- set_physics_override
					-- get_physics_override
					-- hud_add
					-- hud_remove
					-- hud_get
					-- hud_set_flags
					-- hud_get_flags
					-- hud_set_hotbar_itemcount
					-- hud_get_hotbar_itemcount
					-- hud_set_hotbar_image
					-- hud_get_hotbar_image
					-- hud_set_hotbar_selected_image
					-- hud_get_hotbar_selected_image
					-- hud_replace_builtin
					-- set_sky
					-- get_sky
					-- override_day_night_ratio
					-- get_day_night_ratio
					-- set_local_animation
				}

				action(inv, virtplayer, pointed_thing)
			end,
		}}
	}, {
		tiles = tiles.on,
		groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, mesecon = 2, not_in_creative_inventory = 1},
		mesecons = {effector = {
			rules = rules,
			action_off = function(pos, node)
				minetest.swap_node(pos, {name = "pw_like:"..name.."_off", param2 = node.param2})
			end,
		}}
	})
	if minetest.get_modpath("hopper") then
		hopper:add_container({
			{"top", "pw_like:"..name.."_off", "main"},
			{"bottom", "pw_like:"..name.."_off", "main"},
			{"side", "pw_like:"..name.."_off", "main"},

			{"top", "pw_like:"..name.."_on", "main"},
			{"bottom", "pw_like:"..name.."_on", "main"},
			{"side", "pw_like:"..name.."_on", "main"},
		})
	end
end

register("nodebreaker", "Node Breaker", function(inv, virtplayer, pointed_thing)
	local under_node = minetest.get_node(pointed_thing.under)
	if under_node.name == "air" or under_node.name == "ignore" then
		return
	end

	if not inv:room_for_item("main", ItemStack(under_node.name)) then
		return
	end

	local on_dig = (minetest.registered_nodes[under_node.name] or {on_dig=minetest.node_dig}).on_dig
	local status, err = pcall(on_dig, pointed_thing.under, under_node, virtplayer)
	if not status then
		minetest.log("warning", "[pw_like] Node Breaker: error while digging a node: " .. tostring(err))
	end
end, { top = true, bottom = true, side2 = true, side1 = true, front = true }, true)

minetest.register_craft({
	output = "pw_like:nodebreaker_off",
	recipe = {
		{ "group:wood",    "default:pick_mese", "group:wood"    },
		{ "default:stone", "mesecons:piston",   "default:stone" },
		{ "default:stone", "mesecons:mesecon",  "default:stone" },
	}
})

register("deployer", "Deployer", function(inv, virtplayer, pointed_thing)
	local wieldstack = virtplayer:get_wielded_item()
	local status, ret = pcall((minetest.registered_items[wieldstack:get_name()] or {on_place=minetest.item_place}).on_place, wieldstack, virtplayer, pointed_thing)
	if not status then
		minetest.log("warning", "[pw_like] Deployer: error while placing a node: " .. tostring(ret))
		return
	end
	virtplayer:set_wielded_item(ret or wieldstack)
end, { front = true })

minetest.register_craft({
	output = "pw_like:deployer_off",
	recipe = {
		{ "group:wood",    "default:chest",    "group:wood"    },
		{ "default:stone", "mesecons:piston",  "default:stone" },
		{ "default:stone", "mesecons:mesecon", "default:stone" },
	}
})
