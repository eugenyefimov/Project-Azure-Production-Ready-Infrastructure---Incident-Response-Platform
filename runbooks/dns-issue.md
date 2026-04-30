# Runbook: DNS Issue

## Symptoms

- Host can reach IP directly but fails by hostname.
- Intermittent service failures due to name resolution.
- Increased latency/timeouts for external dependencies.

## Possible Causes

- Wrong DNS server settings on VNet/NIC/OS.
- DNS record missing/stale/incorrect TTL.
- Private DNS zone link missing to VNet.
- Conditional forwarder misconfiguration.
- DNS service outage or firewall egress block to DNS endpoint.

## Azure Checks

1. Check VNet DNS server configuration (default vs custom).
2. Validate private DNS zone records and VNet links.
3. Confirm NIC inherits expected DNS settings.
4. Review changes to DNS zones/records and network policy.

## CLI Checks

```bash
az network vnet show -g <rg> -n <vnet-name> --query "dhcpOptions.dnsServers"
az network private-dns zone list -g <rg>
az network private-dns record-set a list -g <rg> -z <zone-name>
az network private-dns link vnet list -g <rg> -z <zone-name>
nslookup <fqdn>
dig <fqdn> +short
```

## OS-Level Checks

- Linux:
  - `cat /etc/resolv.conf`
  - `resolvectl status` (systemd-resolved)
  - `nslookup <fqdn>`, `dig <fqdn>`
- Windows:
  - `ipconfig /all`
  - `Resolve-DnsName <fqdn>`
  - `ipconfig /flushdns` (if stale cache suspected)

## Root Cause Analysis

1. Determine scope: single VM, subnet, VNet, or global.
2. Compare expected resolution path with actual resolver used.
3. Validate record correctness (IP, TTL, zone, link).
4. Correlate with recent DNS/network changes and client cache behavior.

## Fix Steps

1. Correct DNS server configuration at proper scope (VNet/NIC/OS).
2. Create/fix DNS record and VNet link for private zones.
3. Flush client/server DNS cache where appropriate.
4. Validate resolution from multiple hosts/subnets.
5. Confirm dependent services recover and monitor error rate.

## Prevention

- Manage DNS records/zones via IaC with review workflow.
- Use short but controlled TTLs for dynamic endpoints.
- Add synthetic DNS resolution checks for critical FQDNs.
- Maintain dependency map of internal/external DNS zones.

## Communication Summary

"With DNS incidents, I first confirm if IP connectivity is healthy to isolate name resolution. Then I verify resolver configuration, zone/link integrity, and record correctness. I fix the authoritative source, clear stale caches carefully, and add synthetic checks to catch DNS drift early."
