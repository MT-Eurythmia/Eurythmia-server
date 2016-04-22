
minetest.register_craftitem("lavasuit:lavasuit", {
    description = "Lava Suit";
    groups = {};
    inventory_image = "lavasuit_lavasuit.png";
    stack_max = 1;
});

minetest.register_craftitem("lavasuit:watersuit", {
    description = "Water Suit";
    groups = {};
    inventory_image = "lavasuit_watersuit.png";
    stack_max = 1;
});

minetest.register_craftitem("lavasuit:energy", {
    description = "Lava Suit Energy";
    groups = {};
    inventory_image = "lavasuit_energy.png";
    stack_max = 10;
});

minetest.register_craft({
    output = 'lavasuit:lavasuit';
    recipe = {
        { '', 'default:bucket_empty', '' },
        { 'default:mese', 'default:mese', 'default:mese' },
        { '', 'default:mese', '' },
    };
});

minetest.register_craft({
    output = 'lavasuit:watersuit';
    recipe = {
        { '', 'default:bucket_water', '' },
        { '', 'default:mese', '' },
        { '', 'default:mese', '' },
    };
});

minetest.register_craft({
    output = 'lavasuit:energy 25';
    recipe = {
        { '', 'bucket:bucket_lava', '' },
        { '', 'bucket:bucket_lava', '' },
        { '', 'bucket:bucket_lava', '' },
    };
    replacements = {
        { 'bucket:bucket_lava', 'bucket:bucket_empty' },
        { 'bucket:bucket_lava', 'bucket:bucket_empty' },
        { 'bucket:bucket_lava', 'bucket:bucket_empty' },
    }
});

local players = { };

local INTERVAL_LAVA = 0.5;
local INTERVAL_WATER = 4;

local dtime_count_lava = 0;
local dtime_count_water = 0;

minetest.register_globalstep(function ( dtime )
    dtime_count_lava = dtime_count_lava + dtime;
    dtime_count_water = dtime_count_water + dtime;
    
    if (dtime_count_lava >= INTERVAL_LAVA) then
        dtime_count_lava = dtime_count_lava - INTERVAL_LAVA;
        for name, t in pairs(players) do
            if (t.player:get_hp() < t.hp) then
                local pos = t.player:getpos();
                local nodey0 = minetest.env:get_node(pos).name;
                local nodey1 = minetest.env:get_node({ x=pos.x, y=pos.y+1, z=pos.z }).name;
                if ((nodey0 == "default:lava_source") or (nodey1 == "default:lava_source") or (nodey0 == "default:lava_flowing") or (nodey1 == "default:lava_flowing")) then
                    local inv = t.player:get_inventory();
                    local stk = ItemStack("lavasuit:energy 1");
                    local stksuit = ItemStack("lavasuit:lavasuit 1");
                    if (inv:contains_item("main", stk) and inv:contains_item("main", stksuit)) then
                        t.player:set_hp(t.hp);
                        inv:remove_item("main", stk);
                    end
                end
            end
            t.hp = t.player:get_hp();
        end
    end
    
    if (dtime_count_water >= INTERVAL_WATER) then
        dtime_count_water = dtime_count_water - INTERVAL_WATER;
        for name, t in pairs(players) do
            if (t.player:get_breath() < t.breath) then
                local pos = t.player:getpos();
                local nodey1 = minetest.env:get_node({ x=pos.x, y=pos.y+1, z=pos.z }).name;
                if ((nodey1 == "default:water_source") or (nodey1 == "default:water_flowing")) then
                    local inv = t.player:get_inventory();
                    local stk = ItemStack("lavasuit:energy 1");
                    local stksuit = ItemStack("lavasuit:watersuit 1");
                    if (inv:contains_item("main", stk) and inv:contains_item("main", stksuit)) then
                        t.player:set_breath(t.breath);
                        inv:remove_item("main", stk);
                    end
                end
            end
        end
    end
end);

minetest.register_on_joinplayer(function ( player )
    players[player:get_player_name()] = {
        player = player;
        hp = player:get_hp();
        breath = player:get_breath();
    };
end);

minetest.register_on_leaveplayer(function ( player )
    players[player:get_player_name()] = nil;
end);
