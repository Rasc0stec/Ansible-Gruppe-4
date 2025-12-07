# ========================================================================================
# Script: prepare_windows_for_ansible.ps1
#
# Description:
# This script configures a Windows host for remote management with Ansible using WinRM.
# It performs the necessary steps to enable and configure the WinRM service,
# set up firewall rules, and ensure basic authentication settings are in place.
#
#
# NOTE: This script is intended for lab and development environments.
# For production, consider using HTTPS with valid certificates and more secure
# authentication methods like Kerberos.
# ========================================================================================

# --- 1. Configure and Start the WinRM Service ---
Write-Host "Configuring WinRM service..."
winrm quickconfig -q

# Set the WinRM service to start automatically
Set-Service -Name "WinRM" -StartupType Automatic

# --- 2. Configure WinRM for Ansible Compatibility ---
Write-Host "Setting WinRM service configurations for Ansible..."

# Allow unencrypted communication (for lab environments)
# Ansible requires this when not using HTTPS.
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# Configure authentication
# This ensures that Ansible's default authentication methods are enabled.
winrm set winrm/config/service/auth '@{Basic="true"}'

# Increase the memory available to a remote shell
# This prevents potential errors with memory-intensive Ansible modules.
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="1024"}'


# --- 3. Configure Windows Firewall ---
Write-Host "Configuring Windows Firewall..."

# Enable the predefined "Windows Remote Management" firewall rule.
# This opens TCP port 5985 (HTTP) and 5986 (HTTPS).
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP"
Enable-NetFirewallRule -Name "WINRM-HTTP-In-TCP-PUBLIC"


# --- 4. Final Status Check ---
Write-Host "Verifying WinRM configuration..."
winrm enumerate winrm/config/listener

Write-Host "Configuration complete. The machine should now be ready for Ansible management over WinRM."
