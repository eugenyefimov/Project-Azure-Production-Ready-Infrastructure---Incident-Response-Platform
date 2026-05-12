# Contributing

Thanks for improving this Cloud Operations portfolio repository.

## Branch and PR expectations

- Use feature branches from `main`.
- Keep pull requests small and reviewable.
- Describe what changed, why, and how it was verified.

## Security and secret hygiene

- Never commit credentials, tokens, private keys, or state files.
- Keep sensitive values in secure CI variables/secrets only.
- Scope secrets to the minimum required job/step in workflows.

## Evidence sanitization standards

- Evidence must be clearly labeled:
  - `Status: Simulated/Sanitized Sample` or
  - `Status: Real Sanitized Export`
- Replace identifiers/IPs/emails with sanitized placeholders where needed.
- Preserve operational sequence and realism without exposing live tenant/customer data.

## Documentation standards

- Keep claims honest: use `Implemented`, `Partial`, `Simulated/Sanitized`, `Planned`.
- Update reviewer-facing docs when behavior changes:
  - `README.md`
  - `REVIEWER-QUICKSTART.md`
  - `docs/handbook/claims-to-implementation.md`
