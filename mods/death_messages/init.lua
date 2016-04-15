-----------------------------------------------------------------------------------------------
local title	= "Death Messages"
local version = "0.1.2"
local mname	= "death_messages"
-----------------------------------------------------------------------------------------------
dofile(minetest.get_modpath("death_messages").."/settings.txt")
-----------------------------------------------------------------------------------------------

-- A table of quips for death messages
local messages = {}

-- Another one to avoid double death messages
local whacked = {}

local logfile = minetest.get_worldpath() .. "/death_logs.txt"

-- Lava death messages
messages.lava = {
	"%s thought lava was cool. / %s pensait que la lave etait cool.",
	"%s felt an urgent need to touch lava. / %s s'est senti obligé(e) de toucher la lave.",
	"%s died in lava. / %s est mort(e) dans de la lave.",
	"%s didn't know lava was very hot. / %s ne savait pas que la lave était vraiment chaude.",
	"%s melted into a ball of fire. / %s est devenu(e) une boule de feu.",
	"%s couldn't resist to the warm glow of lava. / %s n'a pas pu se retenir face à la chaude lueur de la lave.",
}

-- Drowning death messages
messages.water = {
	"%s lacked oxygen. / %s a manqué d'air.",
	"%s ran out of air. / %s n'avait plus d'air.",
	"%s tried to impersonate an anchor. / %s a essayé d'usurper l'identité d'une ancre.",
	"%s forgot he/she was not a fish. / %s a oublié qu'il/elle n'était pas un poisson.",
	"%s forgot he needed to breath underwater. / %s a oublié qu'il lui fallait respirer sous l'eau.",
	"%s is not good at swimming. / %s n'est pas bon(ne) en natation.",
	"%s forgot his/her scaphander. / %s a oublié son scaphandre.",
	"%s failed his/her swimming lessons. / %s a raté ses cours de natation."
}

-- Burning death messages
messages.fire = {
	"%s was a bit too hot. / %s a eu un peu trop chaud.",
	"%s was too close to the fire. / %s a été trop près du feu.",
	"%s just got roasted. / %s vient de se faire rotir.",
	"%s got burnt. / %s a été carbonisé(e).",
	"%s thought he/she was a torch. / %s a pensé qu'il/elle était une torche.",
	"%s got a little too warm. / %s a eu un peu trop chaud.",
	"%s just got roasted, hotdog style. / %s vient de se faire rôtir façon hotdog.",
	"%s was set aflame. More light that way. / %s s'est embrasé(e). Ça fait plus de lumière.",
}

-- Quicksands death messages
messages.sand = {
	"%s learnt that sand is less fluid than water. / %s a appris que le sable est moins fluide que l'eau.",
	"%s joined the mummies. / %s a rejoint les momies.",
	"%s got themselves buried. / %s s'est fait(e) ensevelir.",
}

-- Other death messages
messages.other = {
	"%s did something fatal to him. / %s a fait quelque chose qui lui a ete fatal.",
	"%s died. / %s est mort(e).",
	"%s left this world. / %s n'est plus de ce monde.",
	"%s reached miner's heaven. / %s a rejoint le paradis des mineurs.",
	"%s lost their life. / %s a perdu la vie.",
	"%s saw the light. / %s a vu la lumiere.",
	"%s fell from a bit too high. / %s est tombe d'un peu trop haut.",
	"%s slipped on a banana skin. / %s a glisse sur une peau de banane.",
	"%s wanted to test his super powers. / %s a voulu tester ses super pouvoirs.",
	"%s gave up on life. / %s a décidé de mourir.",
	"%s is somewhat dead now. / %s est plus ou moins mort(e) maintenant.",
	"%s passed out - permanently. / %s s'est évanoui(e) - pour toujours.",
}

-- Whacking death messages
messages.whacking = {
	"%s has been killed by %s. / %s a été tué par %s.",
	"%s got whacked by %s. / %s s'est pris une raclée de la part de %s.",
	"%s's grave was dug by %s. / La tombe de %s a été creusée par %s.",
	"%s got recycled by %s. / %s s'est fait recycler par %s.",
	"%s surely annoyed %s. / %s embêtait sûrement %s."
	-- Need to fill
}

messages.monsters_whacking = {
	"%s has been killed by a %s. / %s a été tué par un %s.",
	"%s got whacked by a %s. / %s s'est pris une raclée de la part d'un %s.",
	"Darwin said : %s was less adapted than a %s. / Darwin a dit : %s était moins adapté qu'un %s.",
	"%s was transformed into a doormat by a %s. / %s s'est fait transformer en paillasson par un %s.",
	-- Need to fill
}

