local toggle_timer = function (pos, restart)
	local timer = minetest.get_node_timer(pos)
	local meta = minetest.get_meta(pos)
	if timer:is_started() and not restart then
		timer:stop()
	else
		timer:start(tonumber(meta:get_int("interval")))
	end
end

local on_timer = function (pos)
	local node = minetest.get_node(pos)
	if(mesecon.flipstate(pos, node) == "on") then
		mesecon.receptor_on(pos)
	else
		mesecon.receptor_off(pos)
	end
	toggle_timer(pos, false)
end

mesecon.register_node("moremesecons_adjustable_blinkyplant:adjustable_blinky_plant", {
	description="Adjustable Blinky Plant",
	drawtype = "plantlike",
	inventory_image = "moremesecons_blinky_plant_off.png",
	paramtype = "light",
	walkable = false,
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.3, -0.5, -0.3, 0.3, -0.5+0.7, 0.3},
	},
	on_timer = on_timer,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
   		meta:set_string("formspec", "field[interval;interval;${interval}]")
   		toggle_timer(pos, true)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		meta:set_string("interval", fields.interval)
		toggle_timer(pos, true)
	end,
},{
	tiles = {"moremesecons_blinky_plant_off.png"},
	groups = {dig_immediate=3},
	mesecons = {receptor = { state = mesecon.state.off }}
},{
	tiles = {"moremesecons_blinky_plant_on.png"},
	groups = {dig_immediate=3, not_in_creative_inventory=1},
	mesecons = {receptor = { state = mesecon.state.on }},
})


minetest.register_craft({
	output = "moremesecons_adjustable_blinkyplant:adjustable_blinky_plant_off 1",
	recipe = {	{"mesecons_blinkyplant:blinky_plant_off"},
			{"default:mese_crystal_fragment"},}
})
