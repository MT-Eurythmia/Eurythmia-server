minetest.register_privilege("remove_nodes", "Is able to use the /remove_nodes chatcommand")

minetest.register_chatcommand("remove_nodes", {
    description = "Remove nodes at a given list of positions",
    privs = {remove_nodes = true},
    params = "[extreme_position1] [extreme_position2] [pos...]",
    func = function(name, param)
        local str_pos_list = param:split(" ")
        local pos_max_1 = minetest.string_to_pos(str_pos_list[1])
        if not pos_max_1 then
          return false, "Malformed extreme position 1. Position format: (x,y,z)"
        end
        local pos_max_2 = minetest.string_to_pos(str_pos_list[2])
        if not pos_max_2 then
          return false, "Malformed extreme position 2. Position format: (x,y,z)"
        end

      	table.remove(str_pos_list, 2)
      	table.remove(str_pos_list, 1)

        local pos_list = {}
        for _, str_pos in ipairs(str_pos_list) do
          local pos = minetest.string_to_pos(str_pos)
          if not pos then
            return false, "Malformed position. Position format: (x,y,z)"
          end
          table.insert(pos_list, pos)
        end

        local manip = minetest.get_voxel_manip()
        local e1, e2 = manip:read_from_map(pos_max_1, pos_max_2)
        local area = VoxelArea:new{MinEdge=e1, MaxEdge=e2}
        local data = manip:get_data()

        local c_air = minetest.get_content_id("air")

        for _, pos in ipairs(pos_list) do
            data[area:indexp(pos)] = c_air
        end

        manip:set_data(data)
		manip:write_to_map()

        return true, "Removed nodes."
    end
})
