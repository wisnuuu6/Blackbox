#!/bin/bash

# Code color
GREEN='\033[0;32m'
NC='\033[0m' # No Color (reset to default)

# Variables
VERSION="0.25.0"
DOWNLOAD_URL="https://github.com/prometheus/blackbox_exporter/releases/download/v${VERSION}/blackbox_exporter-${VERSION}.linux-amd64.tar.gz"
INSTALL_DIR="/usr/local/bin"
USER="blackbox"
SERVICE_NAME="blackbox_exporter"

# Download Blackbox Exporter
echo "${GREEN}Downloading Blackbox Exporter version ${VERSION}...${NC}"
wget ${DOWNLOAD_URL} -O ./blackbox_exporter-${VERSION}.tar.gz

# Extract the downloaded file
echo "${GREEN}Extracting Blackbox Exporter...${NC}"
tar -zxvf ./blackbox_exporter-${VERSION}.tar.gz

# Change directory to extracted folder
echo "${GREEN}Change directory to blackbox_exporter-${VERSION}.linux-amd64...${NC}"
cd blackbox_exporter-${VERSION}.linux-amd64

# Move blackbox_exporter to /usr/local/bin
echo "${GREEN}Move blackbox_exporter to /usr/local/bin...${NC}"
sudo mv blackbox_exporter /usr/local/bin

# Make directory for blackbox.yml and move blackbox.yml
echo "${GREEN}Make dir /etc/blackbox and move blackbox.yml...${NC}"
sudo mkdir -p /etc/blackbox
sudo mv blackbox.yml /etc/blackbox

# Make user blackbox and change owner file blackbox
echo "${GREEN}Make user blackbox and change owner file to blackbox owner...${NC}"
sudo useradd -rs /bin/false blackbox
sudo chown blackbox:blackbox /usr/local/bin/blackbox_exporter
sudo chown -R blackbox:blackbox /etc/blackbox/*

# Make blackbox services
echo "${GREEN}Setting up systemd service...${NC}"
sudo bash -c "cat <<EOF > /etc/systemd/system/blackbox.service
[Unit]
Description=Blackbox Exporter Service
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=blackbox
Group=blackbox
ExecStart=/usr/local/bin/blackbox_exporter \
  --config.file=/etc/blackbox/blackbox.yml \
  --web.listen-address=":9115"

Restart=always

[Install]
WantedBy=multi-user.target
EOF"

# Restart Service
echo "${GREEN}Restarting Service...${NC}"
sudo systemctl daemon-reload
sudo systemctl enable blackbox.service
sudo systemctl start blackbox.service

echo "${GREEN}Installation complete. Blackbox Exporter is running as a service in port 9115.${NC}"