# Runbook: VM Not Reachable

## Symptoms

- VM cannot be reached over SSH/RDP/HTTP.
- Monitoring shows heartbeat gaps or VM availability alerts.
- Connection times out (not immediate auth failure).

## Possible Causes

- VM is stopped/deallocated or failed provisioning.
- Public IP missing, changed, or not attached to NIC.
- NSG/UDR/firewall blocks traffic path.
- Guest OS network stack issue or host firewall deny.
- Service on target port not listening.

## Azure Checks

1. Check VM power state and recent Activity Log events.
2. Confirm NIC, private IP, and Public IP association.
3. Verify subnet + NIC effective NSG rules for target port.
4. Validate effective routes (unexpected UDR next hop).
5. Use Network Watcher `IP flow verify` and `Connection troubleshoot`.
6. Check boot diagnostics / serial console for startup failures.

## CLI Checks

```bash
az vm get-instance-view -g <rg> -n <vm-name> --query "instanceView.statuses[].displayStatus"
az vm show -g <rg> -n <vm-name> --show-details --query "{privateIps:privateIps,publicIps:publicIps,powerState:powerState}"
az network nic show-effective-nsg -g <rg> -n <nic-name>
az network nic show-effective-route-table -g <rg> -n <nic-name>
az network watcher test-ip-flow -g <rg> --vm <vm-name> --direction Inbound --protocol TCP --local <vm-private-ip>:<port> --remote <client-ip>:50000
```

## OS-Level Checks

- Linux:
  - `ip a`, `ip route`
  - `ss -lntp`
  - `sudo systemctl status ssh nginx`
  - `sudo ufw status` or `sudo iptables -L -n`
- Windows:
  - `ipconfig /all`, `route print`
  - `Get-NetTCPConnection -State Listen`
  - `Get-Service TermService`
  - `Get-NetFirewallProfile`, `Get-NetFirewallRule`

## Root Cause Analysis

1. Build timeline: first failure alert, last known good connection, recent changes.
2. Map traffic path: Client -> Public IP -> NIC -> NSG -> subnet route -> host firewall -> service.
3. Identify first control point where packet/connection is denied.
4. Link failure to change or platform event with evidence (Activity Log, config diff, alert).

## Fix Steps

1. Recover VM state (start/redeploy) if unavailable.
2. Correct IP/NIC attachment if detached or replaced.
3. Fix NSG/route/firewall rules to allow intended least-privilege flow.
4. Restart required service and verify listening port.
5. Validate end-to-end from trusted source and close incident with evidence.

## Prevention

- Add alerts for VM availability + failed connection probes.
- Enforce baseline NSG policies with IaC + code review.
- Run regular connectivity smoke tests after deployments.
- Keep golden troubleshooting scripts for Network Watcher diagnostics.

## Communication Summary

Use a structured triage story:

"I isolate reachability layer by layer: Azure control plane, network policy plane, then guest OS/service plane. I use Azure diagnostics (`effective NSG`, `effective routes`, `IP flow verify`) to pinpoint the drop point quickly, apply a minimal fix, and then add preventive checks/alerts to avoid recurrence."
