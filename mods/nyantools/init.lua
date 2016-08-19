minetest.register_tool("nyantools:pick_nyan", {
	description = "Nyan Pickaxe",
	inventory_image = "nyantools_nyanpick.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 3,
		groupcaps = {
			cracky = {times = {[1] = 2.4, [2] = 1.0, [3] = 0.65}, uses = 150, maxlevel = 3},
			crumbly = {times = {[1] = 2.0, [2] = 0.9, [3] = 0.36}, uses = 150, maxlevel = 2},
		},
		damage_groups = {fleshy = 5},
	},
})

minetest.register_tool("nyantools:shovel_nyan", {
	description = "Nyan Shovel",
	inventory_image = "nyantools_nyanshovel.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 1,
		groupcaps = {
			crumbly = {times = {[1] = 1.65, [2] = 0.6, [3] = 0.32}, uses = 150, maxlevel = 3},
		},
		damage_groups = {fleshy = 4},
	},
})

minetest.register_tool("nyantools:axe_nyan", {
	description = "Nyan Axe",
	inventory_image = "nyantools_nyanaxe.png",
	tool_capabilities = {
		full_punch_interval = 1.2,
		max_drop_level = 1,
		groupcaps = {
			choppy = {times = {[1] = 2.2, [2] = 1.0, [3] = 0.55}, uses = 150, maxlevel = 3},
			snappy = {times = {[3] = 0.125}, uses = 0, maxlevel = 1},
		},
		damage_groups = {fleshy = 6},
	},
})

minetest.register_tool("nyantools:sword_nyan", {
	description = "Nyan Sword",
	inventory_image = "nyantools_nyansword.png",
	tool_capabilities = {
		full_punch_interval = 0.9,
		max_drop_level = 1,
		groupcaps = {
			snappy = {times = {[1] = 1.9, [2] = 0.85, [3] = 0.125}, uses = 150, maxlevel = 3},
		},
		damage_groups = {fleshy = 6},
	}
})


minetest.register_craft({
	output = "nyantools:pick_nyan",
	recipe = {
		{"default:nyancat", "default:nyancat", "default:nyancat"},
		{"", "group:stick", ""},
		{"", "group:stick", ""},
	}
})

minetest.register_craft({
	output = "nyantools:shovel_nyan",
	recipe = {
		{"default:nyancat"},
		{"group:stick"},
		{"group:stick"},
	}
})

minetest.register_craft({
	output = "nyantools:axe_nyan",
	recipe = {
		{"default:nyancat", "default:nyancat"},
		{"default:nyancat", "group:stick"},
		{"", "group:stick"},
	}
})

minetest.register_craft({
	output = "nyantools:axe_nyan",
	recipe = {
		{"default:nyancat", "default:nyancat"},
		{"group:stick", "default:nyancat"},
		{"group:stick", ""},
	}
})

minetest.register_craft({
	output = "nyantools:sword_nyan",
	recipe = {
		{"default:nyancat"},
		{"default:nyancat"},
		{"group:stick"},
	}
})
