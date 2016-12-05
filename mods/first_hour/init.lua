local players = {}
local played_enough = {}

local PLAY_ENOUGH_MINUTES = 2

--Production values
local FRENCH_SIGN = {x=-21, y=30001, z=-1}
local ENGLISH_SIGN = {x=-21, y=30001, z=1}

--Development values
--local FRENCH_SIGN = {x=144, y=30003, z=105}
--local ENGLISH_SIGN = {x=144, y=30003, z=107}

local THECODE = '431C' --will be randomly chosen when first player joins

--our code is always 4 chars, 3 numbers + 1 letter
local function getRandomCode()
	--first chars are numbers
  local array = {}
  for i = 1, 3 do
    array[i] = string.char(math.random(48, 57))
  end
	--last char is an alphabet capital letter
	array[4] = string.char(math.random(65, 90))
  return table.concat(array)
end

local function get_far_node(pos)
	--local node = minetest.get_node(pos)
	--if node.name == "ignore" then
		local manip = minetest.get_voxel_manip()
		manip:read_from_map(pos, pos)
		local node = minetest.get_node(pos)
	--end
	return node
end

--Hack we'll do that sign text replacement when the first player joins
local is_Loaded = false
minetest.register_on_joinplayer(function(player)
	if is_Loaded == false then
		is_Loaded = true
		THECODE = getRandomCode()

		--will load the far node first
		get_far_node(FRENCH_SIGN)
		--get his meta and change the text + infotext with the code on the sign!
		local meta = minetest.get_meta(FRENCH_SIGN)
		meta:set_string("infotext", "Ces regles s'appliquent a tous et si vous acceptez ces regles vous pouvez jouer sur notre serveur. Le privilege interact n'est accorde qu'apres avoir lu les regles et sous reserve d'ecrire "..THECODE.." dans le chat et apres "..PLAY_ENOUGH_MINUTES.." minutes de jeu.")
		meta:set_string("text", "#0Ces regles s'appliquent a tous et si vous acceptez ces regles vous pouvez jouer sur notre serveur. Le privilege interact n'est accorde qu'apres avoir lu les regles et sous reserve d'ecrire #6"..THECODE.." #0dans le chat et apres #6"..PLAY_ENOUGH_MINUTES.." #0minutes de jeu.")

		get_far_node(ENGLISH_SIGN)
		meta = minetest.get_meta(ENGLISH_SIGN)
		meta:set_string("infotext", "These rules apply for all and if you accept these rules then you can play on our server. The interract privilege will only be given to you after you have read these rules and if you write "..THECODE.." in the chat and have at least played "..PLAY_ENOUGH_MINUTES.." minutes here.")
		meta:set_string("text", "#0 These rules apply for all and if you accept these rules then you can play on our server. The interract privilege will only be given to you after you have read these rules and if you write #6"..THECODE.." #0in the chat and have at least played #6"..PLAY_ENOUGH_MINUTES.." #0minutes here.")
	end

	-- Show formspec to player if he has not interact and is not in the players table
	local name = player:get_player_name()
	for _, player in ipairs(players) do
		if player == name then
			return
		end
	end
	if minetest.get_player_privs(name).interact then
		return
	end

	local formspec = "size[5,1.5;]"..
		         "label[0,0;Merci de choisir votre langue.\nPlease choose your preferred language.]"..
		         "button[0,1;2,1;fr;Français]button[2,1;2,1;en;English]"
	minetest.show_formspec(name, "first_hour:language_select", formspec)
end)


