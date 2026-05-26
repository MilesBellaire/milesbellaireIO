#!/bin/bash

# 1. Define the path to your orchestration repository folder
REPO_DIR="/home/deploy/milesbellaireIO"
COMPOSE_FILE="$REPO_DIR/docker-compose.yml"

# 2. Load .env variables into this script's environment
if [ -f "$REPO_DIR/.env" ]; then
    export $(grep -v '^#' "$REPO_DIR/.env" | xargs)
fi

# 3. Define the images to pull
FRONTEND="ghcr.io/milesbellaire/milesbellairefe:latest"
BACKEND="ghcr.io/milesbellaire/milesbellairebe:latest"
CLOUDFLARE="cloudflare/cloudflared:latest"

# 4. Check if we should enable the tunnel profile
if [ "$ENABLE_TUNNEL" = "true" ]; then
    echo "Tunneling enabled. Activating 'tunnel' profile..."
else
    echo "Tunneling disabled. Running in standard mode..."
fi

echo "$(date): Starting deployment..."

# 5. STEP ONE: Update the Orchestration files
# This pulls any changes you made to the docker-compose.yml itself
echo "Updating orchestration files..."
cd $REPO_DIR
git pull origin main

# 6. STEP TWO: Pull the new application images
echo "Pulling latest images from GHCR..."
docker pull $FRONTEND
docker pull $BACKEND
docker pull $CLOUDFLARE

# 7. STEP THREE: Apply the changes
# We use the -f flag to point to the updated file we just pulled
echo "Applying changes to containers..."
if [ "$ENABLE_TUNNEL" = "true" ]; then
    docker compose -f $COMPOSE_FILE --profile tunnel up -d --remove-orphans
else
    # Bring down tunnel profile services first, then start the rest
    docker compose -f $COMPOSE_FILE --profile tunnel down
    docker compose -f $COMPOSE_FILE up -d --remove-orphans
fi

# 8. Cleanup
echo "Cleaning up old images..."
docker image prune -f

echo "$(date): Deployment complete successfully!"