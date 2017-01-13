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
