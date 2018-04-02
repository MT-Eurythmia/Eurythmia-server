#!/usr/bin/bash

git submodule foreach "bash -c 'if [ -z `git remote | grep upstream` ]; then
git pull origin master
else
git pull upstream master --no-edit
git push origin master
fi'"
