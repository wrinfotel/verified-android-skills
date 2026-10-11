#!/usr/bin/env bash
# check_baseline_profile.sh <project-root>
# FLAGS: release build without a baseline profile.
# Rule: SKILL.md §4 — baseline profile is the highest-leverage release setting.
# PASS when ANY of: baseline-prof*.txt present, or `androidx.baselineprofile`
# plugin referenced in Gradle files / version catalogs.
set -uo pipefail
root="${1:?usage: check_baseline_profile.sh <project-root>}"
[ -d "$root" ] || { echo "ERROR: not a directory: $root" >&2; exit 2; }

if find "$root" -name 'baseline-prof*.txt' -not -path '*/build/*' 2>/dev/null | head -n1 | grep -q .; then
  echo "PASS check_baseline_profile (baseline-prof file present)"
  exit 0
fi
if grep -rq 'androidx.baselineprofile' "$root" --include='*.gradle' --include='*.gradle.kts' --include='*.toml' 2>/dev/null; then
  echo "PASS check_baseline_profile (androidx.baselineprofile plugin present)"
  exit 0
fi
# Gate: only a Gradle module/project can be a "release build" — a bare
# source directory (e.g. app/src/main/java) cannot carry baseline profiles
# or Gradle plugins, so flagging it would be a false positive.
if ! find "$root" -maxdepth 3 \( -name 'build.gradle' -o -name 'build.gradle.kts' \) 2>/dev/null | head -n1 | grep -q .; then
  echo "PASS check_baseline_profile (no Gradle build files found — run this check at project root)"
  exit 0
fi
echo "FAIL check_baseline_profile: no baseline-prof*.txt and no androidx.baselineprofile plugin found."
echo "  See https://developer.android.com/topic/performance/baselineprofiles"
exit 1
