#!/bin/bash

echo "=== Cleaning local Docker environment ==="
docker stop $(docker ps -aq) 2>/dev/null || true
docker rm $(docker ps -aq) 2>/dev/null || true
docker system prune -f
docker rmi $(docker images -q) -f 2>/dev/null || true

echo "=== Cleaning remote VM Docker environment ==="
ssh ubuntu@172.18.242.201 "sudo docker stop \$(sudo docker ps -aq) 2>/dev/null || true; sudo docker rm \$(sudo docker ps -aq) 2>/dev/null || true; sudo docker system prune -a -f"

echo "=== Deploying with Kamal ==="

if [ -f .env ]; then
    echo "Loading RAILS_MASTER_KEY and KAMAL_REGISTRY_PASSWORD from .env"
    export RAILS_MASTER_KEY=$(source .env && echo $RAILS_MASTER_KEY)
    export KAMAL_REGISTRY_PASSWORD=$(source .env && echo $KAMAL_REGISTRY_PASSWORD)
fi

if [ -z "$RAILS_MASTER_KEY" ] || [ -z "$KAMAL_REGISTRY_PASSWORD" ]; then
    echo "Error: RAILS_MASTER_KEY and KAMAL_REGISTRY_PASSWORD must be set"
    exit 1
fi

echo "Environment variables loaded successfully"
kamal deploy --verbose