-- Monsters

local monsters = {
	["mobs:fireball"] = "dungeon master",
	["mobs:dungeon_master"] = "dungeon master",
	["mobs:spider"] = "spider",
	["mobs:sand_monster"] = "sand monster",
	["mobs:cow"] = "cow",
	["mobs:npc"] = "npc",
	["mobs:oerkki"] = "oerkki",
	["mobs:stone_monster"] = "stone monster",
	["mobs:dirt_monster"] = "dirt monster",
	["mobs:tree_monster"] = "tree monster",
	["mobs:mese_arrow"] = "mese monster",
	["mobs:pumba"] = "warthog",
}

local function broadcast_death(msg)
	minetest.chat_send_all(msg)
	local logfilep = io.open(logfile, "a")
	logfilep:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. msg .. "\n")
	logfilep:close()
	if irc then
		irc:say(msg)
	end
end

minetest.register_on_punchplayer(function(player, hitter, time,
	tool_caps, dir, damage)
	if player:get_hp() - damage <= 0 and not whacked[player:get_player_name()] then
		local player_name = player:get_player_name()
		local death_message
		if hitter:is_player() then
			death_message = string.format(messages.whacking[math.random(1,#messages.whacking)], player_name, hitter:get_player_name(), player_name, hitter:get_player_name())
		else
			local entity_name = monsters[hitter:get_luaentity().name] or "monster"
			death_message = string.format(messages.monsters_whacking[math.random(1, #messages.monsters_whacking)], player_name, entity_name, player_name, entity_name)
		end
		broadcast_death(death_message)
		whacked[player_name] = true
	end
end)


minetest.register_on_leaveplayer(function(player)
	whacked[player:get_player_name()] = nil
end)

minetest.register_on_respawnplayer(function(player)
	whacked[player:get_player_name()] = nil
end)

if RANDOM_MESSAGES == true then
	minetest.register_on_dieplayer(function(player)
		local player_name = player:get_player_name()
		local node = minetest.registered_nodes[minetest.get_node(player:getpos()).name]
		if minetest.is_singleplayer() then
			player_name = "You"
		end

		local death_message = ""

		if not whacked[player_name] then

			-- Death by lava
			if node.groups.lava ~= nil then
				death_message = messages.lava[math.random(1,#messages.lava)]
			-- Death by acid
			elseif node.groups.acid ~= nil then
				death_message = messages.acid[math.random(1,#messages.acid)]
			-- Death by drowning
			elseif player:get_breath() == 0 and node.groups.water then
				death_message = messages.water[math.random(1,#messages.water)]
			-- Death by fire
			elseif node.name == "fire:basic_flame" then
				death_message = messages.fire[math.random(1,#messages.fire)]
			-- Death in quicksand
			elseif player:get_breath() == 0 and node.name == "default:sand_source" or node.name == "default:sand_flowing" then
				death_message = messages.sand[math.random(1,#messages.sand)]
			-- Death by something else
			else
				death_message = messages.other[math.random(1,#messages.other)]
			end

			-- Actually tell something
			death_message = string.format(death_message, player_name, player_name)
			broadcast_death(death_message)
			whacked[player_name] = true
		end
	end)

else
	-- Should we keep that part?
	minetest.register_on_dieplayer(function(player)
		local player_name = player:get_player_name()
		local node = minetest.registered_nodes[minetest.get_node(player:getpos()).name]
		if minetest.is_singleplayer() then
			player_name = "You"
		end
		if not whacked[player_name] then
			-- Death by lava
			if node.groups.lava ~= nil then
				minetest.chat_send_all(player_name .. " melted into a ball of fire")
			-- Death by drowning
			elseif player:get_breath() == 0 then
				minetest.chat_send_all(player_name .. " ran out of air.")
			-- Death by fire
			elseif node.name == "fire:basic_flame" then
				minetest.chat_send_all(player_name .. " burned to a crisp.")
			-- Death by something else
			else
				minetest.chat_send_all(player_name .. " died.")
			end
		end
	end)
end

-----------------------------------------------------------------------------------------------
minetest.log("action", "[Mod] "..title.." ["..version.."] ["..mname.."] Loaded...")
-----------------------------------------------------------------------------------------------
