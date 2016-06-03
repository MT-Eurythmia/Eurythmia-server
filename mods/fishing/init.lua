-----------------------------------------------------------------------------------------------
local title		= "Fishing - Crabman77's (MFF team) version"
local version 	= "0.0.5"
local mname		= "fishing"
-----------------------------------------------------------------------------------------------
-- original by wulfsdad (http://forum.minetest.net/viewtopic.php?id=4375)
-- rewrited by Mossmanikin (https://forum.minetest.net/viewtopic.php?id=6480)
-- this version rewrited by Crabman77
-- License (code & textures): 	WTFPL
-- Contains code from: 		animal_clownfish, animal_fish_blue_white, fishing (original), stoneage
-- Looked at code from:		default, farming
-- Dependencies: 			default
-- Supports:				animal_clownfish, animal_fish_blue_white, animal_rat, mobs
-----------------------------------------------------------------------------------------------

minetest.log("action","[mod fishing] Loading...")
local path = minetest.get_modpath("fishing").."/"

fishing_setting = {}
fishing_setting.func = {}
fishing_setting.is_creative_mode = minetest.setting_getbool("creative_mode")
fishing_setting.file_settings = minetest.get_worldpath() .. "/fishing_config.txt"
fishing_setting.file_trophies = minetest.get_worldpath() .. "/fishing_trophies.txt"
fishing_setting.file_contest = minetest.get_worldpath() .. "/fishing_contest.txt"
fishing_setting.settings = {}
fishing_setting.contest = {}
--for random object
random_objects = {}
fishing_setting.baits = {}
fishing_setting.hungry = {}
fishing_setting.prizes = {}
fishing_setting.trophies = {}

if (minetest.get_modpath("intllib")) then
  dofile(minetest.get_modpath("intllib").."/intllib.lua")
  fishing_setting.func.S = intllib.Getter(minetest.get_current_modname())
else
  fishing_setting.func.S = function ( s ) return s end
end

dofile(path .."settings.txt")
dofile(path .."functions.lua")

--default_settings
fishing_setting.settings["message"] = MESSAGES
fishing_setting.settings["worm_is_mob"] = WORM_IS_MOB
fishing_setting.settings["worm_chance"] = WORM_CHANCE
fishing_setting.settings["new_worm_source"] = NEW_WORM_SOURCE
fishing_setting.settings["wear_out"] = WEAR_OUT
fishing_setting.settings["simple_deco_fishing_pole"] = SIMPLE_DECO_FISHING_POLE
fishing_setting.settings["bobber_view_range"] = BOBBER_VIEW_RANGE
fishing_setting.settings["fish_chance"] = FISH_CHANCE
fishing_setting.settings["shark_chance"] = SHARK_CHANCE
fishing_setting.settings["treasure_chance"] = TREASURE_CHANCE
fishing_setting.settings["treasure_enable"] = TREASURE_RANDOM_ENABLE
fishing_setting.settings["escape_chance"] = ESCAPE_CHANCE

-- to mobs_fish|mobs_sharks modpack
if (minetest.get_modpath("mobs_fish") ~= nil or minetest.get_modpath("mobs_sharks") ~= nil) then
  fishing_setting.have_true_fish = true
end 

-- load config file if exist in worldpath
fishing_setting.func.load()

dofile(path .."worms.lua")
dofile(path .."crafting.lua")
dofile(path .."baits.lua")
dofile(path .."prizes.lua")
dofile(path .."baitball.lua")
dofile(path .."bobber.lua")
dofile(path .."bobber_shark.lua")
dofile(path .."fishes.lua")
dofile(path .."trophies.lua")
dofile(path .."poles.lua")

--random hungry bait
fishing_setting.func.hungry_random()
--load table caught fish by players
fishing_setting.func.load_trophies()
--load table contest
fishing_setting.func.load_contest()
fishing_setting.func.tick()

-----------------------------------------------------------------------------------------------
minetest.log("action", "[Mod] "..title.." ["..version.."] ["..mname.."] Loaded...")
-----------------------------------------------------------------------------------------------
