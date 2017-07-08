#!/bin/sh

BASE_DIR=/home/minetest/eurythmia-server/
MINETEST_DIR=/home/minetest/minetest/
RUN_SCRIPT_PATH=/home/scripts/run.sh
LOCK_FILE=/home/minetest/autoupdate_lock

if [ -a $LOCK_FILE ];
	echo "Could not run update.sh: file ~/autoupdate_lock is existing."
	exit 1
fi

cd BASE_DIR

# Backup...
git branch --delete backup
git checkout -b backup
git checkout master

git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git submodule sync
git submodule update --init

# Set submodule URLs to SSH
set_submodule_url() {
	for d in "$@"; do
		cd $d
		URL=`git remote -v | grep origin | head -n 1 | awk '{print $2}'`
		if [[ -n `echo $URL | grep 'https://'` ]]; then
			git remote set-url origin 'git@github.com:'${HTTPS_URL: 19}
		fi
		cd $BASE_DIR
	done
}
set_submodule_url `git config --file .gitmodules --get-regexp path | awk '{ print $2 }'`

# Synchronize directories
rsync --delete -a /home/minetest/eurythmia-server/mods/ /home/minetest/.minetest/mods/
rsync --delete -a /home/minetest/eurythmia-server/games/ /home/minetest/.minetest/games/
rsync -lptgo /home/minetest/eurythmia-server/minetest.conf /home/minetest/.minetest/
rsync -lptgo /home/minetest/eurythmia-server/worlds/server/world.mt /home/minetest/.minetest/worlds/server/

# Backup minetestserver
mv MINETEST_DIR'bin/minetestserver' MINETEST_DIR'bin/minetestserver_backup'
# Update it
cd MINETEST_DIR
git branch -d backup
git checkout -b backup
git checkout master
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
make

# Test if everything's correctly booting
timeout --preserve-status 20 $RUN_SCRIPT_PATH once
if [[ $? != 0 ]]; then
	# Re-apply everything as before
	git checkout backup
	mv MINETEST_DIR'bin/minetestserver_backup' MINETEST_DIR'bin/minetestserver'
	cd BASE_DIR
	git checkout backup
	rsync --delete -a /home/minetest/eurythmia-server/mods/ /home/minetest/.minetest/mods/
	rsync --delete -a /home/minetest/eurythmia-server/games/ /home/minetest/.minetest/games/
	rsync -lptgo /home/minetest/eurythmia-server/minetest.conf /home/minetest/.minetest/
	rsync -lptgo /home/minetest/eurythmia-server/worlds/server/world.mt /home/minetest/.minetest/worlds/server/

	# Send an e-mail
	sendmail root@langg.net << END
From: Eurythmia auto-update <minetest@langg.net>
To: root@langg.net
Subject: *** Server is not able to boot after update ***
The nightly update caused the server being no longer able to boot. Everything has been re-applied as before.
Using backup branches and created update lock.
END

	# Create the autoupdate lock
	echo 'This file has been created to prevent the automatic update to run again since it failed. Do not remove it unless you fixed the problem.' >> $LOCK_FILE
fi
