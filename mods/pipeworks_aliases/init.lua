minetest.register_alias("pipeworks:valve_on_loaded", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:grating", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:spigot", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:spigot_pouring", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:entry_panel_empty", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:entry_panel_loaded", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:flow_sensor_empty", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:flow_sensor_loaded", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:fountainhead", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:fountainhead_pouring", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:steel_block_embedded_tube", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:steel_pane_embedded_tub", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:autocrafter", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:one_way_tube", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:trashcan", "default:nyancat_rainbow")
for _, state in ipairs({"on", "off"}) do
	minetest.register_alias("pipeworks:pump_"..state, "default:nyancat_rainbow")
	minetest.register_alias("pipeworks:valve_"..state.."_empty", "default:nyancat_rainbow")
end
for fill = 0, 10 do
	minetest.register_alias("pipeworks:expansion_tank_"..fill, "default:nyancat_rainbow")
	minetest.register_alias("pipeworks:storage_tank_"..fill, "default:nyancat_rainbow")
end
for _, data in ipairs({
	{name = "filter"},
	{name = "mese_filter"}
}) do
	minetest.register_alias("pipeworks:"..data.name, "default:nyancat_rainbow")
end
local cconnects = {{}, {1}, {1, 2}, {1, 3}, {1, 3, 5}, {1, 2, 3}, {1, 2, 3, 5}, {1, 2, 3, 4}, {1, 2, 3, 4, 5}, {1, 2, 3, 4, 5, 6}}
for index, connects in ipairs(cconnects) do
	minetest.register_alias("pipeworks:pipe_"..index.."_empty", "default:nyancat_rainbow")
	minetest.register_alias("pipeworks:pipe_"..index.."_loaded", "default:nyancat_rainbow")
end
for _, name_base in ipairs({"nodebreaker","deployer","dispenser"}) do
	for _, state in ipairs({ "off", "on" }) do
		minetest.register_alias("pipeworks:"..name_base.."_"..state, "default:nyancat_rainbow")
	end
end
minetest.register_alias("pipeworks:pipe_compatibility_empty", "default:nyancat_rainbow")
minetest.register_alias("pipeworks:pipe_compatibility_loaded", "default:nyancat_rainbow")
