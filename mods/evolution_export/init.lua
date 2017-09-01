local mod_storage = minetest.get_mod_storage()

minetest.register_privilege("export", "Can mark areas as needed to be exported for Eurythmia Evolution")

minetest.register_chatcommand("to_export", {
	params = "<area_name>",
	description = "Mark a WorldEdit area as a to-export area",
	privs = {export = true},
	func = function(name, param)
		if param == "" then
			return false, "Please give a name to the area."
		end
		if mod_storage:get_string(param) ~= "" then
			return false, "An area with the same name is already marked. Please give a different name of remove that area."
		end

		local pos1, pos2
		do
			local we_pos1, we_pos2 = worldedit.pos1[name], worldedit.pos2[name]
			if not we_pos1 or not we_pos2 then
				return false, "No region selected"
			end

			pos1 = {x = math.min(we_pos1.x, we_pos2.x), y = math.min(we_pos1.y, we_pos2.y), z = math.min(we_pos1.z, we_pos2.z)}
			pos2 = {x = math.max(we_pos1.x, we_pos2.x), y = math.max(we_pos1.y, we_pos2.y), z = math.max(we_pos1.z, we_pos2.z)}
		end

		mod_storage:set_string(param, minetest.serialize({pos1, pos2}))
		return true, "Area from pos " .. minetest.pos_to_string(pos1) .. " to " .. minetest.pos_to_string(pos2) .. " successfully added as '" .. param .. "'."
	end
})

minetest.register_chatcommand("remove_export", {
	params = "<area_name>",
	description = "Remove a to-export area",
	privs = {export = true},
	func = function(name, param)
		if param == "" then
			return false, "Please provide an area name."
		end
		if mod_storage:get_string(param) == "" then
			return false, "No area with such name exists."
		end
		mod_storage:set_string(param, "")
		return true, "Successfully removed area '" .. param .. "'."
	end
})
