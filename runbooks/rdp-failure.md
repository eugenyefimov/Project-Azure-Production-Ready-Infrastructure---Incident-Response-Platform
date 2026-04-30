# Runbook: RDP Failure

## Symptoms

- RDP client cannot connect (`Remote desktop can't connect...`).
- Credentials prompt appears, then login fails.
- Intermittent disconnects after successful login.

## Possible Causes

- NSG does not allow trusted source CIDR on `3389`.
- VM not running or Public IP changed.
- `TermService` stopped or RDP disabled on guest.
- Windows Firewall blocks RDP.
- Account lockout, expired password, or policy restrictions.

## Azure Checks

1. Check VM state and Public IP/NIC attachment.
2. Verify management subnet NSG allows `3389` only from trusted CIDRs.
3. Run Network Watcher `IP flow verify` for TCP/3389.
4. Review boot diagnostics if VM seems up but guest unresponsive.

## CLI Checks

```bash
az vm show -g <rg> -n <vm-name> --show-details --query "{powerState:powerState,publicIps:publicIps}"
az network nic show-effective-nsg -g <rg> -n <nic-name>
az network watcher test-ip-flow -g <rg> --vm <vm-name> --direction Inbound --protocol TCP --local <vm-private-ip>:3389 --remote <client-ip>:50000
```

## OS-Level Checks

- `Get-Service TermService`
- `Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name fDenyTSConnections`
- `Get-NetFirewallRule -DisplayGroup "Remote Desktop"`
- Event Viewer:
  - `Security` (login failures)
  - `System` (service/network issues)

## Root Cause Analysis

1. Confirm if failure is pre-auth network issue or post-auth identity issue.
2. Correlate with account lockout/policy changes.
3. Check VM patch/restart timeline and GPO changes.
4. Capture evidence: NSG result, Windows event IDs, and user/IP context.

## Fix Steps

1. Correct NSG rule source CIDR if support IP changed.
2. Re-enable RDP and start `TermService` if disabled.
3. Allow RDP in Windows Firewall profiles.
4. Unlock/reset account if login policy issue.
5. Validate connection and document the exact restoration point.

## Prevention

- Use Azure Bastion for controlled management access.
- Monitor repeated failed RDP auth attempts.
- Standardize local admin credential lifecycle and rotation.
- Maintain GPO baseline with tested RDP settings.

## Communication Summary

"I triage RDP by splitting connectivity and identity problems. First I confirm Azure path (NSG/IP flow), then guest service/firewall, then account policy. This keeps MTTR low and avoids insecure quick fixes like opening `3389` broadly."
