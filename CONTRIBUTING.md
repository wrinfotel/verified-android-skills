# Contributing

## Skill format (non-negotiable)

1. `SKILL.md` — terse, imperative, RIGHT/WRONG pairs, `MUST`/`MUST NOT`.
   Prose is short; code carries the load. A skill is operational
   instructions for an LLM, not documentation for humans.
2. `references/*.md` — the primary source for every rule (official Android
   documentation preferred). If a rule has no source, it doesn't ship.
3. `checks/*.sh` — one deterministic check per rule group, POSIX bash.
4. `fixtures/sample-bad/` + `fixtures/sample-good/` — the selftest contract:
   checks must fire on bad, stay quiet on good (`./verify.sh --selftest`).

## Licensing

- Original text only. Adapting ideas from other projects is fine if their
  license is permissive (MIT/Apache-2.0) — add them to NOTICE, never copy
  text verbatim without attribution and license compliance.
- Unlicensed sources are off-limits.

## Process

1. Open an issue with the anti-pattern you want to cover (real-world
   evidence: issue links, SO links, crash patterns).
2. PR with SKILL.md + references + checks + fixtures, selftest green.
3. One skill per PR.
