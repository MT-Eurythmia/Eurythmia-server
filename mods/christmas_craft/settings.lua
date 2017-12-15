

print (" ---- Overrider christmas_craft = true! ---- ")

local dirttiles = {"snow.png", "default_dirt.png", {name = "default_dirt.png^grass_w_snow_side.png", tileable_vertical = false}}
local sandtiles = {"snow.png", "default_sand.png", {name = "default_sand.png^default_snow_side.png", tileable_vertical = false}}
local desertsandtiles = {"snow.png", "default_desert_sand.png", {name = "default_desert_sand.png^default_snow_side.png", tileable_vertical = false}} 
local snowballdrop = {items = {'default:snow'}, rarity = 0}

local add_drop = function (def)
	if type(def.drop) == "table" then
		if def.drop.max_items then
			def.drop.max_items = def.drop.max_items + 1
		end
		table.insert(def.drop.items, snowballdrop)
	elseif type(def.drop) == "string" then
		def.drop = {
			items = {
				{items = {def.drop}, rarity = 0},
				snowballdrop
			}
		}
	else
		def.drop = {
			items = {
				snowballdrop
			}
		}
	end
end

local dirt_with_grass = minetest.registered_items["default:dirt_with_grass"]
minetest.override_item("default:dirt_with_grass", {tiles = dirttiles})
add_drop(dirt_with_grass)

local dirt_with_dry_grass = minetest.registered_items["default:dirt_with_dry_grass"]
minetest.override_item("default:dirt_with_dry_grass", {tiles = dirttiles})
add_drop(dirt_with_dry_grass)

local sand = minetest.registered_items["default:sand"]
minetest.override_item("default:sand", {tiles = sandtiles})
add_drop(sand)

local desert_sand = minetest.registered_items["default:desert_sand"]
minetest.override_item("default:desert_sand", {tiles = desertsandtiles})
add_drop(sand)

local nodebox = {
	type = "fixed",
	fixed = {
		{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	}
}
local leavesoverride = {
	drawtype = "nodebox",
	visual_scale = 1,
	tiles = {"snow.png", "christmas_craft_leaves_top.png", "christmas_craft_leaves_side.png"},
	paramtype = "light",
	node_box = nodebox,
	selection_box = nodebox
}

-- Replace leaves
minetest.override_item("default:leaves", leavesoverride)

-- Replace jungleleaves
minetest.override_item("default:jungleleaves", leavesoverride)

-- Replace aspen, pine and acacia leaves as well
minetest.override_item("default:aspen_leaves", leavesoverride)
minetest.override_item("default:pine_needles", leavesoverride)
minetest.override_item("default:acacia_leaves", leavesoverride)

-- Replace grass
for i=1,5 do
	minetest.override_item("default:grass_" .. i, {tiles = {"christmas_grass_"..i..".png"}})
end

-- Replace junglegrass
minetest.override_item("default:junglegrass", {tiles = {"christmas_junglegrass.png"}})


-- Replace youngtrees
if minetest.registered_items["youngtrees:youngtree_top"] then
	minetest.override_item("youngtrees:youngtree_top", {tiles = {"christmas_youngtree16xa.png"}})
	minetest.override_item("youngtrees:youngtree_middle", {tiles = {"christmas_youngtree16xb.png"}})
end

-- Replace woodsoils
if minetest.registered_items["woodsoils:grass_with_leaves_1"] then
	minetest.override_item("woodsoils:grass_with_leaves_1", {tiles = {"snow.png", "default_dirt.png", "default_dirt.png^grass_w_snow_side.png"}})
	add_drop(minetest.registered_items["woodsoils:grass_with_leaves_1"])
end

if minetest.registered_items["woodsoils:grass_with_leaves_2"] then
	minetest.override_item("woodsoils:grass_with_leaves_2", {tiles = {"snow.png", "default_dirt.png", "default_dirt.png^grass_w_snow_side.png"}})
	add_drop(minetest.registered_items["woodsoils:grass_with_leaves_2"])
end

if minetest.registered_items["woodsoils:dirt_with_leaves_1"] then
	minetest.override_item("woodsoils:dirt_with_leaves_1", {tiles = {"snow.png", "default_dirt.png", "default_dirt.png^grass_w_snow_side.png^woodsoils_ground_cover_side.png"}})
	add_drop(minetest.registered_items["woodsoils:dirt_with_leaves_1"])
end

if minetest.registered_items["woodsoils:dirt_with_leaves_2"] then
	minetest.override_item("woodsoils:dirt_with_leaves_2", {tiles = {"snow.png", "default_dirt.png", "default_dirt.png^grass_w_snow_side.png^woodsoils_ground_cover_side.png"}})
	add_drop(minetest.registered_items["woodsoils:dirt_with_leaves_2"])
end


print (" ---- Overrider christmas_craft [OK] ---- ")
