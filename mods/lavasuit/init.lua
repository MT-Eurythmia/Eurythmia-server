
minetest.register_craftitem("lavasuit:lavasuit", {
    description = "Lava Suit";
    groups = {};
    inventory_image = "lavasuit_lavasuit.png";
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

local INTERVAL = 0.5;

local dtime_count = 0;

minetest.register_globalstep(function ( dtime )
    dtime_count = dtime_count + dtime;
    if (dtime_count >= INTERVAL) then
        dtime_count = dtime_count - INTERVAL;
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
end);

minetest.register_on_joinplayer(function ( player )
    players[player:get_player_name()] = {
        player = player;
        hp = player:get_hp();
    };
end);

minetest.register_on_leaveplayer(function ( player )
    players[player:get_player_name()] = nil;
end);
