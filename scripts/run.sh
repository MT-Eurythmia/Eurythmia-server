#!/bin/bash

### Running MTSatellite
SATPATH="/home/minetest/mtsatellite"
export GOROOT=$SATPATH/go
export GOPATH=$SATPATH/gopath

LOGFILE="/home/minetest/mtsatellite_log.txt"

$GOPATH/bin/mtredisalize -host=localhost -interleaved=true -change-url=http://localhost:8808/update -change-duration=60s /home/minetest/.minetest/worlds/server/map.db >> $LOGFILE 2>&1 &

sleep 1

cpulimit -c 1 -l 1 -b -- $GOPATH/bin/mtwebmapper -colors=$SATPATH/colors.txt -web-host="" -map=$SATPATH/map_satellite -web=$SATPATH/web -redis-host=localhost -workers=1 -websockets=false -players=/tmp/mt_players_fifo -ymax=500 >> $LOGFILE 2>&1

sleep 1

### Running the server	
while [ true ]; do
	/home/minetest/minetest/bin/minetestserver
	if [ $? = 0 ]; then # Normal quit : Maybe the admin pressed Ctrl+C. Wait before restarting.
		exit
	else
		echo "Crash! Restarting the server immediatly..."
		sleep 1 # Sleep a second to avoid a total crashing loop
	fi
	
	# Run again mtredisalize (it stops automatically)
	$GOPATH/bin/mtredisalize -host=localhost -interleaved=true -change-url=http://localhost:8808/update -change-duration=60s /home/minetest/.minetest/worlds/server/map.db >> $LOGFILE 2>&1 &
	sleep 1
done
