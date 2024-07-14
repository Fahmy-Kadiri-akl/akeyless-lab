#!/bin/bash

# Function to prompt the user for input and store it in a variable
prompt_for_input() {
    local prompt_message=$1
    local input_variable=$2
    read -p "$prompt_message: " $input_variable
}

# Prompt the user for values
prompt_for_input "Enter ADMIN_ACCESS_ID" ADMIN_ACCESS_ID
prompt_for_input "Enter SAML_ACCESS_ID" SAML_ACCESS_ID
prompt_for_input "Enter POSTGRESQL_PASSWORD" POSTGRESQL_PASSWORD
prompt_for_input "Enter POSTGRESQL_USERNAME" POSTGRESQL_USERNAME

# Define the path to save the docker-compose.yml file
output_file="docker-compose.yml"

# Create the docker-compose.yml file using a heredoc
cat << EOF > $output_file
services:
  Akeyless-Gateway:
    ports:
      - 8000:8000
      - 8200:8200
      - 18888:18888
      - 8080:8080
      - 8081:8081
      - 5696:5696
    container_name: akeyless-gateway
    environment:
      - CLUSTER_NAME=akeyless-lab
      - ADMIN_ACCESS_ID=$ADMIN_ACCESS_ID
      - 'ALLOWED_ACCESS_PERMISSIONS=[ {"name": "Administrators",
        "access_id": "$SAML_ACCESS_ID", "permissions": ["admin"]}]'
    image: akeyless/base:latest-akeyless
  Custom-Server:
    ports:
      - 2608:2608
      volumes:
        - \$PWD/custom_logic.sh:/custom_logic.sh
      environment:
        - GW_ACCESS_ID=$ADMIN_ACCESS_ID
    restart: unless-stopped
    container_name: custom-server
    image: akeyless/custom-server
  zero-trust-bastion:
    container_name: akeyless-lab-web-bastion
    ports:
      - 8888:8888
    environment:
      - AKEYLESS_GW_URL=https://rest.akeyless.io
      - PRIVILEGED_ACCESS_ID=$ADMIN_ACCESS_ID
      - ALLOWED_ACCESS_IDS=$SAML_ACCESS_ID
      - CLUSTER_NAME=akeyless-lab-sra
    restart: unless-stopped
    image: akeyless/zero-trust-bastion:latest
  ZTWA-Dispatcher:
    image: akeyless/zero-trust-web-dispatcher
    ports:
      - 9000:9000
      - 19414:19414
    volumes:
      - \$PWD/shared:/etc/shared
    environment:
      - CLUSTER_NAME=akeyless-lab-sra
      - SERVICE_DNS=worker
      - AKEYLESS_GW_URL=https://rest.akeyless.io
      - PRIVILEGED_ACCESS_ID=$ADMIN_ACCESS_ID
      - ALLOWED_ACCESS_IDS=[$SAML_ACCESS_ID]
      - ALLOW_INTERNAL_AUTH=false
      - DISABLE_SECURE_COOKIE=true
      - WEB_PROXY_TYPE=http
  postgresql:
    ports:
      - 5432:5432
    environment:
      - POSTGRESQL_PASSWORD=$POSTGRESQL_PASSWORD
      - POSTGRESQL_USERNAME=$POSTGRESQL_USERNAME
    container_name: postgresql
    image: bitnami/postgresql:latest
  grafana:
    container_name: grafana
    ports:
      - 3000:3000
    image: bitnami/grafana:latest
EOF

echo "docker-compose.yml file has been generated at $output_file."

# Run docker-compose up -d
docker-compose up -d

echo "Docker containers are being started in detached mode."
