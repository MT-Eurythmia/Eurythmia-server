#!/bin/sh

# Stop the server if is not
/etc/init.d/minetestserver stop

if [ `date +%d` = '01' ]; then
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_monthly
elif [ `date +%w` = '1' ]; then
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_weekly
else
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_nightly
fi

# Logrotate
/usr/sbin/logrotate /home/minetest/scripts/logrotate_conf

# Restart the server
/etc/init.d/minetestserver start
