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

-- sand <-> desert_sand
minetest.register_craft({
	output = "default:sand",
	recipe = {
		{"default:desert_sand"},
	}
})
minetest.register_craft({
	output = "default:desert_sand",
	recipe = {
		{"default:sand"},
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
	output = "default:dirt_with_dry_grass 2",
	type = "shapeless",
	recipe = {"default:dirt", "default:dirt"}
})

minetest.register_craft({
	output = "bucket:bucket_river_water",
	type = "cooking",
	cooktime = 5,
	recipe = "bucket:bucket_water"
})

