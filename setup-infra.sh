#!/bin/bash

# Create a dummy runner.env so docker-compose doesn't fail parsing
if [ ! -f "runner.env" ]; then
  touch runner.env
fi

echo "Starting Shared Infrastructure (Gitea, SonarQube, Portainer)..."
docker compose -f docker-compose.shared.yml up -d gitea_db gitea sonarqube_db sonarqube portainer

echo "Waiting for Gitea to be fully up and running..."
until [ "$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/)" != "000" ]; do
  echo "Gitea is not ready yet... waiting 5s..."
  sleep 5
done

# Wait just a little more to ensure DB migrations and internal setup are fully ready
sleep 10

echo "Gitea is ready! Creating default admin user..."
# Create admin user (ignore error if already exists)
ADMIN_PASSWD=${GITEA_ADMIN_PASSWD:-admin}
docker exec -u git gitea gitea admin user create --admin --username admin --password "$ADMIN_PASSWD" --email admin@localhost.com --must-change-password=false || true

echo "Extracting runner registration token..."
# Generate token via Gitea CLI inside container
RUNNER_TOKEN=$(docker exec -u git gitea gitea actions generate-runner-token)

# Remove carriage returns if any
RUNNER_TOKEN=$(echo "$RUNNER_TOKEN" | tr -d '\r')

if [ -n "$RUNNER_TOKEN" ]; then
    echo "Writing token to runner.env..."
    echo "GITEA_INSTANCE_URL=http://gitea:3000" > runner.env
    echo "GITEA_RUNNER_REGISTRATION_TOKEN=$RUNNER_TOKEN" >> runner.env
    echo "GITEA_RUNNER_NAME=local-docker-runner" >> runner.env
    echo "GITEA_RUNNER_LABELS=ubuntu-latest:docker://catthehacker/ubuntu:act-latest,ubuntu-22.04:docker://catthehacker/ubuntu:act-22.04" >> runner.env
    
    echo "Starting Gitea Act Runner..."
    docker compose -f docker-compose.shared.yml up -d gitea-runner
    echo "Gitea Runner started successfully!"
else
    echo "Failed to extract Gitea runner token. Please check logs."
fi

echo "Infrastructure is up!"
echo "Gitea: http://localhost:3000 (Create the first user to be admin)"
echo "SonarQube: http://localhost:9001 (admin/admin)"
echo "Portainer: http://localhost:9002"
