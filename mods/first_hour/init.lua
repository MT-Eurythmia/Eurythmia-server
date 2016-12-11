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

MSG = {
	welcome = {
		'french' = "Bienvenue sur le serveur Mynetest !\nVous êtes invicible et ne pouvez pas frapper les autres joueurs pendant une heure.\nVous pourrez commencer à jouer dans "..PLAY_ENOUGH_MINUTES.." minutes.\nSi vous lisez les panneaux !",
		'english' = "Welcome to the Mynetest server !\nYou are invincible and you cannot hit other players during a hour.\nYou will be able to play in "..PLAY_ENOUGH_MINUTES.." minutes.\nIf you read the signs!"
	},
	end_first_hour = {
		'french' = "Ce n'est plus votre première heure... Vous n'êtes plus invicible et vous pouvez frapper les autres joueurs à présent.",
		'english' = "It is not your first hour anymore... You are now not invincible and you are able to hit other players."
	},
	code_with_interact = {
		'french' = "Vous pouvez deja jouer. Et n'envoyer pas le code aux autres joueurs merci.",
		'english' = "You can already play. And thanks not to send the code to other players."
	},
	interact = {
		'french' = "Vous pouvez maintenant commencer à jouer, vous avez obtenu le privilège interact! Merci d'avoir lu les panneaux, vous pouvez revenir a cet endroit au moyen de /spawn :-)",
		'english' = "Let's play, you got the interact privilege! Thanks for having read the signs, you can always come here using /spawn"
	},
	code_too_early = {
		'english' = "You haven't been here "..PLAY_ENOUGH_MINUTES.." minutes yet. Wait a few moment and then retry it! If you didn't read all the signs, please do it",
		'french' = "Vous n'avez pas encore joué "..PLAY_ENOUGH_MINUTES.." minutes ici. Patientez un peu et réessayez! Si vous n'avez pas lu tous les panneaux, veuillez le faire merci.")
	}
}

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
		meta:set_string("infotext", "Ecrivez "..THECODE.." dans le chat pour pouvoir commencer a jouer!")
		meta:set_string("text", "#0Ecrivez "..THECODE.." dans le chat pour pouvoir commencer a jouer!")

		get_far_node(ENGLISH_SIGN)
		meta = minetest.get_meta(ENGLISH_SIGN)
		meta:set_string("infotext", "Type "..THECODE.." in the chat to play!")
		meta:set_string("text", "#0Type "..THECODE.." in the chat to play!")
	end

	-- Show formspec to player if he has not interact and is not in the players table
	local name = player:get_player_name()
	if players[name] then
		return
	end
	if minetest.get_player_privs(name).interact then
		return
	end

	local formspec = "size[5,1.5;]"..
		         "label[0,0;Merci de choisir votre langue.\nPlease choose your preferred language.]"..
		         "button[0,1;2,1;fr;Français]button[2,1;2,1;en;English]"
	minetest.show_formspec(name, "first_hour:language_select", formspec)
end)

minetest.register_on_chat_message(function(name, message)
	if message == THECODE then
		if minetest.get_player_privs(name).interact then
			minetest.chat_send_player(name, MSG.code_with_interact[players[name]])
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
			minetest.chat_send_player(name, MSG.interact[players[name]])
			minetest.chat_send_all(name..", nouveau joueur anglophone, a rejoint le jeu!\nThe new English-speaker player "..name.." joined the game!")
			return true
		else
			minetest.log("info", "Player "..name.." didn't play enough time yet.")
			minetest.chat_send_player(name, MSG.code_too_early[players[name]])
			return true
		end
	end
end


local function begin_game(name)
	minetest.log("action", "First hour of player "..name.." begins")

	local text = MSG.welcome[players[name]]
	minetest.chat_send_player(name, text)

	local formspec = "size[8,2.5;]"..
	           "label[0,0;"..text.."]"..
	           "button_exit[3,2;2,1;exit;Ok]"
	minetest.show_formspec(name, "first_hour:welcome", formspec)

	minetest.after(PLAY_ENOUGH_MINUTES*60, function(name) -- After PLAY_ENOUGH_MINUTES minutes
		played_enough[name] = true
	end, name)

	minetest.after(3600, function(name, pos) -- After a hour
		minetest.chat_send_player(name, MSG.end_first_hour[players[name]])
		players[name] = nil
		minetest.log("info", "End of first hour of player "..name)
	end, name)

end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "first_hour:language_select" then
		return
	end

	local name = player:get_player_name()

	if fields["en"] then
		players[name] = 'english'
		begin_game(name)
	elseif fields["fr"] then
		players[name] = 'french'
		begin_game(name)
	else
		local formspec = "size[5,1.5;]"..
	                         "label[0,0;Merci de choisir votre langue.\nPlease choose your preferred language.]"..
	                         "button[0,1;2,1;fr;Français]button[2,1;2,1;en;English]"
		minetest.show_formspec(name, "first_hour:language_select", formspec)
	end
end)

minetest.register_on_punchplayer(function(player, hitter, time, tool_caps, dir, damage)
	if players[player:get_player_name()] then
		minetest.chat_send_player(player:get_player_name(), "You have been punched but you are invicible because it's your first hour.")
		minetest.log("action", "Player "..player:get_player_name().." has been punched during his first hour.")
		return true
	end
	if hitter:is_player() then
		if players[hitter:get_player_name()] then
			minetest.chat_send_player(hitter:get_player_name(), "You can't punch a player during your first hour.")
			minetest.log("action", "Player "..hitter:get_player_name().." has punched "..player:get_player_name().." during his first hour.")
			return true
		end
	end
end)
