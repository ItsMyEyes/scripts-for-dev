#!/bin/bash

# Script to install amazon-efs-utils on Debian 12 (Bookworm)

# --- Configuration ---
EFS_UTILS_REPO="https://github.com/aws/efs-utils"
EFS_UTILS_DIR="efs-utils"
PYTHON_TARGET_DIR="/usr/lib/python3/dist-packages" # Common path for system-wide Python packages on Debian

# --- Functions ---

log() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $1"
}

error_exit() {
    log "ERROR: $1"
    exit 1
}

# --- Pre-checks ---
if [[ "$EUID" -ne 0 ]]; then
    error_exit "This script must be run with root privileges (sudo)."
fi

log "Starting amazon-efs-utils installation script for Debian 12..."

# --- Step 1: Update system and install dependencies ---
log "Step 1: Updating system and installing build dependencies..."
if ! apt update; then
    error_exit "Failed to update apt package lists."
fi

REQUIRED_DEPS="git binutils rustc cargo pkg-config libssl-dev gettext nfs-common python3-pip"
for dep in $REQUIRED_DEPS; do
    if ! dpkg -s "$dep" &> /dev/null; then
        log "Installing missing dependency: $dep"
        if ! apt install -y "$dep"; then
            error_exit "Failed to install dependency: $dep. Please check your internet connection or apt sources."
        fi
    else
        log "Dependency already installed: $dep"
    fi
done

# --- Step 2: Clone the amazon-efs-utils repository ---
log "Step 2: Cloning the amazon-efs-utils repository..."
if [ -d "$EFS_UTILS_DIR" ]; then
    log "Removing existing $EFS_UTILS_DIR directory..."
    rm -rf "$EFS_UTILS_DIR" || error_exit "Failed to remove existing $EFS_UTILS_DIR."
fi

if ! git clone "$EFS_UTILS_REPO"; then
    error_exit "Failed to clone the EFS utils repository."
fi

if ! cd "$EFS_UTILS_DIR"; then
    error_exit "Failed to change directory to $EFS_UTILS_DIR."
fi

# --- Step 3: Build the Debian package ---
log "Step 3: Building the Debian package..."
if ! ./build-deb.sh; then
    error_exit "Failed to build the Debian package for amazon-efs-utils."
fi

# --- Step 4: Install the generated Debian package ---
log "Step 4: Installing the generated Debian package..."
DEB_PACKAGE=$(find build -name "amazon-efs-utils*.deb" | head -n 1)
if [ -z "$DEB_PACKAGE" ]; then
    error_exit "Could not find the generated .deb package in the 'build' directory."
fi

log "Found Debian package: $DEB_PACKAGE"
if ! apt install -y "$DEB_PACKAGE"; then
    error_exit "Failed to install the amazon-efs-utils Debian package."
fi

# --- Step 5: Install botocore for CloudWatch logging (Optional but recommended) ---
log "Step 5: Installing botocore for CloudWatch logging..."
if ! pip3 install botocore --target "$PYTHON_TARGET_DIR"; then
    log "WARNING: Failed to install botocore. CloudWatch logging for EFS mounts may not work. You can try installing it manually: sudo pip3 install botocore --target $PYTHON_TARGET_DIR"
fi

# --- Step 6: Enable CloudWatch logging in efs-utils.conf (Optional) ---
log "Step 6: Enabling CloudWatch logging in /etc/amazon/efs/efs-utils.conf..."
if [ -f "/etc/amazon/efs/efs-utils.conf" ]; then
    if ! sed -i -e '/\[cloudwatch-log\]/{N;s/# enabled = true/enabled = true/}' /etc/amazon/efs/efs-utils.conf; then
        log "WARNING: Failed to enable CloudWatch logging in efs-utils.conf. You may need to do this manually."
    else
        log "CloudWatch logging enabled successfully."
    fi
else
    log "WARNING: /etc/amazon/efs/efs-utils.conf not found. Skipping CloudWatch logging configuration."
fi

log "amazon-efs-utils installation completed successfully."
log "You can now mount your EFS file system, for example:"
log "  sudo mkdir -p /mnt/efs"
log "  sudo mount -t efs -o tls fs-your-filesystem-id:/ /mnt/efs"
log "Remember to attach an IAM policy (AmazonElasticFileSystemsUtils) to your EC2 instance if applicable."

cd ../ # Go back to the original directory
