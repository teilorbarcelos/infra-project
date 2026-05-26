#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <project-name> <port-prefix>"
    echo "Example: $0 meu-projeto 31"
    exit 1
fi

PROJECT_NAME=$1
PREFIX=$2

echo "Creating new project: $PROJECT_NAME with prefix $PREFIX..."

mkdir -p "../$PROJECT_NAME"
cp -r template/* "../$PROJECT_NAME/"
mkdir -p "../$PROJECT_NAME/.gitea/workflows"
cp template/.gitea/workflows/deploy.yaml "../$PROJECT_NAME/.gitea/workflows/deploy.yaml"

# Replace placeholders
sed -i "s/REPLACE_ME_PROJECT_NAME/$PROJECT_NAME/g" "../$PROJECT_NAME/.gitea/workflows/deploy.yaml"
sed -i "s/REPLACE_ME_PROJECT_NAME/$PROJECT_NAME/g" "../$PROJECT_NAME/sonar-project.properties"

echo "Project $PROJECT_NAME created at ../$PROJECT_NAME"
echo "----------------------------------------------------"
echo "To finish setup, go to Gitea and create a repository named $PROJECT_NAME."
echo "Then, configure the following Secrets in Gitea for this repository (Settings > Actions > Secrets):"
echo "DEV_PORT_BACK=${PREFIX}01"
echo "DEV_PORT_FRONT=${PREFIX}02"
echo "STG_PORT_BACK=${PREFIX}03"
echo "STG_PORT_FRONT=${PREFIX}04"
echo "PRD_PORT_BACK=${PREFIX}05"
echo "PRD_PORT_FRONT=${PREFIX}06"
echo "SONAR_HOST_URL=http://sonarqube:9000"
echo "SONAR_TOKEN=<your_sonar_token>"
echo "----------------------------------------------------"
