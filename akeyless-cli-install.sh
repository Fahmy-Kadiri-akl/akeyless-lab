curl -o akeyless https://akeyless-cli.s3.us-east-2.amazonaws.com/cli/latest/production/cli-linux-amd64
chmod +x akeyless
./akeyless

source /home/azureuser/.bashrc

sudo apt update
sudo apt -y install docker.io
sudo apt -y install docker-compose
sudo usermod -aG docker ${USER}
