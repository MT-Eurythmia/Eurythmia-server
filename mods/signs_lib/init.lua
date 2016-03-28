-- This mod provides the visible text on signs library used by Home Decor
-- and perhaps other mods at some point in the future.  Forked from thexyz's/
-- PilzAdam's original text-on-signs mod and rewritten by Vanessa Ezekowitz
-- and Diego Martinez

-- textpos = {
--		{ delta = {entity position for 0° yaw}, exact yaw expression }
--		{ delta = {entity position for 180° yaw}, exact yaw expression }
--		{ delta = {entity position for 270° yaw}, exact yaw expression }
--		{ delta = {entity position for 90° yaw}, exact yaw expression }
-- }

-- CWz's keyword interact mod uses this setting.
local current_keyword = minetest.setting_get("interact_keyword") or "iaccept"

signs_lib = {}
screwdriver = screwdriver or {}

signs_lib.wallmounted_rotate = function(pos, node, user, mode, new_param2)
	if mode ~= screwdriver.ROTATE_AXIS then return false end
	minetest.swap_node(pos, {name = node.name, param2 = (node.param2 + 1) % 6})
	for _, v in ipairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		local e = v:get_luaentity()
		if e and e.name == "signs:text" then
			v:remove()
		end
	end
	signs_lib.update_sign(pos)
	return true
end

signs_lib.modpath = minetest.get_modpath("signs_lib")

signs_lib.regular_wall_sign_model = {
	nodebox = {
		type = "wallmounted",
		wall_side =   { -0.5,    -0.25,   -0.4375, -0.4375,  0.375,  0.4375 },
		wall_bottom = { -0.4375, -0.5,    -0.25,    0.4375, -0.4375, 0.375 },
		wall_top =    { -0.4375,  0.4375, -0.375,   0.4375,  0.5,    0.25 }
	},
	textpos = {
		nil,
		nil,
		{delta = {x =  0.43,  y = 0.07, z =  0     }, yaw = math.pi / -2},
		{delta = {x = -0.43,  y = 0.07, z =  0     }, yaw = math.pi / 2},
		{delta = {x =  0,     y = 0.07, z =  0.43  }, yaw = 0},
		{delta = {x =  0,     y = 0.07, z = -0.43  }, yaw = math.pi},
	}
}

signs_lib.metal_wall_sign_model = {
	nodebox = {
		type = "fixed",
		fixed = {-0.4375, -0.25, 0.4375, 0.4375, 0.375, 0.5}
	},
	textpos = {
		{delta = {x =  0,     y = 0.07, z =  0.43  }, yaw = 0},
		{delta = {x =  0.43,  y = 0.07, z =  0     }, yaw = math.pi / -2},
		{delta = {x =  0,     y = 0.07, z = -0.43  }, yaw = math.pi},
		{delta = {x = -0.43,  y = 0.07, z =  0     }, yaw = math.pi / 2},
	}
}

signs_lib.yard_sign_model = {
	nodebox = {
		type = "fixed",
		fixed = {
				{-0.4375, -0.25, -0.0625, 0.4375, 0.375, 0},
				{-0.0625, -0.5, -0.0625, 0.0625, -0.1875, 0},
		}
	},
	textpos = {
		{delta = {x =  0,      y = 0.07, z = -0.068}, yaw = 0},
		{delta = {x = -0.068,  y = 0.07, z =  0    }, yaw = math.pi / -2},
		{delta = {x =  0,      y = 0.07, z =  0.068}, yaw = math.pi},
		{delta = {x =  0.068,  y = 0.07, z =  0    }, yaw = math.pi / 2},
	}
}

signs_lib.hanging_sign_model = {
	nodebox = {
		type = "fixed",
		fixed = {
				{-0.4375, -0.3125, -0.0625, 0.4375, 0.3125, 0},
				{-0.4375, 0.25, -0.03125, 0.4375, 0.5, -0.03125},
		}
	},
	textpos = {
		{delta = {x =  0,      y = -0.02, z = -0.063}, yaw = 0},
		{delta = {x = -0.063,  y = -0.02, z =  0    }, yaw = math.pi / -2},
		{delta = {x =  0,      y = -0.02, z =  0.063}, yaw = math.pi},
		{delta = {x =  0.063,  y = -0.02, z =  0    }, yaw = math.pi / 2},
	}
}

