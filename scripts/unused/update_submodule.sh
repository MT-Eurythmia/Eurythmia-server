#!/bin/bash

# Usage: update_submodules.sh <submodule path> [upstream]

echo -e '=> **** Running script update_submodule.sh ****\n'

BASE_DIR='/home/minetest/eurythmia-server/'

cd $BASE_DIR
cd $1

echo '==> Fetching from origin...'
git fetch origin master && git checkout master && git reset --hard FETCH_HEAD && git clean -df

if [[ -n `git remote -v | grep upstream` ]] && [[ $2 == 'upstream' ]]; then
	echo '==> Fetching from upstream...'
	git fetch upstream master && git checkout master
	git cherry-pick --allow-empty master..upstream/master
	if [[ -a $BASE_DIR'.git/modules/'$1'CHERRY_PICK_HEAD' ]]; then
		# Oops, looks like there was a conflict
		git cherry-pick --abort
		# The following commands should not be needed, but I prefer always make sure when using git in scripts :p
		git checkout master
		git checkout -- *
		git reset --hard HEAD

		/usr/sbin/sendmail root@langg.net << END
From: Eurythmia auto-update <minetest@langg.net>
To: root@langg.net
Subject: *** Error updating submodule $0 ***
There was still a CHERRY_PICK_HEAD after running cherry-pick to update submodule $0.
This is probably because of a cherry-pick conflict.
Please run this cherry-pick manually.
END
		echo "===> Error: There was still a CHERRY_PICK_HEAD after running cherry-pick to update submodule $0."

		exit 1
	fi

	echo '==> Cherry-pick from upsream was successful, pushing to origin.'
	# The timeout will avoid staying blocked if git is incorrectly configured (e.g. if git-push asks for a password)
	timeout 20 git push origin master
	if [[ $? == 124 ]]; then
		exit 2
	fi
fi

cd $BASE_DIR
echo '==> Committing update'
git add $1
git commit -m 'Update submodule ['$1']'

echo '==> Pushing new commit'
# The timeout will avoid staying blocked if git is misconfigured (e.g. if git-push asks for a password)
timeout 20 git push origin master
if [[ $? == 124 ]]; then
	exit 3
fi

echo -e '=> **** update_submodule.sh: exiting normally ****\n'
