# Operational Findings (Sample)

This section captures what the drill showed about operational maturity, not just whether it “worked.”

## Findings to record
- restore point age at time of restore decision (RPO realization)
- measured restore timing
- time to first reachability
- time to service stability
- time to monitoring telemetry resumption
- whether network parity matched the expected baseline without extra steps

## Example findings (template-grade placeholders)
- Restore point age: `<= 24h` (example: ~`11h`)
- Measured RTO:
  - Start (decision point): `09:00:00Z`
  - Stable (service + monitoring checks passed): `09:50:00Z`
  - **RTO (measured):** `50 minutes` (example)
- Monitoring resumption:
  - Heartbeat seen in Log Analytics within watch window (PASS) / delayed (document)
- Network parity:
  - Restored NIC matched baseline NSG and DNS settings (PASS) / mismatch detected (document)

## Evidence quality notes
- Record which evidence items were missing and why.
- Example: “Heartbeat query returned empty due to telemetry ingestion delay; closure criteria adjusted after agent status confirmed.”

