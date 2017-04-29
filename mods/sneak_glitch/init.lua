--[[ Sneak ladder and jump 2017-04-20. Commit 58c083f305
In the new player movement code, the replications of sneak ladder and 2 node sneak jump
are an option which is controlled [server-side] by the 'sneak_glitch' physics override,
the option is now disabled by default.
To enable for all players use a mod with this code:
--]]
minetest.register_on_joinplayer(function(player)
   local override_table = player:get_physics_override()
   override_table.sneak_glitch = true
   player:set_physics_override(override_table)
end)
