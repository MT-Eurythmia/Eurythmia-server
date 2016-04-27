-- Needed variables
local pvptable = {}

local function pvp_toggle(player)
	localname = player:get_player_name()
	if pvptable[localname] == 0 then

		pvptable[localname] = 1

		minetest.chat_send_player(localname,
			"PvP was enabled for "..localname)

			player:hud_remove(pvpdisabled)

			player:hud_remove(nopvppic)

			pvpenabled = player:hud_add({
				hud_elem_type = "text",
				position = {x = 1, y = 0},
				offset = {x=-100, y = 20},
				scale = {x = 100, y = 100},
				text = "PvP is enabled for you!",
				number = 0xFF0000 -- Red
			})
			pvppic = player:hud_add({
				hud_elem_type = "image",
				position = {x = 1, y = 0},
				offset = {x=-185, y = 20},
				scale = {x = 1, y = 1},
				text = "pvp.png"
			})
		return

	else

		pvptable[localname] = 0

		minetest.chat_send_player(localname,
			"PvP was disabled for "..localname)

			player:hud_remove(pvpenabled)

			player:hud_remove(pvppic)
			
			pvpdisabled = player:hud_add({
				hud_elem_type = "text",
				position = {x = 1, y = 0},
				offset = {x=-100, y = 20},
				scale = {x = 100, y = 100},
				text = "PvP is disabled for you!",
				number = 0x7DC435
			})
			nopvppic = player:hud_add({
				hud_elem_type = "image",
				position = {x = 1, y = 0},
				offset = {x = -185, y = 20},
				scale = {x = 1, y = 1},
				text = "nopvp.png"
			})
		return
	end
end

unified_inventory.register_button("pvp", {
	type = "image",
	image = "pvp.png",
	action = pvp_toggle
})

minetest.register_on_joinplayer(function(player)

	nopvppic = player:hud_add({
		hud_elem_type = "image",
		position = {x = 1, y = 0},
		offset = {x = -185, y = 20},
		scale = {x = 1, y = 1},
		text = "nopvp.png"
	})

	pvpdisabled = player:hud_add({
		hud_elem_type = "text",
		position = {x = 1, y = 0},
		offset = {x=-100, y = 20},
		scale = {x = 100, y = 100},
		text = "PvP is disabled for you!",
		number = 0x7DC435
	})

	localname = player:get_player_name()
	pvptable[localname] = 0
end)

if minetest.setting_getbool("enable_pvp") then
	if minetest.register_on_punchplayer then
		minetest.register_on_punchplayer(
			function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage, pvp)
			
			if not hitter:is_player() then
				return false
			end
			
			local localname = player:get_player_name()
			local hittername = hitter:get_player_name()
			
				if pvptable[localname] == 1 and pvptable[hittername] == 1 then
					return false
				else
					minetest.chat_send_player(localname,
					"The player "..hittername.." is trying to attack you.")
					minetest.chat_send_player(hittername,
					"The player "..localname.." does not have PvP activated.")
					return true
				end
		end)
	end
end
