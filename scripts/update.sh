#!/bin/bash

echo -e '=> **** Running script update.sh ****\n'

BASE_DIR=/home/minetest/eurythmia-server/
MINETEST_DIR=/home/minetest/minetest/
RUN_SCRIPT_PATH=/home/minetest/scripts/run.sh
UPDATE_SUBMODULE_SCRIPT_PATH=/home/minetest/scripts/update_submodule.sh
SUBMODULES_FILE=/home/minetest/to_update_submodules.txt
LOCK_FILE=/home/minetest/autoupdate_lock

error() {
	echo "==> Error ($1): $2"
	/usr/sbin/sendmail root@langg.net << END
From: Eurythmia auto-update <minetest@langg.net>
To: root@langg.net
Subject: *** $1 ***
$2

See /home/minetest/backup_sh_log.txt for more informations.
END
}

if [[ -a $LOCK_FILE ]]; then
	error 'File ~/autoupdate_lock exists' 'Could not run update.sh: file ~/autoupdate_lock exists.
This is probably because of a previous error.'
	exit 1
fi

cd $BASE_DIR

# Backup...
echo '==> Backuping Eurythmia-server repo to backup branch'
git branch --delete backup
git checkout -b backup
git checkout master

echo '==> Fetching origin'
git fetch origin master
git reset --hard FETCH_HEAD
git clean -df
git submodule sync --recursive
git submodule update --init --recursive

# Set submodule URLs to SSH
set_submodule_url() {
	for d in "$@"; do
		cd $d
		URL=`git remote -v | grep origin | grep push | awk '{print $2}'`
		if [[ -n `echo $URL | grep 'https://'` ]]; then
			git remote set-url --push origin 'git@github.com:'${URL: 19}
		fi
		cd $BASE_DIR
	done
}
echo '==> Setting submodules URLs from HTTPS to SSH'
set_submodule_url `git config --file .gitmodules --get-regexp path | awk '{ print $2 }'`

# Update the submodules marked by the eurybot
echo '==> Updating submodules marked by the eurybot...'
while read submodule; do
	if [[ ${submodule: -1} == '!' ]]; then
		echo "===> Updating submodule ${submodule:0:-1} from upstream"
		$UPDATE_SUBMODULE_SCRIPT_PATH ${submodule:0:-1} upstream
	else
		echo "===> Updating submodule $submodule from origin"
		$UPDATE_SUBMODULE_SCRIPT_PATH $submodule
	fi
done <$SUBMODULES_FILE
echo -n '' > $SUBMODULES_FILE

# Synchronize directories
echo '==> Synchronizing ~/eurythmia-server and ~/.minetest directories'
rsync --delete -a /home/minetest/eurythmia-server/mods/ /home/minetest/.minetest/mods/
rsync --delete -a /home/minetest/eurythmia-server/games/ /home/minetest/.minetest/games/
rsync -lptgo /home/minetest/eurythmia-server/minetest.conf /home/minetest/.minetest/
rsync -lptgo /home/minetest/eurythmia-server/worlds/server/world.mt /home/minetest/.minetest/worlds/server/

# Backup minetestserver
echo '==> Backuping minetestserver executable to ~/minetestserver_backup'
mv $MINETEST_DIR'bin/minetestserver' '~/minetestserver_backup'
# Update it
echo '==> Updating minetestserver'
cd $MINETEST_DIR
git branch -d backup
git checkout -b backup
git checkout master
git pull --ff-only origin master
if [[ $? == 0 ]]; then
	if [[ -n `git remote -v | grep upstream` ]]; then
		git fetch upstream master
		git checkout master
		git cherry-pick --allow-empty master..upstream/master
		if [[ -a $BASE_DIR'.git/CHERRY_PICK_HEAD' ]]; then
			# Oops, looks like there was a conflict
			git cherry-pick --abort
			error 'Impossible to update the minetestserver: cherry-pick conflict' 'The `CHERRY_PICK_HEAD` still existed after running git-cherry-pick to update the minetestserver from upstream.'
		else
			git push origin master
			echo '===> Recompiling...'
			make -j`nproc`
		fi
	else
		echo '===> Recompiling (no upstream, origin changes only)...'
		make -j`nproc` # Make again though, there may be updates from origin
		error 'Impossible to update the minetestserver: no upstream remote' 'The upstream remote does not exist. The minetestserver has still been updated from origin.'
	fi
else
	error 'Impossible to update the minetestserver: non-fast-forward' 'Impossible to update the minetestserver form remote origin: non-fast-forward'
fi

# Test if everything's correctly booting
echo '==> Testing if the minetestserver is able to boot correctly'
timeout --preserve-status 20 $RUN_SCRIPT_PATH once
TIMEOUT_STATUS=$?
if [[ $TIMEOUT_STATUS != 143 ]]; then
	# Re-apply everything as before
	git checkout backup
	mv '~/minetestserver_backup' $MINETEST_DIR'bin/minetestserver'
	cd $BASE_DIR
	git checkout backup
	rsync --delete -a /home/minetest/eurythmia-server/mods/ /home/minetest/.minetest/mods/
	rsync --delete -a /home/minetest/eurythmia-server/games/ /home/minetest/.minetest/games/
	rsync -lptgo /home/minetest/eurythmia-server/minetest.conf /home/minetest/.minetest/
	rsync -lptgo /home/minetest/eurythmia-server/worlds/server/world.mt /home/minetest/.minetest/worlds/server/

	# Create the autoupdate lock
	echo 'This file has been created to prevent the automatic update to run again since it failed. Do not remove it unless you fixed the problem.' >> $LOCK_FILE

	# Send an e-mail
	error 'Server is no longer able to boot ater update' "The nightly update caused the server being no longer able to boot.
Everything has been re-applied as before.
Using backup branches and created update lock.
The timeout status was $TIMEOUT_STATUS."

	exit 2
fi

echo -e '=> **** update.sh: exiting normally ****\n'
