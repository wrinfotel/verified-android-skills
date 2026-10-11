#!/usr/bin/env bash
# check_no_activity_scenario_rule.sh <kotlin-src-dir>
# FLAGS: ActivityScenarioRule / ActivityScenario usage inside files that
# import androidx.compose.ui.test — the activity then launches twice
# (once for the scenario, once via the ComposeTestRule), a classic
# flakiness source. Use createAndroidComposeRule<Activity>() instead.
# Rule: SKILL.md §2.
# Source: https://developer.android.com/develop/ui/compose/testing
#         ("use createAndroidComposeRule<YourActivity>() if you need
#          access to an activity")
# Heuristic limitation: full-line // comments are ignored; inline
# comments still count.
set -uo pipefail
target="${1:?usage: check_no_activity_scenario_rule.sh <kotlin-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  bad=$(grep -nE '\bActivityScenarioRule\b|\bActivityScenario\s*\.' "$f" 2>/dev/null \
    | grep -vE '(^|:)[0-9]+:[[:space:]]*//')
  if [ -n "$bad" ]; then
    [ $hits -eq 0 ] && echo "FAIL check_no_activity_scenario_rule: activity scenario paired with ComposeTestRule (use createAndroidComposeRule):"
    printf '  %s:%s\n' "$f" "$(echo "$bad" | cut -d: -f1 | paste -sd, -)"
    hits=1
  fi
done < <(grep -rlZ '^import androidx\.compose\.ui\.test' "$target" --include='*.kt' 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_no_activity_scenario_rule"
exit 0
