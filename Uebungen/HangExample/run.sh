#!/bin/sh

echo "##################   Aufruf 6 ################"
curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/trouble?count=6'
echo "##################   Aufruf 7 ################"
curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/trouble?count=7'
echo "##################   Aufruf 8 ################"
curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/trouble?count=8'
echo "##################   Aufruf 9 ################"
curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/trouble?count=9'
echo "##################   Aufruf 10 ################"
curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/trouble?count=10'
echo "##################   Aufruf 11 ################"
curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/trouble?count=11'
echo "##################   Aufruf 12 ################"
curl -s 'http://localhost:8080/jaxrs-ws-1.0.0-SNAPSHOT/trouble?count=12'
echo "##################   Ende ###############"
