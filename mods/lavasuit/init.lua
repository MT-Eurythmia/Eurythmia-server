
minetest.register_tool("lavasuit:lavasuit", {
    description = "Lava Suit";
    groups = {};
    inventory_image = "lavasuit_lavasuit.png";
});

minetest.register_tool("lavasuit:watersuit", {
    description = "Water Suit";
    groups = {};
    inventory_image = "lavasuit_watersuit.png";
});

minetest.register_craft({
    output = 'lavasuit:lavasuit';
    recipe = {
        { '', 'bucket:bucket_lava', '' },
        { 'default:mese_crystal', 'default:mese_crystal', 'default:mese_crystal' },
        { '', 'default:mese_crystal', '' },
    };
});

minetest.register_craft({
    output = 'lavasuit:watersuit';
    recipe = {
        { '', 'bucket:bucket_water', '' },
        { 'default:mese_crystal', 'default:mese_crystal', 'default:mese_crystal' },
        { '', 'default:mese_crystal', '' },
    };
});

local players = { };

local INTERVAL_LAVA = 0.5;
local INTERVAL_WATER = 4;
local WEAR_LAVA = 200; -- wear per hp
local WEAR_WATER = 300; -- wear per breath

local dtime_count_lava = 0;
local dtime_count_water = 0;

local function set_wear(player, suit, wear)
    local inv = player:get_inventory();
    local stack;
    local index;
    for i = 1, inv:get_size("main") do
        stack = inv:get_stack("main", i);
        if ((stack:get_name() == suit)
        and ((65535 - stack:get_wear()) > wear)) then
            index = i;
            break;
        end
    end
    if (index) then
        stack:add_wear(wear);
        inv:set_stack("main", index, stack);
        return true;
    else
        return false;
    end
end

minetest.register_globalstep(function ( dtime )
    dtime_count_lava = dtime_count_lava + dtime;
    dtime_count_water = dtime_count_water + dtime;
    
    if (dtime_count_lava >= INTERVAL_LAVA) then
        dtime_count_lava = dtime_count_lava - INTERVAL_LAVA;
        for name, t in pairs(players) do
            local damage = t.hp - t.player:get_hp();
            if (damage > 0) then
                local pos = t.player:getpos();
                local nodey0 = minetest.env:get_node(pos).name;
                local nodey1 = minetest.env:get_node({ x=pos.x, y=pos.y+1, z=pos.z }).name;
                if ((nodey0 == "default:lava_source") or (nodey1 == "default:lava_source") or (nodey0 == "default:lava_flowing") or (nodey1 == "default:lava_flowing")) then
                    if (set_wear(t.player, "lavasuit:lavasuit", WEAR_LAVA*damage)) then
                        t.player:set_hp(t.hp);
                    end
                end
            end
            t.hp = t.player:get_hp();
        end
    end
    
    if (dtime_count_water >= INTERVAL_WATER) then
        dtime_count_water = dtime_count_water - INTERVAL_WATER;
        for name, t in pairs(players) do
            local breathlessness = t.breath - t.player:get_breath();
            if (breathlessness > 0) then
                local pos = t.player:getpos();
                local nodey1 = minetest.env:get_node({ x=pos.x, y=pos.y+1, z=pos.z }).name;
                if ((nodey1 == "default:water_source") or (nodey1 == "default:water_flowing")) then
                    if (set_wear(t.player, "lavasuit:watersuit", WEAR_WATER*breathlessness)) then
                        t.player:set_breath(t.breath);
                    end
                end
            end
            t.breath = t.player:get_breath();
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
