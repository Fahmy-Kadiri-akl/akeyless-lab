#!/bin/bash

#update and install docker
sudo apt update
sudo apt -y install docker.io
sudo apt -y install docker-compose
sudo usermod -aG docker ${USER}

#Download Akeyless CLI
curl -o akeyless https://akeyless-cli.s3.us-east-2.amazonaws.com/cli/latest/production/cli-linux-amd64
chmod +x akeyless
./akeyless

source /home/azureuser/.bashrc


# Check if Azure CLI is installed
if ! command -v az &> /dev/null
then
    echo "Azure CLI not found. Installing..."
    sudo apt-get update
    sudo apt-get install ca-certificates curl apt-transport-https lsb-release gnupg -y
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt-get update
    sudo apt-get install azure-cli -y
else
    echo "Azure CLI is already installed."
fi

# Log in to Azure
echo "Logging in to Azure..."
az login --use-device-code

# Get the Tenant ID
echo "Fetching Tenant ID..."
TENANT_ID=$(az account show --query tenantId --output tsv)

# Display the Tenant ID
echo "Your Azure Tenant ID is: $TENANT_ID"


