#!/bin/bash

echo -e '=> **** Running script backup.sh ****\n'

# Stop the server if is not
echo "==> Killing processes named 'minetestserver'."
killall minetestserver

# Map backup
echo '==> Backuping the map.'
echo '===> Rotating nightly backups'
rm /backupd/minetest/server_nightly_j-2
mv /backupd/minetest/server_nightly_j-1 /backupd/minetest/server_nightly_j-2
mv /backupd/minetest/server_nightly_j-0 /backupd/minetest/server_nightly_j-1
if [ `date +%d` = '01' ]; then
	echo '===> Backuping to /backupd/minetest/server_monthly...'
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_monthly
	ln -s /backupd/minetest/server_monthly /backupd/minetest/server_nightly_j-0
elif [ `date +%w` = '1' ]; then
	echo '===> Backuping to /backupd/minetest/server_weekly...'
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_weekly
	ln -s /backupd/minetest/server_weekly /backupd/minetest/server_nightly_j-0
else
	echo '===> Backuping to /backupd/minetest/server_nightly...'
	rsync --delete --archive /home/minetest/.minetest/worlds/server/ /backupd/minetest/server_nightly_j-0
fi

# Logrotate
echo '==> Running logrotate.'
/usr/sbin/logrotate -s /home/minetest/logrotate_status /home/minetest/scripts/logrotate_conf

# Update files from the git repo
echo '==> Running script update.sh.'
/home/minetest/scripts/update.sh

# Restart the server
echo '==> Starting back the minetestserver.'
nohup /home/minetest/scripts/run.sh &> /dev/null &

echo -e '=> **** backup.sh: exiting normally ****\n'
