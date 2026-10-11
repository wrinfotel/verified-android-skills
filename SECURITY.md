# Security Policy

Agent skills are executed-context content: they steer an AI agent that runs
commands on your machine. Treat them like dependencies.

## Reporting

- Suspected malicious content, prompt injection, or a check that masks a
  real problem: open a private security advisory (GitHub "Report a
  vulnerability") or email the address on the repo profile.
- Response target: 72 hours.

## What this repository does

- All checks are readable shell scripts — audit them like any script.
- No network access, no telemetry, no install hooks. Skills are text;
  `verify.sh` only reads your source files.

## Supply-chain stance

- Every rule links its primary source in `references/`.
- Every check is covered by the selftest contract (fire on bad, quiet on
  good). A check with no fixture is treated as unverified and removed.
