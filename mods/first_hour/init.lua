local players = {}

local function begin_game_english(name)
	local text = "Welcome to the Mynetest server !\nYou are invincible and you cannot hit other players during a hour.\nYou will be able to play in 5 minutes.\nRead the signs to wait!"

	minetest.chat_send_player(name, text)

	local formspec = "size[8,2.5;]"..
	           "label[0,0;"..text.."]"..
	           "button_exit[3,2;2,1;exit;Ok]"
	minetest.show_formspec(name, "first_hour:welcome", formspec)

	minetest.after(300, function(name) -- After five minutes
		minetest.log("info", "Player "..name.." got the interact privilege.")

		local privs = minetest.get_player_privs(name)
		privs.interact = true
		minetest.set_player_privs(name, privs)

		minetest.get_player_by_name(name):setpos({x = 0, y = 18, z = 0})

		minetest.chat_send_player(name, "Let's play, you got the interact privilege! If you didn't read the signs, you can still do it using /spawn :-)")

		minetest.chat_send_all(name..", nouveau joueur anglophone, a rejoint le jeu!\nThe new English-speaker player "..name.." joined the game!")
	end, name)

	minetest.after(3600, function(name, pos) -- After a hour
		minetest.chat_send_player(name, "It is not your first hour anymore... You are now not invincible and you are able to hit other players.")

		table.remove(players, pos)

		minetest.log("info", "End of first hour of player "..name)
	end, name, table.getn(players))
end

local function begin_game_french(name)
	local text = "Bienvenue sur le serveur Mynetest !\nVous êtes invicible et ne pouvez pas frapper les autres joueurs pendant une heure.\nVous pourrez commencer à jouer dans 5 minutes.\nLisez les panneaux en attendant!"

	minetest.chat_send_player(name, text)

	local formspec = "size[10,2.5;]"..
	           "label[0,0;"..text.."]"..
	           "button_exit[4,2;2,1;exit;Ok]"
	minetest.show_formspec(name, "first_hour:welcome", formspec)

	minetest.after(300, function(name) -- After five minutes
		minetest.log("info", "Player "..name.." got the interact privilege.")

		local privs = minetest.get_player_privs(name)
		privs.interact = true
		minetest.set_player_privs(name, privs)

		minetest.get_player_by_name(name):setpos({x = 0, y = 18, z = 0})

		minetest.chat_send_player(name, "Vous pouvez maintenant commencer à jouer, vous avez obtenu le privilège interact! Si vous n'avez pas eu le temps de lire les panneaux, vous pouvez le faire au moyen de /spawn :-)")

		minetest.chat_send_all(name..", nouveau joueur français, a rejoint le jeu!\nThe new French player "..name.." joined the game!")
	end, name)

	minetest.after(3600, function(name, pos) -- After a hour
		minetest.chat_send_player(name, "Ce n'est plus votre première heure... Vous n'êtes plus invicible et vous pouvez frapper les autres joueurs à présent.")

		table.remove(players, pos)

		minetest.log("info", "End of first hour of player "..name)
	end, name, table.getn(players))
end

minetest.register_on_newplayer(function(player)
	local name = player:get_player_name()

	minetest.log("action", "First hour of player "..name.." begins")
	table.insert(players, name)

	local formspec = "size[5,1.5;]"..
	                 "label[0,0;Merci de choisir votre langue.\nPlease choose your preferred language.]"..
	                 "button[0,1;2,1;fr;Français]button[2,1;2,1;en;English]"
	minetest.show_formspec(name, "first_hour:language_select", formspec)
	
	minetest.log("info", "First hour of player "..name.." begins")
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "first_hour:language_select" then
		return
	end

	local name = player:get_player_name()
	
	if fields["en"] then
		begin_game_english(name)
	else
		begin_game_french(name)
	end
end)

minetest.register_on_punchplayer(function(player, hitter, time, tool_caps, dir, damage)
	for i = 1, #players do
		if players[i] == player:get_player_name() then
			minetest.chat_send_player(player:get_player_name(), "You have been punched but you are invicible because it's your first hour.")
			minetest.log("action", "Player "..player:get_player_name().." has been punched during his first hour.")
			return true
		end
		if hitter:is_player() then
			if players[i] == hitter:get_player_name() then
				minetest.chat_send_player(hitter:get_player_name(), "You can't punch a player during your first hour.")
				minetest.log("action", "Player "..hitter:get_player_name().." has punched "..player:get_player_name().." during his first hour.")
				return true
			end
		end
	end
end)
