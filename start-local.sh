#!/bin/bash

echo "=== Cleaning local Docker environment ==="
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker system prune -f
docker rmi $(docker images -q) -f 2>/dev/null || true

docker compose up