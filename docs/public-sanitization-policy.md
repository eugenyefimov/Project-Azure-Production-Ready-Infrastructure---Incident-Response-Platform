# Public Sanitization Policy

This repository is published as a portfolio project for Cloud Support and Azure Operations roles.
It is intentionally transparent about what is real, simulated, and sanitized.

## What is real in this repository

- Terraform modules and environment roots (`environments/*`, `modules/*`)
- GitHub Actions workflow logic and deployment guardrails (`.github/workflows/*`)
- Runbook procedures and operational response flow (`runbooks/*`, `docs/handbook/*`)

## What is simulated or sample-based

- Some evidence datasets in `evidence/live-artifacts/` are sample/simulated but shaped to reflect realistic operational patterns.
- Incident walkthrough narratives may use sanitized timestamps and identifiers to protect environment details.

## What is intentionally sanitized

- Subscription, tenant, and resource identifiers in exported-style artifacts
- Endpoint values, object IDs, and operational handles
- Alert payload details that could expose internal environment structure

## What is intentionally excluded from public GitHub

- Raw incident command dumps and internal-style log bundles
- Real credentials, secret material, and local environment files
- Real tenant exports that contain non-public operational metadata

## Publication rules used for this repository

- No private keys, passwords, tokens, or state files are committed.
- Example config files are retained for reviewer usability (`*.tfvars.example`).
- Evidence is included only when it improves reviewer understanding without exposing sensitive internals.
- When uncertain, the repository prefers conservative disclosure and clear labeling.

## Reviewer note

The goal is operational credibility, not artificial scale.
This repo demonstrates support workflows and platform controls while keeping sensitive operational data out of the public domain.
