#!/bin/bash

# Maximum number of concurrent requests
MAX_REQUESTS=${1:-1000}
DELAY=${2:-0.15}  # Delay between starting each request (in seconds)

request_counter=0

# short wait
sleep 2

# Send requests gradually (non-blocking)
for i in $(seq 1 $MAX_REQUESTS); do
    ((request_counter++))
    (
        echo "[$i] Sending request at $(date +%H:%M:%S)"
        response=$(curl -s -w "\nHTTP_CODE:%{http_code}\nTIME_TOTAL:%{time_total}" \
                   http://localhost:8080/api/slow 2>&1)
        
        http_code=$(echo "$response" | grep "HTTP_CODE" | cut -d: -f2)
        time_total=$(echo "$response" | grep "TIME_TOTAL" | cut -d: -f2)
        body=$(echo "$response" | grep -v "HTTP_CODE" | grep -v "TIME_TOTAL")
        
        if [ "$http_code" = "200" ]; then
            echo "[$i] SUCCESS after ${time_total}s -> Response is: $body"
        else
            echo "[$i] FAILED (HTTP $http_code) after ${time_total}s"
        fi
    ) &
    
    # Gradually increase load by waiting between requests
    sleep $DELAY
done

echo ""
echo "All $MAX_REQUESTS requests sent. Waiting for completion..."

# Wait for all background jobs to complete
wait

echo ""
echo "Load test completed!"
