-----------------------------------------------------------------------------------------------
-- Fishing - crabman77 version - Bobber Shark
-- Rewrited from original Fishing - Mossmanikin's version - Bobber Shark 0.0.6
-- License (code & textures): 	WTFPL
-----------------------------------------------------------------------------------------------

-- bobber shark
minetest.register_node("fishing:bobber_shark_box", {
	drawtype = "nodebox",
	node_box = {
		type = "fixed",
		fixed = {
--			{ left, bottom, front,  right, top ,  back}
			{-8/16, -8/16,     0,  8/16,  8/16,     0}, -- feathers
			{-2/16, -8/16, -2/16,  2/16, -4/16,  2/16},	-- bobber
		}
	},
	tiles = {
		"fishing_bobber_top.png",
		"fishing_bobber_bottom.png",
		"fishing_bobber_shark.png",
		"fishing_bobber_shark.png",
		"fishing_bobber_shark.png",
		"fishing_bobber_shark.png^[transformFX"
	},
	groups = {not_in_creative_inventory=1},
})


local FISHING_BOBBER_SHARK_ENTITY={
	physical = true,
	timer = 0,
	visual = "wielditem",
	visual_size = {x=1/3, y=1/3, z=1/3},
	textures = {"fishing:bobber_shark_box"},
	--			   {left ,bottom, front, right,  top ,  back}
	collisionbox = {-3/16, -4/16, -3/16,  3/16, 4/16,  3/16},
	randomtime = 50,
	baitball = 0,
	prize = "",
	bait = "",
	owner = nil,
	old_pos = nil,
	old_pos2 = nil,


--  DESTROY BOBBER WHEN PUNCHING IT
	on_punch = function (self, puncher, time_from_last_punch, tool_capabilities, dir)
		if not puncher:is_player() then return end
		local player_name = puncher:get_player_name()
		if player_name ~= self.owner then return end
		if fishing_setting.settings["message"] == true then
			minetest.chat_send_player(player_name, fishing_setting.func.S("You didn't catch anything."), false)
		end
		if not fishing_setting.is_creative_mode then
			local inv = puncher:get_inventory()
			if inv:room_for_item("main", {name=self.bait, count=1, wear=0, metadata=""}) then
				inv:add_item("main", {name=self.bait, count=1, wear=0, metadata=""})
				if fishing_setting.settings["message"] == true then
					minetest.chat_send_player(player_name, fishing_setting.func.S("The bait is still there."), false)
				end
			end
		end
		-- make sound and remove bobber
		minetest.sound_play("fishing_bobber1", { pos = self.object:getpos(), gain = 0.5, })
		self.object:remove()
	end,


--	WHEN RIGHTCLICKING THE BOBBER THE FOLLOWING HAPPENS (CLICK AT THE RIGHT TIME WHILE HOLDING A FISHING POLE)
	on_rightclick = function (self, clicker)
		local item = clicker:get_wielded_item()
		local player_name = clicker:get_player_name()
		if not player_name or not self.owner then
			self.object:remove()
			return
		end
		local inv = clicker:get_inventory()
		local pos = self.object:getpos()
		local item_name = item:get_name()

		if string.find(item_name, "fishing:pole_") ~= nil then
			if player_name ~= self.owner then return end
			if self.prize ~= "" then
				if math.random(1, 100) <= fishing_setting.settings["escape_chance"] then -- fish escaped
					if fishing_setting.settings["message"] == true then
						minetest.chat_send_player(player_name, fishing_setting.func.S("Your fish escaped."), false)
						end
				else
					local name = self.prize[1]..":"..self.prize[2]
					local desc = self.prize[4]
					if fishing_setting.settings["message"] == true then
						minetest.chat_send_player(player_name, fishing_setting.func.S("You caught "..desc), false)
					end
					fishing_setting.func.add_to_trophies(clicker, self.prize[2], desc)
					local wear_value = fishing_setting.func.wear_value(self.prize[3])
					if inv:room_for_item("main", {name=name, count=1, wear=wear_value, metadata=""}) then
						inv:add_item("main", {name=name, count=1, wear=wear_value, metadata=""})
					else
						minetest.spawn_item(clicker:getpos(), {name=name, count=1, wear=wear_value, metadata=""})
					end
				end
			else
				if not fishing_setting.is_creative_mode then
					if inv:room_for_item("main", {name=self.bait, count=1, wear=0, metadata=""}) then
						inv:add_item("main", {name=self.bait, count=1, wear=0, metadata=""})
					end
				end
			end
			-- weither player has fishing pole or not
			minetest.sound_play("fishing_bobber1", { pos = self.object:getpos(), gain = 0.5, })
			self.object:remove()

		elseif item_name == "fishing:baitball_shark" then
			if not fishing_setting.is_creative_mode then
				inv:remove_item("main", "fishing:baitball_shark")
			end
			self.baitball = 20
			--addparticle
			minetest.add_particlespawner(30, 0.5,   -- for how long (?)             -- Particles on splash
				{x=pos.x,y=pos.y-0.0325,z=pos.z}, {x=pos.x,y=pos.y,z=pos.z}, -- position min, pos max
				{x=-2,y=-0.0325,z=-2}, {x=2,y=3,z=2}, -- velocity min, vel max
				{x=0,y=-3.8,z=0}, {x=0,y=-9.8,z=0},
				0.3, 1.2,
				0.25, 0.40,  -- min size, max size
				false, "fishing_particle_baitball_shark.png")
			-- add sound
			minetest.sound_play("fishing_baitball", {pos = self.object:getpos(), gain = 0.2, })
		end
	end,


-- AS SOON AS THE BOBBER IS PLACED IT WILL ACT LIKE
	on_step = function(self, dtime)
		local pos = self.object:getpos()
		--remove if no owner, no player, owner no in bobber_view_range
		if self.owner == nil then self.object:remove(); return end
		--remove if not node water
		local node = minetest.get_node_or_nil({x=pos.x, y=pos.y-0.5, z=pos.z})
		if not node or string.find(node.name, "water_source") == nil then
			if fishing_setting.settings["message"] == true then
				minetest.chat_send_player(self.owner, fishing_setting.func.S("Haha, Fishing is prohibited outside water!"))
			end
			self.object:remove()
			return
		end
		local player = minetest.get_player_by_name(self.owner)
		if not player then self.object:remove(); return end
		local p = player:getpos()
		local dist = ((p.x-pos.x)^2 + (p.y-pos.y)^2 + (p.z-pos.z)^2)^0.5
		if dist > fishing_setting.settings["bobber_view_range"] then
			minetest.sound_play("fishing_bobber1", {pos = self.object:getpos(),gain = 0.5,})
			self.object:remove()
			return
		end

		--rotate bobber
		if math.random(1, 4) == 1 then
			self.object:setyaw(self.object:getyaw()+((math.random(0,360)-180)/2880*math.pi))
		end

		self.timer = self.timer + 1
		if self.timer < self.randomtime then
			-- if fish or others items, move bobber to simulate fish on the line
			if self.prize ~= "" and math.random(1,3) == 1 then
				if self.old_pos2 == true then
					pos.y = pos.y-0.050
					self.object:moveto(pos, false)
					self.old_pos2 = false
				else
					pos.y = pos.y+0.050
					self.object:moveto(pos, false)
					self.old_pos2 = true
				end
			end
			return
		end

		--change item on line
		self.timer = 0
		if self.prize ~= "" and fishing_setting.have_true_fish and fishing_setting.prizes["true_fish"]["big"][self.prize[1]..":"..self.prize[2]] then
			minetest.add_entity({x=pos.x, y=pos.y-1, z=pos.z}, self.prize[1]..":"..self.prize[2])
		end
		self.prize = ""
		self.object:moveto(self.old_pos, false)
		--Once the fish are not hungry :), baitball increase hungry + 20%
		if math.random(1, 100) > fishing_setting.baits[self.bait]["hungry"] + self.baitball then
			--Fish not hungry !(
			self.randomtime = math.random(20,60)*10
			return
		end

		self.randomtime = math.random(1,5)*10
		local chance = math.random(1, 100)
		--if 1 you catch a treasure
		if fishing_setting.settings["treasure_enable"] and chance == 1 then
			if math.random(1, 100) <= fishing_setting.settings["treasure_chance"] then
				self.prize = fishing_setting.prizes["treasure"][math.random(1,#fishing_setting.prizes["treasure"])]
			end
		elseif chance <= fishing_setting.settings["fish_chance"] then
			if self.water_type and self.water_type == "sea" then
				self.prize = fishing_setting.prizes["sea"]["big"][math.random(1,#fishing_setting.prizes["sea"]["big"])]
			else
				self.prize = fishing_setting.prizes["rivers"]["big"][math.random(1,#fishing_setting.prizes["rivers"]["big"])]
			end

			-- to mobs_fish modpack
			if fishing_setting.have_true_fish then
				local objs = minetest.get_objects_inside_radius({x=pos.x, y=pos.y-2, z=pos.z}, 3)
				for _, obj in pairs(objs) do
					if obj:get_luaentity() ~= nil then
						local name = obj:get_luaentity().name
						if fishing_setting.prizes["true_fish"]["big"][name] then
							self.prize = fishing_setting.prizes["true_fish"]["big"][name]
							obj:remove()
							self.randomtime = math.random(3,7)*10
							break
						end
					end
				end
			end
		elseif math.random(1, 100) <= 10 then
			self.prize = fishing_setting.func.get_loot()
		end

		if self.prize ~= "" then
			pos.y = self.old_pos.y-0.140
			self.object:moveto(pos, false)
			minetest.sound_play("fishing_bobber1", {pos=pos,gain = 0.5,})
		end
	end,
}

minetest.register_entity("fishing:bobber_shark_entity", FISHING_BOBBER_SHARK_ENTITY)
