#!/bin/bash

# Jenkins setup script for Ubuntu/Debian
# Creates swap, installs Java 21, adds Jenkins repo (2026 key), installs Jenkins

set -e  # Exit on any error

echo "=== Starting Jenkins setup ==="

# 1. Create 2GB swap file
echo "Creating 2GB swap file..."
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make swap permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify swap
echo "Swap status:"
free -h

# 2. Install Java 21
echo "Installing OpenJDK 21..."
sudo apt update
sudo apt install -y openjdk-21-jdk

echo "Java version installed:"
java -version

# 3. Add Jenkins repository with 2026 GPG key
echo "Adding Jenkins repository (2026 key)..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian/jenkins.io-2026.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 4. Install Jenkins
echo "Installing Jenkins..."
sudo apt update
sudo apt install -y jenkins

# 5. Reload systemd and start Jenkins
echo "Starting Jenkins service..."
sudo systemctl daemon-reload
sudo systemctl restart jenkins

# 6. Check status
echo "Jenkins service status:"
sudo systemctl status jenkins --no-pager

echo "=== Setup complete! ==="
echo "Access Jenkins at http://$(curl -s ifconfig.me):8080"
echo "Initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password file not ready yet. Wait a few seconds and run: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"