local function begin_game_english(name)

	minetest.log("action", "First hour of player "..name.." begins")
	table.insert(players, name)

	local text = "Welcome to the Mynetest server !\nYou are invincible and you cannot hit other players during a hour.\nYou will be able to play in "..PLAY_ENOUGH_MINUTES.." minutes.\nIf you read the signs!"
	minetest.chat_send_player(name, text)

	local formspec = "size[8,2.5;]"..
	           "label[0,0;"..text.."]"..
	           "button_exit[3,2;2,1;exit;Ok]"
	minetest.show_formspec(name, "first_hour:welcome", formspec)

  minetest.after(PLAY_ENOUGH_MINUTES*60, function(name) -- After PLAY_ENOUGH_MINUTES minutes
		played_enough[name] = true
	end, name)

	minetest.register_on_chat_message(function(name, message)
		if message == THECODE then
      if minetest.get_player_privs(name).interact then
        minetest.chat_send_player(name, "You can already play. And thanks not to send the code to other players.")
        return true
      end
			minetest.log("info", "Player "..name.." entered the right code.")
			if played_enough[name] ~= nil then
				minetest.log("info", "Player "..name.." played enough time.")
				local privs = minetest.get_player_privs(name)
				privs.interact = true
				minetest.set_player_privs(name, privs)
				minetest.log("info", "Player "..name.." got the interact privilege.")

				local player = minetest.get_player_by_name(name)
				if not player then -- If the player has disconnected
					return true
				end

				played_enough[name] = nil
				player:setpos({x = 0, y = 18, z = 0})

				minetest.chat_send_player(name, "Let's play, you got the interact privilege! Thanks for having read the signs, you can always come here using /spawn")
				minetest.chat_send_all(name..", nouveau joueur anglophone, a rejoint le jeu!\nThe new English-speaker player "..name.." joined the game!")
				return true
			else
				minetest.log("info", "Player "..name.." didn't play enough time yet.")
				minetest.chat_send_player(name, "You haven't been here "..PLAY_ENOUGH_MINUTES.." minutes yet. Wait a few moment and then retry it! If you didn't read all the signs, please do it")
			 return true
			end
		end
	end)

	minetest.after(3600, function(name, pos) -- After a hour
		minetest.chat_send_player(name, "It is not your first hour anymore... You are now not invincible and you are able to hit other players.")

		table.remove(players, pos)

		minetest.log("info", "End of first hour of player "..name)
	end, name, table.getn(players))

end



local function begin_game_french(name)

	minetest.log("action", "First hour of player "..name.." begins")
	table.insert(players, name)

	local text = "Bienvenue sur le serveur Mynetest !\nVous êtes invicible et ne pouvez pas frapper les autres joueurs pendant une heure.\nVous pourrez commencer à jouer dans "..PLAY_ENOUGH_MINUTES.." minutes.\nSi vous lisez les panneaux !"
	minetest.chat_send_player(name, text)

	local formspec = "size[10,2.5;]"..
	           "label[0,0;"..text.."]"..
	           "button_exit[4,2;2,1;exit;Ok]"
	minetest.show_formspec(name, "first_hour:welcome", formspec)

	minetest.after(PLAY_ENOUGH_MINUTES*60, function(name) -- After PLAY_ENOUGH_MINUTES minutes
		played_enough[name] = true
	end, name)

	minetest.register_on_chat_message(function(name, message)
		if message == THECODE then
      if minetest.get_player_privs(name).interact then
        minetest.chat_send_player(name, "Vous pouvez deja jouer. Et n'envoyer pas le code aux autres joueurs merci.")
        return true
      end
			minetest.log("info", "Player "..name.." entered the right code.")
			if played_enough[name] ~= nil then
				minetest.log("info", "Player "..name.." played enough time.")
				local privs = minetest.get_player_privs(name)
				privs.interact = true
				minetest.set_player_privs(name, privs)
				minetest.log("info", "Player "..name.." got the interact privilege.")

				local player = minetest.get_player_by_name(name)
				if not player then -- If the player has disconnected
					return true
				end

				played_enough[name] = nil
				player:setpos({x = 0, y = 18, z = 0})

				minetest.chat_send_player(name, "Vous pouvez maintenant commencer à jouer, vous avez obtenu le privilège interact! Merci d'avoir lu les panneaux, vous pouvez revenir a cet endroit au moyen de /spawn :-)")
				minetest.chat_send_all(name..", nouveau joueur français, a rejoint le jeu!\nThe new French player "..name.." joined the game!")
				return true
			else
				minetest.log("info", "Player "..name.." didn't play enough time yet.")
				minetest.chat_send_player(name, "Vous n'avez pas encore joué "..PLAY_ENOUGH_MINUTES.." minutes ici. Patientez un peu et réessayez! Si vous n'avez pas lu tous les panneaux, veuillez le faire merci.")
				return true
			end
		end
	end)

	minetest.after(3600, function(name, pos) -- After a hour
		minetest.chat_send_player(name, "Ce n'est plus votre première heure... Vous n'êtes plus invicible et vous pouvez frapper les autres joueurs à présent.")

		table.remove(players, pos)

		minetest.log("info", "End of first hour of player "..name)
	end, name, table.getn(players))
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "first_hour:language_select" then
		return
	end

	local name = player:get_player_name()

	if fields["en"] then
		begin_game_english(name)
	elseif fields["fr"] then
		begin_game_french(name)
	else
		local formspec = "size[5,1.5;]"..
	                         "label[0,0;Merci de choisir votre langue.\nPlease choose your preferred language.]"..
	                         "button[0,1;2,1;fr;Français]button[2,1;2,1;en;English]"
		minetest.show_formspec(name, "first_hour:language_select", formspec)
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
