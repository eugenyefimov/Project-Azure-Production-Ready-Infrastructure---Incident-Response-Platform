# Network Parity Checks (Post-Restore)

Goal:
- verify the restored VM NIC and DNS settings match the **current baseline** used for the app VM in this repo

## What to validate

### 1) NIC attachment and subnet placement
- restored NIC is attached to expected subnet
- NSG association matches the app baseline NSG for that subnet

### 2) Effective routes and DNS settings
- check effective route table expectations
- check DNS settings inherited on the restored NIC are correct

### 3) Resolve mismatch evidence
- if mismatch occurs (common with restored template drift), remediate and re-run service + monitoring checks

## Azure verification commands (examples)

```bash
az network nic show --ids <restored-nic-id> \
  --query "{privateIp:ipConfigurations[0].privateIpAddress,dns:ipConfigurations[0].privateDnsZoneConfigs,customDns:dnsSettings}" \
  -o json

az network nic show-effective-nsg -g <drill-rg> -n <nic-name> -o json

az network nic show-effective-route-table -g <drill-rg> -n <nic-name> -o json
```

## Evidence placeholders
- `screenshots/restored-nic.png` (optional)

