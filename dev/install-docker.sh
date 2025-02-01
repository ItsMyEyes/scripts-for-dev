#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
    print_error "This script must be run as root (sudo)"
    exit 1
fi

# Get username as parameter
if [ -z "$1" ]; then
    print_error "Please provide a username as parameter"
    echo "Usage: $0 username"
    exit 1
fi

USERNAME=$1

# Check if user exists
if ! id "$USERNAME" &>/dev/null; then
    print_error "User $USERNAME does not exist"
    exit 1
fi

print_message "Starting Docker installation..."

# Update system
print_message "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install prerequisites
print_message "Installing prerequisites..."
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# Add Docker's official GPG key
print_message "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
print_message "Setting up Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
print_message "Installing Docker..."
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start and enable Docker service
print_message "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add user to docker group
print_message "Adding $USERNAME to docker group..."
usermod -aG docker $USERNAME

# Verify installation
if systemctl is-active --quiet docker; then
    print_message "Docker service is running"
else
    print_error "Docker service failed to start"
    exit 1
fi

# Print Docker version
print_message "Docker version:"
docker --version

print_message "Docker installation completed successfully!"
print_warning "Please log out and log back in for group changes to take effect"
print_message "You can test Docker with: docker run hello-world"

# Print user instructions
echo -e "\n${GREEN}Post-installation steps:${NC}"
echo "1. Log out and log back in to apply group changes"
echo "2. Test Docker with: docker run hello-world"
echo "3. Check Docker service status with: systemctl status docker"
echo "4. View Docker info with: docker info"