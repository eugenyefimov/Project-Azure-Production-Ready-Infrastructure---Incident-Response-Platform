# Runbook: Network Connectivity Issue

## Symptoms

- Service intermittently unreachable between subnets.
- Packet loss, high latency, or asymmetric connectivity.
- One protocol/port works, another fails.

## Possible Causes

- NSG rule conflict or wrong priority/order.
- UDR sends traffic to wrong next hop.
- DNS resolution causes wrong destination.
- Host firewall blocks east-west traffic.
- Changed subnet, NIC, or peering configuration.

## Azure Checks

1. Validate source and destination NIC effective NSG rules.
2. Validate effective route tables on affected NICs.
3. Check VNet/subnet configuration drift (address overlap, peering).
4. Use Network Watcher:
   - `IP flow verify`
   - `Connection troubleshoot`
   - `Topology`
5. Review Activity Log for network resource changes.

## CLI Checks

```bash
az network nic show-effective-nsg -g <rg> -n <src-nic>
az network nic show-effective-route-table -g <rg> -n <src-nic>
az network watcher test-connectivity -g <rg> --source-resource <src-vm-id> --dest-address <dest-ip-or-fqdn> --dest-port <port>
az network watcher test-ip-flow -g <rg> --vm <dest-vm-name> --direction Inbound --protocol TCP --local <dest-private-ip>:<port> --remote <src-private-ip>:50000
```

## OS-Level Checks

- Linux:
  - `ping`, `traceroute`, `mtr`
  - `nc -vz <dest> <port>`
  - `ip route`, `ss -lntp`
- Windows:
  - `Test-NetConnection <dest> -Port <port>`
  - `tracert <dest>`
  - `Get-NetRoute`, `netstat -ano`

## Root Cause Analysis

1. Reproduce from source host and confirm failing hop/control.
2. Compare intended flow matrix vs actual effective rules/routes.
3. Identify exact deny point (NSG, UDR, firewall, listener).
4. Tie failure to config drift/change and document blast radius.

## Fix Steps

1. Correct NSG rule scope/priority with least-privilege intent.
2. Fix route table next hop or remove invalid route.
3. Open host firewall only for required source/port.
4. Validate bidirectional connectivity and app-level readiness.

## Prevention

- Maintain documented traffic matrix per subnet/workload.
- Use IaC policy checks for risky NSG/UDR changes.
- Add automated connectivity tests after infra changes.
- Alert on sudden drops in connection success/latency SLO.

## Communication Summary

"I troubleshoot networking from flow intent to effective enforcement. I verify NSG and routing on both ends, use Network Watcher to pinpoint the deny location, then apply minimal policy corrections and add automation to detect regression early."
