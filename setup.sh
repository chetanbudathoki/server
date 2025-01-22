#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Use current working directory
NPM_DIR="$(pwd)"

echo "Using current directory: $NPM_DIR for setup"

# Step 1: Install Docker (if not installed)
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    bash docker.sh
else
    echo "Docker is already installed, skipping installation."
fi

# Step 2: Install Docker Compose if not installed
if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    sudo apt update && sudo apt install -y docker-compose
else
    echo "Docker Compose is already installed, skipping installation."
fi

# Step 3: Firewall Configuration
echo "Configuring firewall..."
sudo ufw allow 22/tcp  # Allow SSH access
sudo ufw allow 80/tcp  # Allow HTTP traffic
sudo ufw allow 443/tcp # Allow HTTPS traffic
sudo ufw allow 81/tcp  # Allow Nginx Proxy Manager Admin UI
sudo ufw reload        # Reload firewall rules to apply changes

# Step 4: Create Necessary Directories
echo "Creating required directories..."
mkdir -p "$NPM_DIR/data" "$NPM_DIR/letsencrypt"

# Step 5: Fix Permissions for Docker Volumes
echo "Fixing directory permissions..."
sudo chown -R 1000:1000 "$NPM_DIR/data" "$NPM_DIR/letsencrypt"
sudo chmod -R 755 "$NPM_DIR/data" "$NPM_DIR/letsencrypt"

# Step 6: Start Docker Compose services
echo "Starting Nginx Proxy Manager with Docker Compose..."
docker-compose down || true
docker-compose up -d

# Step 7: Enable Docker Service on Startup
echo "Enabling Docker to start on boot..."
sudo systemctl enable docker

# Step 8: Display Access Information
echo "============================================="
echo "Nginx Proxy Manager has been installed!"
echo "Access it at: http://$(curl -s ifconfig.me):81"
echo "Default login: admin@example.com"
echo "Password: changeme"
echo "============================================="

exit 0
