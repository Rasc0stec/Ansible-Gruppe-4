#!/bin/bash

# ==============================================================================
# Script to set up a Debian/Ubuntu VM as a DATABASE SERVER template.
#
# This script installs:
#  1. Base packages for Proxmox/Ansible compatibility.
#  2. Role-specific packages for a MariaDB/Galera database server.
#
# Run this script with sudo:
# sudo ./setup_db_template.sh
# ==============================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. System Update and Base Packages ---
echo ">>> (1/2) Updating package lists and installing base tools..."
apt-get update -y
apt-get install -y \
    qemu-guest-agent \
    cloud-init \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    git

# Ensure qemu-guest-agent is enabled to start on boot
systemctl enable qemu-guest-agent

echo ">>> Base tools installed."

# --- 2. Role-Specific Packages: MariaDB/Galera Database ---

echo ">>> (2/2) Installing MariaDB and Galera packages..."
# This will install the server and the Galera-4 provider for clustering.
# The `DEBIAN_FRONTEND=noninteractive` helps suppress prompts.
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    mariadb-server \
    galera-4

echo ">>> MariaDB and Galera packages installed."

echo ""
echo "=========================== DATABASE SERVER TEMPLATE SETUP COMPLETE ========================="
echo "This VM is now ready to be converted into a MariaDB/Galera database template."
echo "Remember that the database and cluster still require extensive configuration."
echo "==========================================================================================="
