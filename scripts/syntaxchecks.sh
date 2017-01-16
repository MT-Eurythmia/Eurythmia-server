#!/bin/sh

luac `find ../games ../mods -name \*.lua`
if [ $? = '0' ]; then
	echo "No syntax issue!"
fi
rm luac.out
