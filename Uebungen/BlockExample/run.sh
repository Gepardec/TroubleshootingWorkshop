#!/bin/sh


###########################
# start_calls
###########################
start_calls() {
	while true; do
		# time curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/perf2' > /dev/null &
		/usr/bin/time -f "time %E" curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/perf2' > /dev/null &
        sleep 0.5
	done
}

################################################
#                   MAIN
################################################

start_calls &
CALL_PID=$!
trap "kill $CALL_PID" INT

sleep 120
kill $CALL_PID

