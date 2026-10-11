#!/usr/bin/env bash
# check_no_activity_test_rule.sh <test-src-dir>
# FLAGS: androidx.test.rule.ActivityTestRule — @Deprecated; use
#        ActivityScenarioRule (androidx.test.ext.junit.rules) or
#        ActivityScenario (androidx.test.core.app).
# Rule: SKILL.md §3 — no deprecated Activity rule.
# Source: androidx.test source KDoc
#   (runner/rules/java/androidx/test/rule/ActivityTestRule.java):
#   "use androidx.test.core.app.ActivityScenario or
#    androidx.test.ext.junit.rules.ActivityScenarioRule instead."
# Heuristic limitation: full-line comments are filtered; an ActivityTestRule
# mention in a trailing comment on a code line still flags.
set -uo pipefail
target="${1:?usage: check_no_activity_test_rule.sh <test-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=$(grep -rnE '\bActivityTestRule\b' "$target" --include='*.kt' --include='*.java' 2>/dev/null \
  | grep -vE '(^|:)[0-9]+:[[:space:]]*//' \
  | sed 's/^/  /')
if [ -n "$hits" ]; then
  echo "FAIL check_no_activity_test_rule: deprecated ActivityTestRule — use ActivityScenarioRule / activityScenarioRule:"
  echo "$hits"
  exit 1
fi
echo "PASS check_no_activity_test_rule"
exit 0
