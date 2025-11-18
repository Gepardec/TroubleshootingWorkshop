#!/bin/bash

cd configure && java -Xmx100m -jar memory-leak-demo-1.0.0-SNAPSHOT-runner.jar &
cd ..
