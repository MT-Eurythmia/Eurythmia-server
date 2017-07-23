local players = {}
local played_enough = {}

local PLAY_ENOUGH_MINUTES = 1

--Production values
local FRENCH_SIGN = {x=7, y=30015, z=65}
local ENGLISH_SIGN = {x=15, y=30015, z=68}
local INITIAL_SPAWNPOINT = {x=4, y=30015, z=71}
local SECOND_SPAWNPOINT = {french = {x=18, y=30015, z=65}, english = {x=4, y=30015, z=67}}
local START_GAME_SPAWNPOINT = {xw=0, y=18, z=0}

--Development values
--local FRENCH_SIGN = {x=144, y=30003, z=105}
--local ENGLISH_SIGN = {x=144, y=30003, z=107}

local THECODE = '431C' --will be randomly chosen when first player joins

local MSG = {
	welcome = {
		['french'] = "Bienvenue sur le serveur Eurythmia !\nVous êtes invincible et ne pouvez pas frapper les autres joueurs pendant une heure.\nVous ne pouvez pas encore jouer, c'est normal.",
		['english'] = "Welcome to the Eurythmia server!\nYou are invincible and you cannot hit other players during a hour.\nYou cannot play yet, this is normal."
	},
	read_the_signs = {
		['french'] = "Maintenant, lisez tous les panneaux !",
		['english'] = "Now, read the signs!"
	},
	end_first_hour = {
		['french'] = "Ce n'est plus votre première heure... Vous n'êtes plus invicible et vous pouvez frapper les autres joueurs à présent.",
		['english'] = "It is not your first hour anymore... You are now not invincible and you are able to hit other players."
	},
	code_with_interact = {
		['french'] = "Vous pouvez deja jouer. Et n'envoyer pas le code aux autres joueurs merci.",
		['english'] = "You can already play. And thanks not to send the code to other players.",
		['both'] = "You can already play! Vous pouvez déjà jouer !"
	},
	interact = {
		['french'] = "Vous pouvez maintenant commencer à jouer, vous avez obtenu le privilège interact ! Merci d'avoir lu les panneaux, vous pouvez relire les règles en tapant /spawn :-)",
		['english'] = "Let's play, you got the interact privilege! Thanks for having read the signs, you can always re-read the rules by typing /spawn :-)"
	},
	code_too_early = {
		['french'] = "Vous n'avez pas encore joué "..PLAY_ENOUGH_MINUTES.." "..(PLAY_ENOUGH_MINUTES < 2 and "minute" or "minutes").." ici. Patientez un peu et réessayez ! Si vous n'avez pas lu tous les panneaux, veuillez le faire merci.",
		['english'] = "You haven't been here "..PLAY_ENOUGH_MINUTES.." "..(PLAY_ENOUGH_MINUTES < 2 and "minute" or "minutes").." yet. Wait a few moment and then retry it! If you didn't read all the signs, please do it"
	},
	new_player = {
		['french'] = ", nouveau joueur francophone a rejoint le jeu!",
		['english'] = ', new english player joined the game !'
	}
}

--our code is always 4 chars, 3 numbers + 1 letter
local function getRandomCode()
	--first chars are numbers
	local array = {}
	for i = 1, 3 do
		array[i] = string.char(math.random(49, 57)) -- Do not include 48 (0), too close to O
	end
	--last char is an alphabet capital letter
	repeat
		array[4] = string.char(math.random(65, 90))
	until array[4] ~= "O" and array[4] ~= "I" -- Avoid generating O, too close to 0, and I, too close to l
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

local function show_initial_formspec(name)
	local formspec = "size[5,1.5;]"..
	         "label[0,0;Merci de choisir votre langue.\nPlease choose your preferred language.]"..
	         "button[0,1;2,1;fr;Français]button[2,1;2,1;en;English]"
	minetest.show_formspec(name, "first_hour:language_select", formspec)
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

	player:setpos(INITIAL_SPAWNPOINT)
	show_initial_formspec(name)
end)

minetest.register_on_chat_message(function(name, message)
	if string.upper(message) == THECODE then
		if minetest.get_player_privs(name).interact then
			if players[name] ~= nil then
				minetest.chat_send_player(name, MSG.code_with_interact[players[name]])
			else
				minetest.chat_send_player(name, MSG.code_with_interact['both'])
			end
			return true
		end
		minetest.log("info", "Player "..name.." entered the right code.")
		if played_enough[name] ~= nil then
			minetest.log("info", "Player "..name.." played enough time.")

			minetest.set_player_privs(name, {interact = true, home = true, shout = true, zoom = true, spawn=true, pvp=true})
			minetest.log("info", "Player "..name.." got the interact privilege.")
			local player = minetest.get_player_by_name(name)
			if not player then -- If the player has disconnected
				return true
			end
			played_enough[name] = nil
			player:setpos({x = 0, y = 18, z = 0})
			minetest.chat_send_player(name, MSG.interact[players[name]])
			minetest.chat_send_all(name..MSG.new_player[players[name]])
			return true
		else
			minetest.log("info", "Player "..name.." didn't play enough time yet.")
			minetest.chat_send_player(name, MSG.code_too_early[players[name]])
			return true
		end
	end
end)


local function begin_game(name)
	minetest.log("action", "First hour of player "..name.." begins")

	minetest.get_player_by_name(name):setpos(SECOND_SPAWNPOINT[players[name]])

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
		if players[name] ~= nil then
			minetest.chat_send_player(name, MSG.end_first_hour[players[name]])
		end
		if not minetest.get_player_privs(name).interact then -- Still not ?!
			played_enough[name] = nil
			if minetest.get_player_by_name(name) then -- If the player is connected
				minetest.get_player_by_name(name):setpos(INITIAL_SPAWNPOINT)
				show_initial_formspec(name)
			end
		end
		players[name] = nil
		minetest.log("info", "End of first hour of player "..name)
	end, name)

end

local function print_read_the_signs_form(name)
	local text = MSG.read_the_signs[players[name]]
	minetest.chat_send_player(name, text)

	local formspec = "size[8,2.5;]"..
	           "label[0,0;"..text.."]"..
	           "button_exit[3,2;2,1;exit;Ok]"
	minetest.show_formspec(name, "first_hour:read_the_signs", formspec)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local name = player:get_player_name()

	if formname == "first_hour:language_select" then
		if players[name] then
			return
		end

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
	elseif formname == "first_hour:welcome" then
		print_read_the_signs_form(name)
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
