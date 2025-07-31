#!/bin/bash

# Exit on any error
set -e

# Update system package index
echo "Updating package index..."
sudo apt update

# Install required dependencies
echo "Installing prerequisites..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common gnupg

# Add Docker’s official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the Docker stable repository
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index with Docker packages
echo "Updating packages again after adding Docker repo..."
sudo apt update

# Show available Docker versions
apt-cache policy docker-ce

# Install Docker Engine and Docker Compose Plugin
echo "Installing Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin docker-compose

# Enable and start Docker service
echo "Starting Docker service..."
sudo systemctl enable --now docker

# Add current user and ubuntu user to docker group
echo "Adding users to 'docker' group..."
sudo usermod -aG docker $USER
sudo usermod -aG docker ubuntu

# Docker Compose version check
echo "Checking Docker Compose version..."
docker compose version

echo "ℹ️ You may need to re-login or run ' su - \$USER ' to apply Docker group permissions."