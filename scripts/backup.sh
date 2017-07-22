#!/bin/sh

echo -e '=> **** Running script backup.sh ****\n'

# Stop the server if is not
echo "==> Killing processes named 'minetestserver'."
killall minetestserver

# Map backup
echo '==> Backuping the map.'
if [ `date +%d` = '01' ]; then
	echo '===> Backuping to /backupd/minetest/server_monthly...'
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_monthly
elif [ `date +%w` = '1' ]; then
	echo '===> Backuping to /backupd/minetest/server_weekly...'
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_weekly
else
	echo '===> Backuping to /backupd/minetest/server_nightly...'
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_nightly
fi

# Logrotate
echo '==> Running logrotate.'
/usr/sbin/logrotate -s ~/logrotate_status /home/minetest/scripts/logrotate_conf

# Update files from the git repo
echo '==> Running script update.sh.'
/home/minetest/scripts/update.sh

# Restart the server
echo '==> Starting back the minetestserver.'
nohup /home/minetest/scripts/run.sh &> /dev/null &

echo -e '=> **** backup.sh: exiting normally ****\n'
