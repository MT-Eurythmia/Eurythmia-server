-- drop_leaves: update leaves groups to make the default decay function drop them as entities (like apples)
-- Written to allow Pipeworks to collect them on Mynetest server.


-- Leaves to drop 
local leaves = {
	"default:leaves",
	"default:jungleleaves",
	"default:pine_needles",
	"default:acacia_leaves",
	"default:aspen_leaves"
}
-- Add leaves from farming_plus (useless because they don't yield themselves, it's a sapling or nothing)
if minetest.get_modpath("farming_plus") ~= nil then
	leaves[#leaves + 1] = "farming_plus:banana_leaves"
	leaves[#leaves + 1] = "farming_plus:cocoa_leaves"
end


for _, v in ipairs(leaves) do 
	local ndef = minetest.registered_nodes[v]
	if ndef == nil then 
		minetest.log("error", "[drop_leaves] Unknown leaves: " .. v)
	else
		if minetest.get_item_group(v, "leafdecay_drop") == 0 then
			-- Update the groups to make the default decay function drop the leaves 
			-- instead of making them disappear.
			ndef.groups.leafdecay_drop = 1
		end
	end
end
