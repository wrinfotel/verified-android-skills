# verified-android-skills

[![verify](https://github.com/wrinfotel/verified-android-skills/actions/workflows/verify.yml/badge.svg)](https://github.com/wrinfotel/verified-android-skills/actions/workflows/verify.yml)

Verified Android & Compose skills for AI coding agents — every skill ships
with machine-readable checks, so your agent **proves its work** instead of
claiming it.

<!-- TODO(demo): hero GIF <5MB — agent fixes a recomposition bug, runs
     verify.sh, output shows PASS. Record with VHS/asciinema before launch. -->

## Install (30 seconds)

```bash
npx skills add wrinfotel/verified-android-skills
```

or copy `skills/` into your loader of choice: `~/.claude/skills`,
`.cursor/rules`, `AGENTS.md` include, plugin marketplace manifest.

## What's inside

| Skill | What it enforces | Verified by |
|---|---|---|
| `compose-performance` | stability, deferred reads, lazy keys, baseline profiles | 3 checks + selftest |
| `compose-architecture` | layer separation, UDF, ViewModel scoping, lifecycle-aware collection | 4 checks + selftest |
| `compose-testing` | synchronization without sleeps, rule choice, ui-test deps, semantics assertions | 3 checks + selftest |
| `compose-migration` | ComposeView strategy, AndroidView factory/update, XML interop, migration order | 3 checks + selftest |
| `kmp-fundamentals` | source-set discipline, expect/actual placement and balance | 3 checks + selftest |
| `compose-multiplatform` | shared UI, Res resources, Android-only API isolation, no Fragments | 3 checks + selftest |
| `gradle-build-logic` | version catalogs, KSP over kapt, R8 release, build-speed flags | 4 checks + selftest |
| `android-testing` | test dependency scopes, Robolectric placement, ActivityScenarioRule, Espresso sync | 4 checks + selftest |
| `dependency-injection` | Hilt entry points, @HiltViewModel @Inject constructor, provider placement, no ViewModel-to-ViewModel | 4 checks + selftest |
| `offline-first` | repositories as data-layer entry, Room main thread, destructive migration, DataStore per file | 4 checks + selftest |
| `material3-theming` | theme tokens over hardcodes, no M2 imports/accessors, theme-file exclusions | 4 checks + selftest |
| `release-engineering` | release hardening: no debug tooling/signing, cleartext, android:exported | 4 checks + selftest |

## Why verified

Post-supply-chain, agent skills are audited like dependencies. Here every
rule is grounded in official AndroidX documentation (`references/`) and
carries deterministic checks (`checks/`) your agent runs after every edit:

```bash
./verify.sh app/src/main/java
#  compose-architecture  check_no_data_layer_in_ui.sh  PASS
#  compose-architecture  check_viewmodel_construction.sh PASS
#  compose-performance   check_no_var_in_ui_state.sh   PASS
#  compose-performance   check_immutable_collections.sh FAIL ...
```

CI runs the same checks plus a selftest (checks must fire on bad fixtures
and stay quiet on good ones) on every commit.

## Compatibility

Claude Code · Codex · Cursor · Gemini CLI · Windsurf
(loader matrix maintained in docs/verification.md)

## License

MIT. Skill coverage informed by Apache-2.0/MIT open-source projects and
official Android documentation — see NOTICE.

If this saved you a recomposition bug, consider a star ⭐
