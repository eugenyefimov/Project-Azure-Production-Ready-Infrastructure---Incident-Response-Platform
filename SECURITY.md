# Security Policy

This repository is a public portfolio project for Cloud Support / Cloud Operations roles.

## Scope

- No live credentials, tenant data, customer data, or production secrets should be committed.
- Evidence artifacts must be either:
  - `Status: Simulated/Sanitized Sample`, or
  - `Status: Real Sanitized Export`
- Real exports must be sanitized before commit.

## Prohibited content

Do not commit:

- secrets, tokens, API keys, private keys, certificates
- Terraform state files or local secret files
- live tenant identifiers, customer identifiers, or internal URLs that are not sanitized
- screenshots or logs containing sensitive metadata

## Reporting accidental exposure

If you find suspected sensitive data:

1. Open a private security report to the repository owner/maintainer.
2. Include file path, commit hash (if known), and exposure type.
3. Do not post sensitive details in a public issue.

The maintainer should remove exposed content, rotate credentials (if relevant), and document remediation.