signs_lib.sign_post_model = {
	nodebox = {
		type = "fixed",
		fixed = {
				{-0.4375, -0.25, -0.1875, 0.4375, 0.375, -0.125},
				{-0.125, -0.5, -0.125, 0.125, 0.5, 0.125},
		}
	},
	textpos = {
		{delta = {x = 0,      y = 0.07, z = -0.188}, yaw = 0},
		{delta = {x = -0.188, y = 0.07, z = 0     }, yaw = math.pi / -2},
		{delta = {x = 0,      y = 0.07, z = 0.188 }, yaw = math.pi},
		{delta = {x = 0.188,  y = 0.07, z = 0     }, yaw = math.pi / 2},
	}
}

-- Boilerplate to support localized strings if intllib mod is installed.
local S = rawget(_G, "intllib") and intllib.Getter() or function(s) return s end
signs_lib.gettext = S

-- the list of standard sign nodes

signs_lib.sign_node_list = {
		"default:sign_wall_wood",
		"signs:sign_yard",
		"signs:sign_hanging",
		"signs:sign_wall_green",
		"signs:sign_wall_yellow",
		"signs:sign_wall_red",
		"signs:sign_wall_white_red",
		"signs:sign_wall_white_black",
		"signs:sign_wall_orange",
		"signs:sign_wall_blue",
		"signs:sign_wall_brown",
		"locked_sign:sign_wall_locked"
}

local default_sign, default_sign_image

-- Default sign was renamed in 0.4.14. Support both & old versions.
if minetest.registered_nodes["default:sign_wall_wood"] then
	default_sign = "default:sign_wall_wood"
	default_sign_image = "default_sign_wood.png"
else
	default_sign = "default:sign_wall"
	default_sign_image = "default_sign_wall.png"
end

--table copy

function signs_lib.table_copy(t)
    local nt = { };
    for k, v in pairs(t) do
        if type(v) == "table" then
            nt[k] = signs_lib.table_copy(v)
        else
            nt[k] = v
        end
    end
    return nt
end

-- infinite stacks

if minetest.get_modpath("unified_inventory") or not minetest.setting_getbool("creative_mode") then
	signs_lib.expect_infinite_stacks = false
else
	signs_lib.expect_infinite_stacks = true
end

-- CONSTANTS

local MP = minetest.get_modpath("signs_lib")

