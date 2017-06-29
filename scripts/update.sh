#!/bin/sh

cd /home/minetest/eurythmia-server && git fetch --quiet origin master && git reset --quiet --hard FETCH_HEAD && git clean -df && git submodule sync --quiet && git submodule update --init --quiet
rsync --delete -a /home/minetest/eurythmia-server/mods/ /home/minetest/.minetest/mods/
rsync --delete -a /home/minetest/eurythmia-server/games/ /home/minetest/.minetest/games/
rsync -lptgo /home/minetest/eurythmia-server/minetest.conf /home/minetest/.minetest/
rsync -lptgo /home/minetest/eurythmia-server/worlds/server/world.mt /home/minetest/.minetest/worlds/server/
