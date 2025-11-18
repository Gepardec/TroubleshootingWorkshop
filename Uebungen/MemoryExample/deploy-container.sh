#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Stop and remove existing container if it exists
docker stop memory-leak-demo 2>/dev/null
docker rm memory-leak-demo 2>/dev/null

# Build the image
docker build -f "$SCRIPT_DIR/configure/Containerfile" -t memory-leak-demo "$SCRIPT_DIR/configure/"


docker run -d -p 8080:8080 --memory=70m --name memory-leak-demo memory-leak-demo \
  -Xmx100m \
  -XX:+ExitOnOutOfMemoryError \
  -Dquarkus.http.host=0.0.0.0 \
  -Djava.util.logging.manager=org.jboss.logmanager.LogManager \
  -jar /deployments/app.jar

echo "Container 'memory-leak-demo' is running on port 8080"
