#!/bin/bash

# Exit script on any error
set -e

echo "============================================="
echo "Removing existing Docker installation..."
echo "============================================="

# Stop Docker service if running
sudo systemctl stop docker || true

# Uninstall Docker packages and dependencies
sudo apt purge -y docker-ce docker-ce-cli containerd.io docker.io docker-doc docker-compose podman-docker containerd runc || true

# Remove Docker's associated directories
echo "Removing Docker directories..."
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo rm -rf /etc/docker
sudo rm -rf ~/.docker

# Remove any dangling network configurations
echo "Removing Docker network configurations..."
sudo ip link delete docker0 || true
sudo ip link delete br-$(docker network ls --filter "driver=bridge" -q) || true

# Clean up remaining packages
echo "Cleaning up residual files..."
sudo apt autoremove -y
sudo apt autoclean

echo "============================================="
echo "Docker has been completely removed."
echo "Starting fresh installation..."
echo "============================================="

# Step 1: Install required dependencies
sudo apt update -y && sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Step 2: Add Docker's official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Step 3: Set up the Docker repository
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 4: Install Docker
echo "Installing Docker..."
sudo apt update -y && sudo apt install -y docker-ce docker-ce-cli containerd.io

# Step 5: Enable and start Docker
echo "Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Step 6: Add current user to Docker group (to run without sudo)
echo "Adding current user to Docker group..."
sudo usermod -aG docker $USER

echo "============================================="
echo "Docker has been successfully installed!"
echo "You might need to log out and log back in."
echo "Test Docker by running: docker run hello-world"
echo "============================================="

exit 0
