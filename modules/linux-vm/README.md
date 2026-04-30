# Module: linux-vm

Reusable Ubuntu VM module for application workloads.

Features:

- Ubuntu 22.04 LTS VM
- Cloud-init bootstrapping (Nginx installation and service start)
- SSH key-only authentication (`disable_password_authentication = true`)
- Standard static public IP for support and troubleshooting operations
