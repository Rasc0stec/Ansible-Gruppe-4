#!/bin/bash

# ==============================================================================
# Script to set up a Debian/Ubuntu VM as a MAIL SERVER template.
#
# This script installs:
#  1. Base packages for Proxmox/Ansible compatibility.
#  2. Role-specific packages for Postfix and Dovecot mail server.
#
# Run this script with sudo:
# sudo ./setup_mail_template.sh
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

# --- 2. Role-Specific Packages: Mail Server (Postfix, Dovecot) ---
echo ">>> (2/2) Installing Postfix and Dovecot..."
# Postfix will prompt for configuration during installation.
# For a template, it's often better to skip initial config and do it via Ansible later.
# The `DEBIAN_FRONTEND=noninteractive` helps suppress prompts.
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    postfix \
    dovecot-imapd \
    dovecot-lmtpd \
    dovecot-sieve \
    dovecot-managesieved

echo ">>> Postfix and Dovecot installed."

echo ""
echo "=========================== MAIL SERVER TEMPLATE SETUP COMPLETE ============================"
echo "This VM is now ready to be converted into a mail server template."
echo "Remember that Postfix/Dovecot still require extensive configuration (e.g., domains, users, SSL)."
echo "==========================================================================================="
