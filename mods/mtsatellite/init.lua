--[[
This mod is highly system-specific.
It is not supposed to be used as a player, but as a server administrator.
It will be very hard for you to understand it without knowing the system
specificities - if you wish to get explanations though, please send your
questions by mail at <upsilon@langg.net>, I'll be happy to answer you.
]]

local ie = minetest.request_insecure_environment()
if not ie then
	minetest.log("error", "[mtsatellite] Needs an insecure environment.")
	return
end

local base_path = minetest.get_modpath(minetest.get_current_modname())
loadfile(base_path.."/players.lua")(ie)
loadfile(base_path.."/POIs.lua")(ie)
