#!/bin/bash

### Running MTSatellite
SATPATH="$PWD/../mtsatellite"
export GOROOT=$SATPATH/go
export GOPATH=$SATPATH/gopath

LOGFILE="$PWD/../mtsatellite_log.txt"

$GOPATH/bin/mtredisalize -host=localhost -interleaved=true -change-url=http://localhost:8808/update -change-duration=60s $PWD/../worlds/server/map.db >> $LOGFILE 2>&1 &

sleep 1

GOMAXPROCS=2 $GOPATH/bin/mtwebmapper -colors=$SATPATH/colors.txt -web-host="" -map=$SATPATH/map_satellite -web=$SATPATH/web -redis-host=localhost -workers=1 -websockets=false -players=/tmp/mt_players_fifo >> $LOGFILE 2>&1 &

sleep 1

### Running the server	
while [ true ]; do
	
	/home/administrateur/minetest/bin/minetestserver
	if [ $? = 0 ]; then # Normal quit : Maybe the admin pressed Ctrl+C. Wait before restarting.
		echo "Please press Ctrl+C (again). If you don't, the server will restart in 5 seconds."
		sleep 5
	else
		echo "Crash! Restarting the server immediatly..."
		sleep 0.1 # Sleep a little to avoid a total crashing loop
	fi
	
	# Run again mtredisalize (it stops automatically)
	$GOPATH/bin/mtredisalize -host=localhost -interleaved=true -change-url=http://localhost:8808/update -change-duration=60s $PWD/../worlds/server/map.db >> $LOGFILE 2>&1 &
	sleep 1
done
