#!/usr/bin/env bash
# check_expect_actual_balance.sh <kmp-src-root>
# FLAGS: name imbalance between expect and actual declarations across the
# module — an expect with no actual anywhere (forgotten platform file) and
# an actual with no expect (does not compile). Per-target coverage and
# signature matching stay the compiler's job; this is pre-compile feedback.
# Rule: SKILL.md §3.
# Source: https://kotlinlang.org/docs/multiplatform/multiplatform-expect-actual.html
#         ("every expected declaration ... has a matching actual
#          declaration in every platform-specific source set")
# Heuristic limitation: name-based (overloads with the same name count
# once). Multi-module expect/actual is out of scope — run per module.
# Full-line // comments are ignored.
set -uo pipefail
target="${1:?usage: check_expect_actual_balance.sh <kmp-src-root>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

expects=""
actuals=""
while IFS= read -r -d '' f; do
  body=$(grep -vE '^[[:space:]]*//' "$f" 2>/dev/null)
  e=$(echo "$body" | grep -oE '\bexpect[[:space:]]+(fun|val|var|class|interface|object|typealias)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' 2>/dev/null | awk '{print $NF}')
  a=$(echo "$body" | grep -oE '\bactual[[:space:]]+(fun|val|var|class|interface|object|typealias)[[:space:]]+[A-Za-z_][A-Za-z0-9_]*' 2>/dev/null | awk '{print $NF}')
  [ -n "$e" ] && expects="$expects$e"$'\n'
  [ -n "$a" ] && actuals="$actuals$a"$'\n'
done < <(find "$target" -name '*.kt' -type f -print0 2>/dev/null)

if [ -z "${expects}${actuals}" ]; then
  echo "PASS check_expect_actual_balance (no expect/actual declarations found)"
  exit 0
fi

exp_unique=$(printf '%s' "$expects" | sort -u)
act_unique=$(printf '%s' "$actuals" | sort -u)
missing_actual=$(comm -23 <(printf '%s' "$exp_unique") <(printf '%s' "$act_unique"))
missing_expect=$(comm -13 <(printf '%s' "$exp_unique") <(printf '%s' "$act_unique"))

if [ -n "$(printf '%s%s' "$missing_actual" "$missing_expect" | tr -d '[:space:]')" ]; then
  echo "FAIL check_expect_actual_balance: unbalanced expect/actual declarations:"
  [ -n "$missing_actual" ] && echo "  expect without actual: $(printf '%s' "$missing_actual" | paste -sd, -)"
  [ -n "$missing_expect" ] && echo "  actual without expect: $(printf '%s' "$missing_expect" | paste -sd, -)"
  exit 1
fi
echo "PASS check_expect_actual_balance"
exit 0