-- Used by `build_char_db' to locate the file.
local FONT_FMT = "%s/hdf_%02x.png"

-- Simple texture name for building text texture.
local FONT_FMT_SIMPLE = "hdf_%02x.png"

-- Path to the textures.
local TP = MP.."/textures"

local TEXT_SCALE = {x=0.8, y=0.5}

-- Lots of overkill here. KISS advocates, go away, shoo! ;) -- kaeza

local PNG_HDR = string.char(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)

-- Read the image size from a PNG file.
-- Returns image_w, image_h.
-- Only the LSB is read from each field!
local function read_image_size(filename)
	local f = io.open(filename, "rb")
	f:seek("set", 0x0)
	local hdr = f:read(8)
	if hdr ~= PNG_HDR then
		f:close()
		return
	end
	f:seek("set", 0x13)
	local ws = f:read(1)
	f:seek("set", 0x17)
	local hs = f:read(1)
	f:close()
	return ws:byte(), hs:byte()
end

-- Set by build_char_db()
local LINE_HEIGHT
local SIGN_WIDTH
local COLORBGW, COLORBGH

-- Size of the canvas, in characters.
-- Please note that CHARS_PER_LINE is multiplied by the average character
-- width to get the total width of the canvas, so for proportional fonts,
-- either more or fewer characters may fit on a line.
local CHARS_PER_LINE = 30
local NUMBER_OF_LINES = 6

-- 6 rows, max 80 chars per, plus a bit of fudge to
-- avoid excess trimming (e.g. due to color codes)

local MAX_INPUT_CHARS = 600

-- This holds the individual character widths.
-- Indexed by the actual character (e.g. charwidth["A"])
local charwidth

-- helper functions to trim sign text input/output

local function trim_input(text)
	return text:sub(1, math.min(MAX_INPUT_CHARS, text:len()))
end

local function build_char_db()

	charwidth = { }

	-- To calculate average char width.
	local total_width = 0
	local char_count = 0

	for c = 32, 126 do
		local w, h = read_image_size(FONT_FMT:format(TP, c))
		if w and h then
			local ch = string.char(c)
			charwidth[ch] = w
			total_width = total_width + w
			char_count = char_count + 1
		end
	end

	COLORBGW, COLORBGH = read_image_size(TP.."/slc_n.png")
	assert(COLORBGW and COLORBGH, "error reading bg dimensions")
	LINE_HEIGHT = COLORBGH

	-- XXX: Is there a better way to calc this?
	SIGN_WIDTH = math.floor((total_width / char_count) * CHARS_PER_LINE)

end

local sign_groups = {choppy=2, dig_immediate=2}

local fences_with_sign = { }

-- some local helper functions

local function split_lines_and_words_old(text)
	local lines = { }
	local line = { }
	if not text then return end
	for word in text:gmatch("%S+") do
		if word == "|" then
			table.insert(lines, line)
			if #lines >= NUMBER_OF_LINES then break end
			line = { }
		elseif word == "\\|" then
			table.insert(line, "|")
		else
			table.insert(line, word)
		end
	end
	table.insert(lines, line)
	return lines
end

local function split_lines_and_words(text)
	if not text then return end
	text = string.gsub(text, "@KEYWORD", current_keyword)
	local lines = { }
	for _, line in ipairs(text:split("\n")) do
		table.insert(lines, line:split(" "))
	end
	return lines
end

local math_max = math.max

local function fill_line(x, y, w, c)
	c = c or "0"
	local tex = { }
	for xx = 0, math.max(0, w), COLORBGW do
		table.insert(tex, (":%d,%d=slc_%s.png"):format(x + xx, y, c))
	end
	return table.concat(tex)
end

local function make_line_texture(line, lineno)

	local width = 0
	local maxw = 0

	local words = { }

	local cur_color = 0

	-- We check which chars are available here.
	for word_i, word in ipairs(line) do
		local chars = { }
		local ch_offs = 0
		local word_l = #word
		local i = 1
		while i <= word_l  do
			local c = word:sub(i, i)
			if c == "#" then
				local cc = tonumber(word:sub(i+1, i+1), 16)
				if cc then
					i = i + 1
					cur_color = cc
				end
			else
				local w = charwidth[c]
				if w then
					width = width + w + 1
					if width >= (SIGN_WIDTH - charwidth[" "]) then
						width = 0
					else
						maxw = math_max(width, maxw)
					end
					if #chars < MAX_INPUT_CHARS then
						table.insert(chars, {
							off=ch_offs,
							tex=FONT_FMT_SIMPLE:format(c:byte()),
							col=("%X"):format(cur_color),
						})
					end
					ch_offs = ch_offs + w
				end
			end
			i = i + 1
		end
		width = width + charwidth[" "] + 1
		maxw = math_max(width, maxw)
		table.insert(words, { chars=chars, w=ch_offs })
	end

	-- Okay, we actually build the "line texture" here.

	local texture = { }

	local start_xpos = math.floor((SIGN_WIDTH - maxw) / 2)

	local xpos = start_xpos
	local ypos = (LINE_HEIGHT * lineno)

	cur_color = nil

	for word_i, word in ipairs(words) do
		local xoffs = (xpos - start_xpos)
		if (xoffs > 0) and ((xoffs + word.w) > maxw) then
			table.insert(texture, fill_line(xpos, ypos, maxw, "n"))
			xpos = start_xpos
			ypos = ypos + LINE_HEIGHT
			lineno = lineno + 1
			if lineno >= NUMBER_OF_LINES then break end
			table.insert(texture, fill_line(xpos, ypos, maxw, cur_color))
		end
		for ch_i, ch in ipairs(word.chars) do
			if ch.col ~= cur_color then
				cur_color = ch.col
				table.insert(texture, fill_line(xpos + ch.off, ypos, maxw, cur_color))
			end
			table.insert(texture, (":%d,%d=%s"):format(xpos + ch.off, ypos, ch.tex))
		end
		table.insert(texture, (":%d,%d=hdf_20.png"):format(xpos + word.w, ypos))
		xpos = xpos + word.w + charwidth[" "]
		if xpos >= (SIGN_WIDTH + charwidth[" "]) then break end
	end

	table.insert(texture, fill_line(xpos, ypos, maxw, "n"))
	table.insert(texture, fill_line(start_xpos, ypos + LINE_HEIGHT, maxw, "n"))

	return table.concat(texture), lineno
end

local function make_sign_texture(lines)
	local texture = { ("[combine:%dx%d"):format(SIGN_WIDTH, LINE_HEIGHT * NUMBER_OF_LINES) }
	local lineno = 0
	for i = 1, #lines do
		if lineno >= NUMBER_OF_LINES then break end
		local linetex, ln = make_line_texture(lines[i], lineno)
		table.insert(texture, linetex)
		lineno = ln + 1
	end
	table.insert(texture, "^[makealpha:0,0,0")
	return table.concat(texture, "")
end

local function set_obj_text(obj, text, new)
	local split = new and split_lines_and_words or split_lines_and_words_old
	obj:set_properties({
		textures={make_sign_texture(split(text))},
		visual_size = TEXT_SCALE,
	})
end

signs_lib.construct_sign = function(pos, locked)
    local meta = minetest.get_meta(pos)
	meta:set_string(
		"formspec",
		"size[6,4]"..
		"textarea[0,-0.3;6.5,3;text;;${text}]"..
		"button_exit[2,3.4;2,1;ok;Write]"..
		"background[-0.5,-0.5;7,5;bg_signs_lib.jpg]")
	meta:set_string("infotext", "")
end

signs_lib.destruct_sign = function(pos)
    local objects = minetest.get_objects_inside_radius(pos, 0.5)
    for _, v in ipairs(objects) do
		local e = v:get_luaentity()
        if e and e.name == "signs:text" then
            v:remove()
        end
    end
end

local function make_infotext(text)
	text = trim_input(text)
	local lines = split_lines_and_words(text) or {}
	local lines2 = { }
	for _, line in ipairs(lines) do
		table.insert(lines2, (table.concat(line, " "):gsub("#[0-9a-fA-F]", ""):gsub("##", "#")))
	end
	return table.concat(lines2, "\n")
end

signs_lib.update_sign = function(pos, fields, owner)

	-- First, check if the interact keyword from CWz's mod is being set,
	-- or has been changed since the last restart...

	local meta = minetest.get_meta(pos)
	local stored_text = meta:get_string("text") or ""
	current_keyword = rawget(_G, "mki_interact_keyword") or current_keyword

	if fields then -- ...we're editing the sign.
		if fields.text and string.find(dump(fields.text), "@KEYWORD") then
			meta:set_string("keyword", current_keyword)
		else
			meta:set_string("keyword", nil)
		end
	elseif string.find(dump(stored_text), "@KEYWORD") then -- we need to check if the password is being set/changed

		local stored_keyword = meta:get_string("keyword")
		if stored_keyword and stored_keyword ~= "" and stored_keyword ~= current_keyword then
			signs_lib.destruct_sign(pos)
			meta:set_string("keyword", current_keyword)
			local ownstr = ""
			if owner then ownstr = "Locked sign, owned by "..owner.."\n" end
			meta:set_string("infotext", ownstr..string.gsub(make_infotext(stored_text), "@KEYWORD", current_keyword).." ")
		end
	end

	local new

	if fields then

		fields.text = trim_input(fields.text)

		local ownstr = ""
		if owner then ownstr = "Locked sign, owned by "..owner.."\n" end

		meta:set_string("infotext", ownstr..string.gsub(make_infotext(fields.text), "@KEYWORD", current_keyword).." ")
		meta:set_string("text", fields.text)
		
		meta:set_int("__signslib_new_format", 1)
		new = true
	else
		new = (meta:get_int("__signslib_new_format") ~= 0)
	end
	local text = meta:get_string("text")
	if text == nil then return end
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	local found
	for _, v in ipairs(objects) do
		local e = v:get_luaentity()
		if e and e.name == "signs:text" then
			if found then
				v:remove()
			else
				set_obj_text(v, text, new)
				found = true
			end
		end
	end
	if found then
		return
	end

	-- if there is no entity
	local sign_info
	local signnode = minetest.get_node(pos)
	if signnode.name == "signs:sign_yard" then
		sign_info = signs_lib.yard_sign_model.textpos[minetest.get_node(pos).param2 + 1]
	elseif signnode.name == "signs:sign_hanging" then
		sign_info = signs_lib.hanging_sign_model.textpos[minetest.get_node(pos).param2 + 1]
	elseif string.find(signnode.name, "sign_wall") then
		if signnode.name == default_sign
		  or signnode.name == "locked_sign:sign_wall_locked" then
			sign_info = signs_lib.regular_wall_sign_model.textpos[minetest.get_node(pos).param2 + 1]
		else
			sign_info = signs_lib.metal_wall_sign_model.textpos[minetest.get_node(pos).param2 + 1]
		end
	else -- ...it must be a sign on a fence post.
		sign_info = signs_lib.sign_post_model.textpos[minetest.get_node(pos).param2 + 1]
	end
	if sign_info == nil then
		return
	end
	local text = minetest.add_entity({x = pos.x + sign_info.delta.x,
										y = pos.y + sign_info.delta.y,
										z = pos.z + sign_info.delta.z}, "signs:text")
	text:setyaw(sign_info.yaw)
end

-- What kind of sign do we need to place, anyway?

function signs_lib.determine_sign_type(itemstack, placer, pointed_thing, locked)
	local name
	name = minetest.get_node(pointed_thing.under).name
	if fences_with_sign[name] then
		if minetest.is_protected(pointed_thing.under, placer:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.under,
				placer:get_player_name())
			return itemstack
		end
	else
		name = minetest.get_node(pointed_thing.above).name
		local def = minetest.registered_nodes[name]
		if not def.buildable_to then
			return itemstack
		end
		if minetest.is_protected(pointed_thing.above, placer:get_player_name()) then
			minetest.record_protection_violation(pointed_thing.above,
				placer:get_player_name())
			return itemstack
		end
	end

	local node=minetest.get_node(pointed_thing.under)

	if minetest.registered_nodes[node.name] and minetest.registered_nodes[node.name].on_rightclick then
		return minetest.registered_nodes[node.name].on_rightclick(pointed_thing.under, node, placer, itemstack)
	else
		local above = pointed_thing.above
		local under = pointed_thing.under
		local dir = {x = under.x - above.x,
					 y = under.y - above.y,
					 z = under.z - above.z}

		local wdir = minetest.dir_to_wallmounted(dir)

		local placer_pos = placer:getpos()
		if placer_pos then
			dir = {
				x = above.x - placer_pos.x,
				y = above.y - placer_pos.y,
				z = above.z - placer_pos.z
			}
		end

		local fdir = minetest.dir_to_facedir(dir)

		local pt_name = minetest.get_node(under).name
		local signname = itemstack:get_name()

		if fences_with_sign[pt_name] and signname == default_sign then
			minetest.add_node(under, {name = fences_with_sign[pt_name], param2 = fdir})
		elseif wdir == 0 and signname == default_sign then
			minetest.add_node(above, {name = "signs:sign_hanging", param2 = fdir})
		elseif wdir == 1 and signname == default_sign then
			minetest.add_node(above, {name = "signs:sign_yard", param2 = fdir})
		elseif signname ~= default_sign
		  and signname ~= "locked_sign:sign_wall_locked" then -- it's a metal wall sign.
			minetest.add_node(above, {name = signname, param2 = fdir})
		else -- it must be a default or locked wooden wall sign
			minetest.add_node(above, {name = signname, param2 = wdir }) -- note it's wallmounted here!
			if locked then
				local meta = minetest.get_meta(above)
				local owner = placer:get_player_name()
				meta:set_string("owner", owner)
			end
		end

		if not signs_lib.expect_infinite_stacks then
			itemstack:take_item()
		end
		return itemstack
	end
end

function signs_lib.receive_fields(pos, formname, fields, sender, lock)
	if minetest.is_protected(pos, sender:get_player_name()) then
		minetest.record_protection_violation(pos,
			sender:get_player_name())
		return
	end
	local lockstr = lock and "locked " or ""
	if fields and fields.text and fields.ok then
		minetest.log("action", S("%s wrote \"%s\" to "..lockstr.."sign at %s"):format(
			(sender:get_player_name() or ""),
			fields.text,
			minetest.pos_to_string(pos)
		))
		if lock then
			signs_lib.update_sign(pos, fields, sender:get_player_name())
		else
			signs_lib.update_sign(pos, fields)
		end
	end
end

minetest.register_node(":"..default_sign, {
	description = S("Sign"),
	inventory_image = default_sign_image,
	wield_image = default_sign_image,
	node_placement_prediction = "",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = signs_lib.regular_wall_sign_model.nodebox,
	tiles = {"signs_wall_sign.png"},
	groups = sign_groups,

	on_place = function(itemstack, placer, pointed_thing)
		return signs_lib.determine_sign_type(itemstack, placer, pointed_thing)
	end,
	on_construct = function(pos)
		signs_lib.construct_sign(pos)
	end,
	on_destruct = function(pos)
		signs_lib.destruct_sign(pos)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		signs_lib.receive_fields(pos, formname, fields, sender)
	end,
	on_punch = function(pos, node, puncher)
		signs_lib.update_sign(pos)
	end,
	on_rotate = signs_lib.wallmounted_rotate
})

minetest.register_node(":signs:sign_yard", {
    paramtype = "light",
	sunlight_propagates = true,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = signs_lib.yard_sign_model.nodebox,
	selection_box = {
		type = "fixed",
		fixed = {-0.4375, -0.5, -0.0625, 0.4375, 0.375, 0}
	},
    tiles = {"signs_top.png", "signs_bottom.png", "signs_side.png", "signs_side.png", "signs_back.png", "signs_front.png"},
    groups = {choppy=2, dig_immediate=2},
    drop = default_sign,

    on_construct = function(pos)
        signs_lib.construct_sign(pos)
    end,
    on_destruct = function(pos)
        signs_lib.destruct_sign(pos)
    end,
	on_receive_fields = function(pos, formname, fields, sender)
		signs_lib.receive_fields(pos, formname, fields, sender)
	end,
	on_punch = function(pos, node, puncher)
		signs_lib.update_sign(pos)
	end,
})

minetest.register_node(":signs:sign_hanging", {
    paramtype = "light",
	sunlight_propagates = true,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = signs_lib.hanging_sign_model.nodebox,
    selection_box = {
		type = "fixed",
		fixed = {-0.45, -0.275, -0.049, 0.45, 0.5, 0.049}
	},
    tiles = {
		"signs_hanging_top.png",
		"signs_hanging_bottom.png",
		"signs_hanging_side.png",
		"signs_hanging_side.png",
		"signs_hanging_back.png",
		"signs_hanging_front.png"
	},
    groups = {choppy=2, dig_immediate=2},
    drop = default_sign,

    on_construct = function(pos)
        signs_lib.construct_sign(pos)
    end,
    on_destruct = function(pos)
        signs_lib.destruct_sign(pos)
    end,
	on_receive_fields = function(pos, formname, fields, sender)
		signs_lib.receive_fields(pos, formname, fields, sender)
	end,
	on_punch = function(pos, node, puncher)
		signs_lib.update_sign(pos)
	end,
})

minetest.register_node(":signs:sign_post", {
    paramtype = "light",
	sunlight_propagates = true,
    paramtype2 = "facedir",
    drawtype = "nodebox",
    node_box = signs_lib.sign_post_model.nodebox,
    tiles = {
		"signs_post_top.png",
		"signs_post_bottom.png",
		"signs_post_side.png",
		"signs_post_side.png",
		"signs_post_back.png",
		"signs_post_front.png",
	},
    groups = {choppy=2, dig_immediate=2},
    drop = {
		max_items = 2,
		items = {
			{ items = { default_sign }},
			{ items = { "default:fence_wood" }},
		},
    },
})

-- Locked wall sign

minetest.register_privilege("sign_editor", "Can edit all locked signs")

minetest.register_node(":locked_sign:sign_wall_locked", {
	description = S("Sign"),
	inventory_image = "signs_locked_inv.png",
	wield_image = "signs_locked_inv.png",
	node_placement_prediction = "",
	sunlight_propagates = true,
	paramtype = "light",
	paramtype2 = "wallmounted",
	drawtype = "nodebox",
	node_box = signs_lib.regular_wall_sign_model.nodebox,
	tiles = { "signs_wall_sign_locked.png" },
	groups = sign_groups,
	on_place = function(itemstack, placer, pointed_thing)
		return signs_lib.determine_sign_type(itemstack, placer, pointed_thing, true)
	end,
	on_construct = function(pos)
		signs_lib.construct_sign(pos, true)
	end,
	on_destruct = function(pos)
		signs_lib.destruct_sign(pos)
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local pname = sender:get_player_name() or ""
		if pname ~= owner and pname ~= minetest.setting_get("name")
		  and not minetest.check_player_privs(pname, {sign_editor=true}) then
			return
		end
		signs_lib.receive_fields(pos, formname, fields, sender, true)
	end,
	on_punch = function(pos, node, puncher)
		signs_lib.update_sign(pos)
	end,
	can_dig = function(pos, player)
		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local pname = player:get_player_name()
		return pname == owner or pname == minetest.setting_get("name")
			or minetest.check_player_privs(pname, {sign_editor=true})
	end,
	on_rotate = signs_lib.wallmounted_rotate
})

-- metal, colored signs

local sign_colors = { "green", "yellow", "red", "white_red", "white_black", "orange", "blue", "brown" }

for _, color in ipairs(sign_colors) do
	minetest.register_node(":signs:sign_wall_"..color, {
		description = S("Sign ("..color..", metal)"),
		inventory_image = "signs_"..color.."_inv.png",
		wield_image = "signs_"..color.."_inv.png",
		node_placement_prediction = "",
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "facedir",
		drawtype = "nodebox",
		node_box = signs_lib.metal_wall_sign_model.nodebox,
		tiles = {
			"signs_metal_tb.png",
			"signs_metal_tb.png",
			"signs_metal_sides.png",
			"signs_metal_sides.png",
			"signs_metal_back.png",
			"signs_"..color.."_front.png"
		},
		groups = sign_groups,
		on_place = function(itemstack, placer, pointed_thing)
			return signs_lib.determine_sign_type(itemstack, placer, pointed_thing)
		end,
		on_construct = function(pos)
			signs_lib.construct_sign(pos)
		end,
		on_destruct = function(pos)
			signs_lib.destruct_sign(pos)
		end,
		on_receive_fields = function(pos, formname, fields, sender)
			signs_lib.receive_fields(pos, formname, fields, sender)
		end,
		on_punch = function(pos, node, puncher)
			signs_lib.update_sign(pos)
		end,
	})
end

local signs_text_on_activate

signs_text_on_activate = function(self)
	local meta = minetest.get_meta(self.object:getpos())
	local text = meta:get_string("text")
	local new = (meta:get_int("__signslib_new_format") ~= 0)
	if text then
		text = trim_input(text)
		set_obj_text(self.object, text, new)
	end
end

minetest.register_entity(":signs:text", {
    collisionbox = { 0, 0, 0, 0, 0, 0 },
    visual = "upright_sprite",
    textures = {},

	on_activate = signs_text_on_activate,
})

-- And the good stuff here! :-)

function signs_lib.register_fence_with_sign(fencename, fencewithsignname)
    local def = minetest.registered_nodes[fencename]
    local def_sign = minetest.registered_nodes[fencewithsignname]
    if not (def and def_sign) then
        minetest.log("warning", "[signs_lib] Attempt to register unknown node as fence")
        return
    end
    def = signs_lib.table_copy(def)
    def_sign = signs_lib.table_copy(def_sign)
    fences_with_sign[fencename] = fencewithsignname

    def_sign.on_place = function(itemstack, placer, pointed_thing, ...)
		local node_above = minetest.get_node_or_nil(pointed_thing.above)
		local node_under = minetest.get_node_or_nil(pointed_thing.under)
		local def_above = node_above and minetest.registered_nodes[node_above.name]
		local def_under = node_under and minetest.registered_nodes[node_under.name]
		local fdir = minetest.dir_to_facedir(placer:get_look_dir())
		local playername = placer:get_player_name()

		if minetest.is_protected(pointed_thing.under, playername) then
			minetest.record_protection_violation(pointed_thing.under, playername)
			return itemstack
		end

		if minetest.is_protected(pointed_thing.above, playername) then
			minetest.record_protection_violation(pointed_thing.above, playername)
			return itemstack
		end

		if def_under and def_under.on_rightclick then
			return def_under.on_rightclick(pointed_thing.under, node_under, placer, itemstack) or itemstack
		elseif def_under and def_under.buildable_to then
			minetest.add_node(pointed_thing.under, {name = fencename, param2 = fdir})
			if not signs_lib.expect_infinite_stacks then
				itemstack:take_item()
			end
			placer:set_wielded_item(itemstack)
		elseif def_above and def_above.buildable_to then
			minetest.add_node(pointed_thing.above, {name = fencename, param2 = fdir})
			if not signs_lib.expect_infinite_stacks then
				itemstack:take_item()
			end
			placer:set_wielded_item(itemstack)
		end
		return itemstack
	end
	def_sign.on_construct = function(pos, ...)
		signs_lib.construct_sign(pos)
	end
	def_sign.on_destruct = function(pos, ...)
		signs_lib.destruct_sign(pos)
	end
	def_sign.on_receive_fields = function(pos, formname, fields, sender)
		signs_lib.receive_fields(pos, formname, fields, sender)
	end
	def_sign.on_punch = function(pos, node, puncher, ...)
		signs_lib.update_sign(pos)
	end
	local fencename = fencename
	def_sign.after_dig_node = function(pos, node, ...)
	    node.name = fencename
	    minetest.add_node(pos, node)
	end
    def_sign.drop = default_sign
	minetest.register_node(":"..fencename, def)
	minetest.register_node(":"..fencewithsignname, def_sign)
	table.insert(signs_lib.sign_node_list, fencewithsignname)
	minetest.log("debug", S("Registered %s and %s"):format(fencename, fencewithsignname))
end

build_char_db()

minetest.register_alias("homedecor:fence_wood_with_sign", "signs:sign_post")
minetest.register_alias("sign_wall_locked", "locked_sign:sign_wall_locked")

signs_lib.register_fence_with_sign("default:fence_wood", "signs:sign_post")

-- restore signs' text after /clearobjects and the like

minetest.register_abm({
	nodenames = signs_lib.sign_node_list,
	interval = 15,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		signs_lib.update_sign(pos)
	end
})

-- locked sign

minetest.register_craft({
	output = "locked_sign:sign_wall_locked",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "group:wood", "default:steel_ingot"},
		{"", "group:stick", ""},
	}
})

--Alternate recipe.

minetest.register_craft({
    	output = "locked_sign:sign_wall_locked",
    	recipe = {
        	{default_sign},
        	{"default:steel_ingot"},
    },
})

-- craft recipes for the metal signs

minetest.register_craft( {
        output = "signs:sign_wall_green 4",
        recipe = {
			{ "dye:dark_green", "dye:white", "dye:dark_green" },
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_green 2",
        recipe = {
			{ "dye:dark_green", "dye:white", "dye:dark_green" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_yellow 4",
        recipe = {
			{ "dye:yellow", "dye:black", "dye:yellow" },
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_yellow 2",
        recipe = {
			{ "dye:yellow", "dye:black", "dye:yellow" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_red 4",
        recipe = {
			{ "dye:red", "dye:white", "dye:red" },
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_red 2",
        recipe = {
			{ "dye:red", "dye:white", "dye:red" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_white_red 4",
        recipe = {
			{ "dye:white", "dye:red", "dye:white" },
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_white_red 2",
        recipe = {
			{ "dye:white", "dye:red", "dye:white" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_white_black 4",
        recipe = {
			{ "dye:white", "dye:black", "dye:white" },
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_white_black 2",
        recipe = {
			{ "dye:white", "dye:black", "dye:white" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_orange 4",
        recipe = {
			{ "dye:orange", "dye:black", "dye:orange" },
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_orange 2",
        recipe = {
			{ "dye:orange", "dye:black", "dye:orange" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_blue 4",
        recipe = {
			{ "dye:blue", "dye:white", "dye:blue" },
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_blue 2",
        recipe = {
			{ "dye:blue", "dye:white", "dye:blue" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_brown 4",
        recipe = {
			{ "dye:brown", "dye:white", "dye:brown" },
			{ "default:steel_ingot", "default:steel_ingot", "default:steel_ingot" }
        },
})

minetest.register_craft( {
        output = "signs:sign_wall_brown 2",
        recipe = {
			{ "dye:brown", "dye:white", "dye:brown" },
			{ "steel:sheet_metal", "steel:sheet_metal", "steel:sheet_metal" }
        },
})

if minetest.setting_get("log_mods") then
	minetest.log("action", S("signs loaded"))
end
