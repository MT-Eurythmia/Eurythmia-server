#!/bin/bash

# Usage: update_submodules.sh <submodule path>

BASE_DIR=`pwd`

cd $BASE_DIR$1

git fetch origin master && git checkout master && git reset --hard FETCH_HEAD && git clean -df

if [[ -n `git remote -v | grep upstream` ]]; then
	git fetch upstream master && git checkout master
	git cherry-pick master..upstream/master
	if [[ -a $BASE_DIR'.git/modules/'$1'CHERRY_PICK_HEAD' ]]; then
		# Oops, looks like there was a conflict
		git cherry-pick --abort
		# The following commands should not be needed, but I prefer always make sure when using git in scripts :p
		git checkout master
		git checkout -- *
		git reset --hard HEAD

		exit 1
	fi

	# The timeout will avoid staying blocked if git is misconfigured (e.g. if git-push asks for a password)
	timeout 20 git push origin master
	if [[ $? == '124' ]]; then
		exit 2
	fi
fi

cd $BASE_DIR
git add $1
git commit -m 'Update subodule ['$1']'

# The timeout will avoid staying blocked if git is misconfigured (e.g. if git-push asks for a password)
timeout 20 git push origin master
if [[ $? == '124' ]]; then
	exit 3
fi
