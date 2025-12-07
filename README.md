# Ansible Proxmox: Automated Windows 11 Control Node Deployment

This Ansible project automates the deployment of four identical Windows 11 virtual machines on a Proxmox VE host. These VMs are intended to be used as Ansible control nodes for educational or lab purposes, pre-configured with Windows Subsystem for Linux (WSL), Ubuntu, and Ansible.

The process is fully interactive, requiring no manual editing of configuration files before execution.

## Features

-   **Interactive Setup**: The playbook prompts for all necessary information, such as Proxmox credentials, hostnames, and user details for the new VMs.
-   **No Hardcoded Secrets**: Credentials are handled via interactive prompts and are not stored in the project files.
-   **Automated VM Creation**: Deploys four Windows 11 VMs from a specified Proxmox template.
-   **Cloud-Init Configuration**: Uses Cloud-Init to set up a local user, password, and run a PowerShell script to prepare the VM for WinRM management.
-   **Dynamic Inventory**: Includes a dynamic inventory script to automatically discover and group the created VMs based on their Proxmox tags.
-   **Automated Node Configuration**: A second playbook installs WSL, Ubuntu, and Ansible on the newly created Windows VMs.

---

## Prerequisites

Before you begin, ensure you have the following installed on your local machine:

1.  **Python 3.8+**: Ansible is built on Python. You can download it from the [official Python website](https://www.python.org/downloads/) or install it via the Microsoft Store.
2.  **Git**: For cloning this repository.
3.  **Proxmox VE**: A running Proxmox server with a prepared Windows 11 template. See notes on template preparation below.

### Proxmox Template Requirements

Your Proxmox VM template **must** have the following:

-   **Cloud-Init Guest Agent**: Installed and enabled. This is crucial for the setup automation to work. For Windows, you can get the drivers from the [Fedora VirtIO-Win ISO](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso).
-   The name of this template will be requested by the playbook.

---

## Setup Instructions

Follow these steps to set up the project on your Ansible control machine (your local computer).

**1. Clone the Repository**

```bash
git clone <URL_of_your_Git_repository>
cd Ansible_Gruppe4
```

**2. Create and Activate a Python Virtual Environment**

It is highly recommended to use a virtual environment to avoid conflicts with system-wide packages.

From the project root directory (`Ansible_Gruppe4`):

```powershell
# Create the virtual environment
python -m venv venv

# Activate the virtual environment (for PowerShell)
.\venv\Scripts\Activate.ps1
```
*Note: If you use a different shell like Command Prompt or Git Bash, the activation command will be different (e.g., `venv\Scripts\activate.bat`).*

**3. Install Dependencies**

Install the required Python packages and Ansible collections.

```bash
# Install Python packages
pip install -r requirements.txt

# Install Ansible collections
ansible-galaxy collection install -r requirements.yml
```

---

## Execution

The deployment is a two-stage process:

1.  **Create the VMs**: Run the `create_control_nodes.yml` playbook.
2.  **Configure the VMs**: Run the `configure_control_nodes.yml` playbook.

### Step 1: Create the Control Node VMs

This playbook will interactively ask for all the necessary information to create the four Windows 11 VMs.

Run the following command:

```bash
ansible-playbook playbooks/create_control_nodes.yml
```

The playbook will prompt you for:
-   Proxmox Host IP or FQDN.
-   Proxmox API credentials.
-   The name of your Windows 11 template.
-   The target Proxmox node.
-   A starting VMID.
-   A unique name, username, and password for each of the four VMs.

### Step 2: Configure the Control Nodes

This playbook uses the dynamic inventory to find the VMs you just created. It will connect to them using WinRM and install WSL, Ubuntu, and Ansible.

First, you need to provide the administrator password for the Windows VMs that will be configured. This is done via a prompted variable.

Run the playbook using the **dynamic inventory** file:

```bash
ansible-playbook -i inventory_proxmox.yml playbooks/configure_control_nodes.yml
```

This playbook will prompt for the administrator password of the target Windows VMs to perform the software installation. Once complete, all four nodes will be ready to use as Ansible control nodes.
