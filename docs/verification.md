# Verification — how checks work

## Philosophy

A skill that only *claims* correctness is a dependency without a lockfile.
Every rule in this repository therefore carries a deterministic check:

- **Deterministic** — same input, same verdict; no model in the loop.
- **Fast** — static analysis (grep/awk level), runs in CI on every commit.
- **Advisory heuristics** — they catch the *documented* anti-patterns from
  `references/`, not every perf bug. They are a floor, not a ceiling.

## The selftest contract

`./verify.sh --selftest` enforces the only rule that keeps a check honest:

- every check **must fire** on its skill's `fixtures/sample-bad/`
- every check **must stay quiet** on `fixtures/sample-good/`

A check that fails either side is marked `DEAD CHECK` / `FALSE POSITIVE`
and CI fails. This is what "verified" means here — nothing more, and
nothing less.

## Limitations (known, deliberate)

- Static text heuristics: no type resolution, no cross-module visibility.
- False negatives are possible (multiline/complex code shapes).
- False positives are treated as bugs — file an issue with the snippet.

For deep verification use the Compose compiler metrics report and a
macrobenchmark: https://developer.android.com/jetpack/compose/performance

## Compatibility matrix

| Loader | Install path | Status |
|---|---|---|
| Claude Code | `~/.claude/skills/` or plugin marketplace | tested |
| Codex | `AGENTS.md` include / skills dir | tested |
| Cursor | `.cursor/rules/` | compatible |
| Gemini CLI | skills loader | compatible |
| Windsurf | rules dir | compatible |

*Matrix updated per release; `npx skills add` covers all of them.*
