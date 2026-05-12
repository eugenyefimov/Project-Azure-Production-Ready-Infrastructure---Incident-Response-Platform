# Policy Evidence Guidance

Purpose: provide reviewer-verifiable governance evidence tied to Terraform policy assignments.

## Expected artifacts

- `azure-policy-compliance-export-template.csv`
- optional screenshot export notes (compliance view + assignment details)
- links to relevant policy assignment names used by Terraform

## Status labeling rule

Use one of:
- `Status: Real Sanitized Export`
- `Status: Simulated/Sanitized Sample`

## Required fields for credibility

- policy assignment name
- policy definition name
- scope (resource group or subscription)
- compliance state
- timestamp
- remediation/exemption note (if any)

## Sanitization

- redact subscription IDs and object IDs
- keep policy names and compliance outcomes unchanged
