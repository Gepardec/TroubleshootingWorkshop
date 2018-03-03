#!/bin/sh

curl -X PUT  --header "Content-Type: application/json" http://localhost:8080/ticket-monster/rest/bot/status -d '"RUNNING"'
echo "Bot gestartet, warte 60 Sekunden"
sleep 60
curl -X PUT  --header "Content-Type: application/json" http://localhost:8080/ticket-monster/rest/bot/status -d '"NOT_RUNNING"'
echo "Bot beendet"
