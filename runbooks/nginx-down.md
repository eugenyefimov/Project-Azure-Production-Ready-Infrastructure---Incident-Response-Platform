# Runbook: Nginx Down

## Symptoms

- HTTP endpoint times out or returns `5xx`.
- VM reachable by SSH, but web service unavailable.
- Monitoring alert for service or CPU spikes tied to web traffic.

## Possible Causes

- Nginx process stopped or failed to start.
- Port `80` blocked by NSG or host firewall.
- Disk full prevents logs/pid/temp files.
- Config error after change/deployment.
- Upstream dependency failure (if reverse proxy).

## Azure Checks

1. Confirm VM is healthy and reachable via SSH.
2. Verify application subnet NSG allows intended HTTP source CIDRs.
3. Check CPU/memory/disk metrics for resource pressure.
4. Review recent deployment/change events.

## CLI Checks

```bash
curl -I http://<public-ip>
az monitor metrics list --resource <vm-id> --metric "Percentage CPU"
az network watcher test-ip-flow -g <rg> --vm <vm-name> --direction Inbound --protocol TCP --local <vm-private-ip>:80 --remote <client-ip>:50000
```

## OS-Level Checks

- `sudo systemctl status nginx`
- `sudo nginx -t`
- `sudo ss -lntp | rg ":80"`
- `sudo tail -n 100 /var/log/nginx/error.log`
- `df -h` and `free -m`
- `curl -I http://127.0.0.1`

## Root Cause Analysis

1. Identify if issue is network reachability vs service health.
2. If service issue, inspect config and logs around failure timestamp.
3. Correlate with recent package/config/image changes.
4. Document triggering event and why safeguards did not prevent impact.

## Fix Steps

1. Fix configuration errors and validate (`nginx -t`).
2. Restart Nginx (`sudo systemctl restart nginx`).
3. Free disk/resources if capacity issue.
4. Correct NSG/host firewall rule if ingress blocked.
5. Validate externally and internally, then close alert.

## Prevention

- Add health probes and synthetic checks.
- Add pre-deploy config validation (`nginx -t`) in CI/CD.
- Track disk usage and log rotation.
- Use staged rollout/canary for config changes.

## Communication Summary

"I treat Nginx incidents as layered checks: network path, process status, config validity, and dependency health. I restore service quickly with validated rollback/restart and then add guardrails like config linting and health probes."
