--[[
Cart: allow power rails to work without mesecons.
the new minetest_game/mods/carts or boost_cart work (optional dependency)
]]
minetest.override_item("carts:powerrail", {
  after_place_node = function(pos, placer, itemstack)
    minetest.get_meta(pos):set_string("cart_acceleration", "0.5")
  end,

  mesecons = {
    effector = {
      action_on = function(pos, node)
        return
      end,

      action_off = function(pos, node)
        return
      end
    }
  }
})

--[[
Override the brake rail so that it stops instantly (the : are used to override its definition)
--]]

carts:register_rail(":carts:brakerail", {
	description = "Brake rail",
	tiles = {
		"carts_rail_straight_brk.png", "carts_rail_curved_brk.png",
		"carts_rail_t_junction_brk.png", "carts_rail_crossing_brk.png"
	},
	groups = carts:get_rail_groups(),
}, {acceleration = -10000})
