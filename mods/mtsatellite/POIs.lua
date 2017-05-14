-- Don't worry, you're not supposed to understand the content of this file :)
-- This mod is not made to be used as a player.

local ie = ...

local POIs_js_path = "/home/minetest/mtsatellite/web/js/POIs.js"
local buildings_json_path = "/home/minetest/mtsatellite/web/js/POIs_buildings.json"
local travel_json_path = "/home/minetest/mtsatellite/web/js/POIs_travel.json"


local function cannot_open_json(path)
	-- Create it
	local f = ie.io.open(path, "w")
	if not f then
		minetest.log("error", "Couln't open JSON file: " .. path)
		return nil
	end
	local json = minetest.write_json({type = "FeatureCollection", features = {}}, true):gsub("null", "[]")
	f:write(json)
	f:close()

	return ie.io.open(path, "r")
end

local buildings_file = ie.io.open(buildings_json_path, "r")
if not buildings_file then
	buildings_file = cannot_open_json(buildings_json_path)
	if not buildings_file then
		return
	end
end
local buildings = minetest.parse_json(buildings_file:read("*all"))
buildings_file:close()


local travel_file = ie.io.open(travel_json_path, "r")
if not travel_file then
	travel_file = cannot_open_json(travel_json_path)
	if not travel_file then
		return
	end
end
local travelnet = minetest.parse_json(travel_file:read("*all"))
travel_file:close()

local function write_js(json_buildings, json_travel)
	local js_file = ie.io.open(POIs_js_path, "w")
	if not js_file then
		minetest.log("error", "Couln't open JavaScript file: " .. POIs_js_path)
		return
	end

	js_file:write("var buildings = " .. json_buildings .. ";\n\nvar travelnet = " .. json_travel .. ";\n")
	js_file:close()
end

local function write_json(json, path)
	local file = ie.io.open(path, "w")
	file:write(json)
	file:close()
end

local function write()
	local json_buildings = minetest.write_json(buildings, true)
	if #buildings.features == 0 then
		json_buildings = json_buildings:gsub("null", "[]")
	end
	local json_travelnet = minetest.write_json(travelnet, true)
	if #travelnet.features == 0 then
		json_travelnet = json_travelnet:gsub("null", "[]")
	end
	write_json(json_buildings, buildings_json_path)
	write_json(json_travelnet, travel_json_path)
	write_js(json_buildings, json_travelnet)
end

write()


local function add_feature(t, x, y, desc)
	table.insert(t.features, {
		type = "Feature",
		properties = {
	                popupContent = desc,
        	},
		geometry = {
			type = "Point",
			coordinates = {y, x},
		},
	})
end

local function add_building(x, y, desc)
	add_feature(buildings, x, y, desc)
end

local function add_travelnet(x, y, owner, network, station)
	add_feature(travelnet, x, y, "Owner: " .. owner .. "<br />Network: " .. network .. "<br />Station: " .. station)
end


-- Travelnet
local function add_travelnet_at_pos(pos)
	local meta = minetest.get_meta(pos)

	if meta:get_int("mtsatellite_ID") and travelnet.features[meta:get_int("mtsatellite_ID")] then
		return
	end

	local owner_name      = meta:get_string("owner");
	local station_name    = meta:get_string("station_name");
	local station_network = meta:get_string("station_network");

	if owner_name ~= "" and station_name ~= "" and station_network ~= "" then
		add_travelnet(pos.x, pos.z, owner_name, station_network, station_name)
		-- Custom metadata
		meta:set_int("mtsatellite_ID", #travelnet.features)
		write()
	end
end
do
	local def = minetest.registered_nodes["travelnet:travelnet"]
	local old_on_receive_fields = def.on_receive_fields
	local old_after_dig_node = def.after_dig_node
	minetest.override_item("travelnet:travelnet", {
		on_receive_fields = function(pos, ...)
			old_on_receive_fields(pos, ...)

			add_travelnet_at_pos(pos)
		end,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			old_after_dig_node(pos, oldnode, oldmetadata, digger)

			if not oldmetadata then
				return
			end
			if not oldmetadata.mtsatellite_ID or oldmetadata.mtsatellite_ID == 0 then
				return
			end
			table.remove(travelnet.features, oldmetadata.mtsatellite_ID)
			write()
		end
	})
end

minetest.register_lbm({
	label = "Add Travelnet boxes to MTSatellite features",
	name = "mtsatellite:add_travelnet_3",
	nodenames = {"travelnet:travelnet"},
	run_at_every_load = false,
	action = add_travelnet_at_pos
})

-- Buildings
minetest.register_privilege("mtsatellite", "Can use mtsatellite-related chat commands")
minetest.register_chatcommand("add_building", {
	params = "<description>",
	description = "Add a building feature on the MTSatellite at your current pos",
	privs = {mtsatellite = true},
	func = function(name, param)
		local player = minetest.get_player_by_name(name)
		if not player then
			return false
		end
		local pos = vector.round(player:get_pos())

		add_building(pos.x, pos.z, param)

		write()

		return true, "Building added at pos (" .. pos.x .. "," .. pos.z .. "). ID (for removal): " .. tostring(#buildings.features)
	end
})
minetest.register_chatcommand("remove_building", {
	params = "<ID>",
	description = "Remove a building using its ID",
	privs = {mtsatellite = true},
	func = function(name, param)
		local ID = tonumber(param)
		if not ID then
			return false, "Invalid usage. See /help remove_building"
		end

		if not buildings.features[ID] then
			return false, "Building does not exist."
		end

		table.remove(buildings.features, ID)

		write()

		return true, "Removed building."
	end
})
minetest.register_chatcommand("find_building", {
	params = "<regexp>",
	description = "Find a building using a Lua regexp",
	privs = {},
	func = function(name, param)
		local no_result = true
		for i, feature in ipairs(buildings.features) do
			if string.match(feature.properties.popupContent, param) then
				no_result = false
				minetest.chat_send_player(name, feature.properties.popupContent .. " [" .. i .. "]: (" .. feature.geometry.coordinates[2] .. "," .. feature.geometry.coordinates[1] .. ")")
			end
		end

		if no_result then
			return false, "No result found."
		else
			return true
		end
	end
})
