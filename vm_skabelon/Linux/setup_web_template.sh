#!/bin/bash

# ==============================================================================
# Script to set up a Debian/Ubuntu VM as a WEB SERVER template.
#
# This script installs:
#  1. Base packages for Proxmox/Ansible compatibility.
#  2. Role-specific packages for an Apache web server.
#
# Run this script with sudo:
# sudo ./setup_web_template.sh
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

# --- 2. Role-Specific Packages: Web Server ---
echo ">>> (2/2) Installing Apache2..."
apt-get install -y \
    apache2

echo ">>> Apache2 installed."

echo ""
echo "=========================== WEB SERVER TEMPLATE SETUP COMPLETE ==========================="
echo "This VM is now ready to be converted into a web server template."
echo "Remember to copy any website files to /var/www/html/ if needed before creating the template."
echo "========================================================================================="
