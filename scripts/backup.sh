#!/bin/sh

# Stop the server if is not
/etc/init.d/minetestserver stop

if [ `date +%d` = '1' ]; then
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /home/minetest/.minetest/worlds/server_monthly
elif [ `date +%w` = '1' ]; then
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /home/minetest/.minetest/worlds/server_weekly
else
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /home/minetest/.minetest/worlds/server_nightly
fi

# Restart the server
/etc/init.d/minetestserver start
