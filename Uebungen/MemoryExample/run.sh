#!/bin/sh


###########################
# start_calls
###########################
start_calls() {
	cnt=0
	start_time=$(date +%s.%N)
	while true; do
		curl -s 'http://localhost:8080/ticket2rock/bandlist.faces'  > /dev/null & 
		curl -s 'http://localhost:8080/ticket2rock/konzertsuche.faces' > /dev/null; 
		echo -n '.';
		let cnt=$cnt+1
		if [ $cnt -ge 50 ]; then
			cnt=0
			end_time=$(date +%s.%N)
			diff=$(echo "$end_time - $start_time" | bc)
			echo $diff
			start_time=$end_time
		fi
	done
}

################################################
#                   MAIN
################################################

start_calls &
CALL_PID=$!
trap "kill $CALL_PID" INT

sleep 500
kill $CALL_PID

