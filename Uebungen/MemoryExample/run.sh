#!/bin/bash

echo "Starting memory leak test..."
echo "Press Ctrl+C to stop"
echo ""

counter=1

while true; do
    echo "[$counter] Triggering leak endpoint..."
    response=$(curl -s http://localhost:8080/leak)
    echo "Response: $response"
    
    echo "Getting memory status..."
    status=$(curl -s http://localhost:8080/leak/status)
    echo "$status"
    echo "---"
    
    ((counter++))
    
    # Wait 5 seconds between calls
    sleep 5
done
