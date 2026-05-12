# Incident Report: Failed-First Remediation (DNS vs NSG Egress)

Status: Simulated/Sanitized Sample  
Scope: Portfolio repository. No live tenant data or customer data is included.

- **Incident ID:** `INC-2026-06-03-004`
- **Environment:** `prod`
- **Service:** `customer-api`
- **Severity:** `Sev2` (degradation, intermittent hard failures)
- **Start:** `2026-06-03 16:12 UTC`
- **Resolved:** `2026-06-03 17:01 UTC`
- **Total impact:** 49 minutes

## 1) Summary

This incident is intentionally documented as a failed-first remediation case.

- first hypothesis was wrong
- first fix looked correct and was approved
- failure evidence forced a pivot
- second approach resolved the incident

Customer symptoms looked like DNS instability at first, but root cause was NSG egress deny behavior on a newly enforced rule path.

---

## 2) Timeline (UTC)

- **16:12** - API latency jumps; 5xx starts increasing from baseline.
- **16:14** - `Sev2` alert fires: `alert-upstream-timeout-rate`.
- **16:16** - On-call assumes DNS resolver instability (similar pattern to earlier incident class).
- **16:19** - First fix approved: rotate upstream DNS resolver endpoint + flush local cache.
- **16:24** - First fix applied via change `CHG-4942`.
- **16:29** - Error rate briefly dips, then returns to pre-fix level.
- **16:33** - New signal: outbound deny counters increase on app subnet NSG.
- **16:36** - Pivot decision: DNS fix did not hold; likely egress policy fault.
- **16:40** - Second approach prepared: hotfix NSG egress rule for upstream dependency.
- **16:46** - NSG hotfix applied (`CHG-4943`).
- **16:52** - Upstream timeout errors drop sharply.
- **16:57** - P95 latency normalizes.
- **17:01** - Incident resolved after short watch window.

---

## 3) Initial Hypothesis (Wrong)

Hypothesis:

- upstream DNS resolution intermittently failing under load

Why it looked correct:

- recent history included DNS timeout incidents with similar symptom shape
- app logs showed repeated upstream timeout errors
- local resolver metrics had short spikes in lookup latency

What was missed:

- DNS lookups were slow but mostly successful
- hard request failures aligned better with blocked outbound connection attempts

---

## 4) First Fix Attempt (Failed)

## Attempted remediation

- switched resolver order to known-good secondary endpoint
- flushed resolver cache on app VM
- restarted app process to clear stale upstream sessions

Change path:

- **Change ticket:** `CHG-4942`
- **CI/CD run ID:** `10495522117`
- **Status:** `success` (execution success, outcome failure)

Commands executed:

```powershell
az network dns resolver forwarding-rule update `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --dns-forwarding-ruleset-name rs-prod-upstream `
  --name fr-upstream-api `
  --target-dns-servers 192.0.2.10 192.0.2.11

ssh ops-user@vm-app-sim-01
sudo resolvectl flush-caches
sudo systemctl restart customer-api
```

## Evidence the first fix failed

```text
16:26 UTC  timeout_rate=0.19  (temporary improvement)
16:29 UTC  timeout_rate=0.27
16:31 UTC  timeout_rate=0.31
16:33 UTC  timeout_rate=0.29
```

App log snippet:

```text
2026-06-03T16:27:04Z api[8013]: upstream lookup ok api-dependency.simulated -> 192.0.2.14
2026-06-03T16:27:05Z api[8013]: upstream connect timeout after 3000ms
2026-06-03T16:29:42Z api[8013]: upstream lookup ok api-dependency.simulated -> 192.0.2.14
2026-06-03T16:29:45Z api[8013]: upstream connect timeout after 3000ms
```

Interpretation:

- DNS resolution succeeded; connection establishment still failed.

---

## 5) Pivot Decision

Signal that proved first fix wrong:

- NSG flow logs showed increasing egress denies to upstream dependency CIDR and port.

Pivot evidence:

```text
TimeGeneratedUTC,SrcIP,DestIP,DestPort,Decision,RuleName,Hits
2026-06-03T16:31:00Z,192.0.2.9,192.0.2.14,443,Deny,deny-egress-default,184
2026-06-03T16:32:00Z,192.0.2.9,192.0.2.14,443,Deny,deny-egress-default,201
2026-06-03T16:33:00Z,192.0.2.9,192.0.2.14,443,Deny,deny-egress-default,193
```

Decision at `16:36`:

- stop DNS-focused remediation
- treat as egress policy regression
- hotfix NSG egress allow for dependency path

---

## 6) Second Approach (Successful)

Second remediation:

- added explicit allow egress rule from app subnet to dependency CIDR `192.0.2.14/32` on `443`
- kept default deny behavior for other destinations

Change path:

- **Change ticket:** `CHG-4943`
- **PR:** `hotfix/nsg-egress-dependency-allow`
- **CI/CD run ID:** `10495526492`

Commands executed:

```powershell
az network nsg rule create `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --nsg-name az-ir-platform-p-westeurope-vnet-nsg-application `
  --name allow-egress-dependency-443 `
  --priority 230 `
  --direction Outbound `
  --access Allow `
  --protocol Tcp `
  --source-address-prefixes 192.0.2.0/24 `
  --destination-address-prefixes 192.0.2.14/32 `
  --destination-port-ranges 443

az network nic list-effective-nsg `
  --resource-group az-ir-platform-p-westeurope-rg-network `
  --name az-ir-platform-p-westeurope-nic-app-01 -o table
```

---

## 7) Final Resolution Evidence

Post-fix metrics:

```text
16:52 UTC  timeout_rate=0.11
16:54 UTC  timeout_rate=0.07
16:57 UTC  timeout_rate=0.03
17:00 UTC  timeout_rate=0.02
```

Latency trend:

```text
16:35 UTC  p95=2480ms
16:45 UTC  p95=2012ms
16:55 UTC  p95=882ms
17:00 UTC  p95=641ms
```

Flow log verification:

```text
2026-06-03T16:50:00Z,192.0.2.9,192.0.2.14,443,Allow,allow-egress-dependency-443,267
2026-06-03T16:51:00Z,192.0.2.9,192.0.2.14,443,Allow,allow-egress-dependency-443,251
```

Incident closure criteria met:

- [x] timeout rate returned near baseline
- [x] latency stabilized
- [x] no new related alerts in watch window
- [x] dependency path confirmed allow in effective rules

---

## 8) Lessons Learned

- first fix can be technically clean but still wrong for the fault domain
- temporary metric dips are not proof of resolution
- connection timeout after successful DNS lookup should immediately trigger network-policy branch
- incident process must explicitly record failed remediations to prevent repeated debugging bias

Follow-up actions:

- add runbook branch: "DNS lookup success + connect timeout" -> check NSG egress early
- add alert enrichment with `faultDomainHint=network-policy` when deny counters spike
- require 10-minute stabilization check before declaring remediation success
