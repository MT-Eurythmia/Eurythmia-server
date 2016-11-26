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
	output = "default:dirt_with_dry_grass",
	type = "shapeless",
	recipe = {"default:dirt", "default:dry_grass_1"}
})

minetest.register_craft({
	output = "default:dirt_with_grass",
	type = "shapeless",
	recipe = {"default:dirt", "default:grass_1"}
})

minetest.register_craft({
	output = "bucket:bucket_river_water",
	type = "cooking",
	cooktime = 5,
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
