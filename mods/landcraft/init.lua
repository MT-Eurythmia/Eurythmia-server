-- cobble -> gravel -> sand
minetest.register_craft({
	output = "default:gravel",
	recipe = {
		{"default:cobble"},
	}
})
minetest.register_craft({
	output = "default:sand",
	recipe = {
		{"default:gravel"},
	}
})

-- sand --> desert_sand --> silver_sand --> sand
minetest.register_craft({
	output = "default:desert_sand",
	recipe = {
		{"default:sand"},
	}
})
minetest.register_craft({
	output = "default:silver_sand",
	recipe = {
		{"default:desert_sand"},
	}
})
minetest.register_craft({
	output = "default:sand",
	recipe = {
		{"default:silver_sand"},
	}
})

minetest.register_craft({
	output = "default:desert_cobble 2",
	type = "shapeless",
	recipe = {"default:cobble", "default:desert_sand"}
})

-- gravel -> dirt
minetest.register_craft({
	output = "default:dirt 4",
	type = "shapeless",
	recipe = {"default:gravel", "default:gravel", "default:gravel", "default:gravel"}
})

-- Otherwise uncraftable landscape blocks
minetest.register_craft({
	output = "default:dirt_with_dry_grass 6",
	recipe = {
		{"", "default:dry_grass_1", ""},
		{"default:dirt", "default:dirt", "default:dirt"},
		{"default:dirt", "default:dirt", "default:dirt"},
	}
})

minetest.register_craft({
	output = "default:dirt_with_grass 6",
	recipe = {
		{"", "default:grass_1", ""},
		{"default:dirt", "default:dirt", "default:dirt"},
		{"default:dirt", "default:dirt", "default:dirt"},
	}
})

minetest.register_craft({
	output = "default:dirt_with_rainforest_litter 6",
	recipe = {
		{"", "default:jungleleaves", ""},
		{"default:dirt", "default:dirt", "default:dirt"},
		{"default:dirt", "default:dirt", "default:dirt"},
	}
})

minetest.register_craft({
	output = "bucket:bucket_river_water",
	type = "cooking",
	recipe = "bucket:bucket_water"
})

-- clay
minetest.register_craft({
	output = "default:clay 2",
	type = "shapeless",
	recipe = {"default:cobble", "default:dirt"}
})

-- Ice and snow
minetest.register_craft({
	output = "default:ice 3",
	-- The recipe is an ice skate
	recipe = {
		{"default:cobble", "", ""},
		{"", "default:cobble", "default:cobble"},
	}
})
minetest.register_craft({
	output = "default:snowblock 6",
	-- The recipe is an ice skate on ice
	recipe = {
		{"default:cobble", "", ""},
		{"", "default:cobble", "default:cobble"},
		{"default:ice", "default:ice", "default:ice"},
	}
})

-- saplings
minetest.register_craft({
	output = "default:sapling",
	recipe = {
		{"", "default:leaves", ""},
		{"default:leaves", "group:stick", "default:leaves"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "default:junglesapling",
	recipe = {
		{"", "default:jungleleaves", ""},
		{"default:jungleleaves", "group:stick", "default:jungleleaves"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "default:pine_sapling",
	recipe = {
		{"", "default:pine_needles", ""},
		{"default:pine_needles", "group:stick", "default:pine_needles"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "default:acacia_sapling",
	recipe = {
		{"", "default:acacia_leaves", ""},
		{"default:acacia_leaves", "group:stick", "default:acacia_leaves"},
		{"", "group:stick", ""},
	}
})
minetest.register_craft({
	output = "default:aspen_sapling",
	recipe = {
		{"", "default:aspen_leaves", ""},
		{"default:aspen_leaves", "group:stick", "default:aspen_leaves"},
		{"", "group:stick", ""},
	}
})

-- Bushes
minetest.register_craft({
	output = "default:bush_stem 4",
	recipe = {
		{"default:sapling"},
		{"default:tree"},
	}
})
minetest.register_craft({
	output = "default:acacia_bush_stem 4",
	recipe = {
		{"default:acacia_sapling"},
		{"default:acacia_tree"},
	}
})
minetest.register_craft({
	output = "default:bush_leaves 6",
	recipe = {
		{"default:leaves", "default:leaves", "default:leaves"},
		{"default:leaves", "default:leaves", "default:leaves"},
		{"", "default:bush_stem", ""},
	}
})
minetest.register_craft({
	output = "default:acacia_bush_leaves 6",
	recipe = {
		{"default:acacia_leaves", "default:acacia_leaves", "default:acacia_leaves"},
		{"default:acacia_leaves", "default:acacia_leaves", "default:acacia_leaves"},
		{"", "default:acacia_bush_stem", ""},
	}
})


-- Grasses
minetest.register_craft({
	output = "default:dry_grass_1",
	recipe = {
		{"default:grass_1"}
	}
})

minetest.register_craft({
	output = "default:dry_shrub",
	recipe = {
		{"default:dry_grass_1"}
	}
})

-- Corals
minetest.register_craft({
	output = "default:coral_skeleton 5",
	recipe = {
		{"default:cobble", "group:sapling", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"},
	}
})
minetest.register_craft({
	output = "default:coral_brown 5",
	recipe = {
		{"", "dye:brown", ""},
		{"default:cobble", "group:sapling", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"},
	}
})
minetest.register_craft({
	output = "default:coral_orange 5",
	recipe = {
		{"", "dye:orange", ""},
		{"default:cobble", "group:sapling", "default:cobble"},
		{"default:cobble", "default:cobble", "default:cobble"},
	}
})
