local storage = minetest.get_mod_storage()

minetest.register_privilege("news_editor", {
	description = "Can edit the news",
	give_to_singleplayer = true
})

unified_inventory.register_page("news", {
	get_formspec = function(player)
		local player_name = player:get_player_name()
		local formspec = "background[0.06,0.99;7.92,7.52;ui_misc_form.png]"
		local news_text = storage:get_string("txt")
		formspec = formspec.."label[0,0;".."News".."]"
		if minetest.check_player_privs(player, "news_editor") then
			formspec = formspec.."textarea[0.2,0.4;8.1,3.2;news_text;;"..news_text.."]"
			formspec = formspec.."button[3,3.6;2,1;news_submit;Submit]"
		else
			formspec = formspec.."textarea[0.2,0.4;8.1,4;news_text;;"..news_text.."]"
		end
		return {formspec=formspec}
	end,
})

unified_inventory.register_button("news", {
	type = "image",
	image = "default_book.png",
	tooltip = "News"
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "" then
		return
	end
	if fields["news_submit"] then
		if minetest.check_player_privs(player, "news_editor") then
			minetest.chat_send_player(player:get_player_name(), "News submitted")
			-- Escape square brackets. This is an engine bug.
			local txt = fields["news_text"]
			if txt then
				txt = string.gsub(txt, "%[", "\\[")
				txt = string.gsub(txt, "%]", "\\]")
				storage:set_string("txt", txt)
			end
			minetest.log("action", "Player " .. player:get_player_name() .. " edited the news.")
		else
			minetest.chat_send_player(player:get_player_name(), "You can't edit the news. Missing privilege: news_editor")
		end
	end
end)
