#!/bin/bash

SUBMODULES=""

BASE_DIR=`pwd`

get_submodule() {
	for d in "$@"; do
		cd $d
		FETCH_URL=`git remote -v | grep origin | head -n 1 | awk '{print $2}'`

		# Forked?
		FORKED_FROM_LINE=`curl -s ${FETCH_URL:0:-4} | grep '      <span class="text">forked from '`
		if [[ -n $FORKED_FROM_LINE ]]; then
			# Bash expansion syntax is killing me, really.
			MATCH_START=${FORKED_FROM_LINE##*<a href=\"}
			UPSTREAM_URL="https://github.com""${MATCH_START%%\"*}"

			if [[ -z `git remote -v | grep upstream` ]]; then
				git remote add upstream $UPSTREAM_URL.git
			fi
		fi

		SUBMODULES="$SUBMODULES$d,${FETCH_URL:0:-4},$UPSTREAM_URL;"

		cd $BASE_DIR
	done
}

cd $BASE_DIR
get_submodule `git config --file .gitmodules --get-regexp path | awk '{ print $2 }'`
echo $SUBMODULES
