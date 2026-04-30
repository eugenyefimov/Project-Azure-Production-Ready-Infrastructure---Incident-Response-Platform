# Runbook: SSH Failure

## Symptoms

- `Permission denied (publickey)` or authentication timeout.
- SSH handshake starts but session closes immediately.
- Works from one source CIDR but fails from another.

## Possible Causes

- Wrong username or private key mismatch.
- Key not present in `authorized_keys`.
- NSG blocks source CIDR on port `22`.
- Linux SSH daemon down or misconfigured.
- Host firewall denies SSH.

## Azure Checks

1. Confirm VM has reachable IP path and NSG allows TCP/22 from trusted CIDR.
2. Validate NIC effective NSG and route table.
3. Review Activity Log for VM extension/config changes.
4. Use serial console if SSH path is broken.

## CLI Checks

```bash
az network nic show-effective-nsg -g <rg> -n <nic-name>
az network watcher test-ip-flow -g <rg> --vm <vm-name> --direction Inbound --protocol TCP --local <vm-private-ip>:22 --remote <client-ip>:50000
ssh -i ~/.ssh/<key> <user>@<public-ip> -vvv
```

## OS-Level Checks

- `sudo systemctl status ssh` (or `sshd`)
- `sudo sshd -t` (config validation)
- `sudo cat /etc/ssh/sshd_config | rg "PasswordAuthentication|PubkeyAuthentication|AllowUsers"`
- `sudo ls -la /home/<user>/.ssh/authorized_keys`
- `sudo journalctl -u ssh --since "1 hour ago"`
- `sudo ufw status`

## Root Cause Analysis

1. Determine whether failure is network path vs auth path.
2. If auth failure, verify key fingerprint alignment and account permissions.
3. Check when SSH config or keys changed and by whom.
4. Record exact error from client verbose logs and server logs.

## Fix Steps

1. Correct SSH key and username mapping.
2. Restore valid `authorized_keys` permissions (`700` dir, `600` file).
3. Re-enable/repair SSH daemon config and restart service.
4. Confirm NSG source CIDR includes support/admin egress IP.
5. Retest with `ssh -vvv` and capture success evidence.

## Prevention

- Enforce key-only SSH via baseline image and IaC policy.
- Keep break-glass access via serial console procedure.
- Rotate keys regularly and audit stale keys.
- Add config lint checks for `sshd_config` in image pipeline.

## Communication Summary

"For SSH incidents, I separate transport from authentication first. If TCP/22 is open but auth fails, I inspect key/user mapping and `sshd` logs. I fix the smallest secure control (key, config, or NSG CIDR) and then harden with key rotation and automated config checks."
