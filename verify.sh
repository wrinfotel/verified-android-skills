#!/usr/bin/env bash
# verify.sh — verification harness for verified-android-skills.
#
# Usage:
#   ./verify.sh --selftest              # validate the harness on fixtures
#   ./verify.sh <project-or-src-dir>    # run all checks against your code
#
# Output: one line per check + a final JSON report (skills[i].checks[j]).
set -uo pipefail
cd "$(dirname "$0")"

mode="${1:-}"
json=""
overall=0

run_check() { # $1=skill $2=check-script $3=target
  local skill="$1" script="$2" target="$3" out rc
  out=$(bash "$script" "$target" 2>&1); rc=$?
  [ $rc -ne 0 ] && overall=1
  printf '%-22s %-34s %s\n' "$skill" "$(basename "$script")" "$(echo "$out" | head -n1)" >&2
  printf '%s{"skill":"%s","check":"%s","exit":%d,"first_line":"%s"}' \
    "$json" "$skill" "$(basename "$script")" "$rc" "$(echo "$out" | head -n1 | sed 's/"/\\"/g')"
  json=","
  return $rc
}

case "$mode" in
  --selftest)
    echo "== SELFTEST: checks must FIRE on sample-bad and stay QUIET on sample-good ==" >&2
    skills_root="skills"
    json=""
    printf '['
    fail=0
    for skill_dir in "$skills_root"/*/; do
      skill=$(basename "$skill_dir")
      bad="$skill_dir/fixtures/sample-bad"
      good="$skill_dir/fixtures/sample-good"
      [ -d "$bad" ] && [ -d "$good" ] || continue
      for check in "$skill_dir"/checks/*.sh; do
        [ -f "$check" ] || continue
        # bad fixture: check SHOULD fail (rc!=0). good fixture: SHOULD pass (rc=0).
        out_bad=$(bash "$check" "$bad" 2>&1); rc_bad=$?
        out_good=$(bash "$check" "$good" 2>&1); rc_good=$?
        if [ $rc_bad -eq 0 ]; then
          echo "DEAD CHECK  $skill/$(basename "$check") — did not fire on sample-bad"; fail=1
        fi
        if [ $rc_good -ne 0 ]; then
          echo "FALSE POSITIVE  $skill/$(basename "$check") — fired on sample-good:"; echo "$out_good"; fail=1
        fi
        printf '%s{"skill":"%s","check":"%s","fires_on_bad":%s,"quiet_on_good":%s}' \
          "$json" "$skill" "$(basename "$check")" "$([ $rc_bad -ne 0 ] && echo true || echo false)" "$([ $rc_good -eq 0 ] && echo true || echo false)"
        json=","
      done
    done
    printf ']\n'
    if [ $fail -eq 0 ]; then echo "SELFTEST PASS: all checks fire on bad fixtures, quiet on good." >&2; exit 0
    else echo "SELFTEST FAIL" >&2; exit 1; fi
    ;;
  "")
    echo "usage: ./verify.sh --selftest | <project-or-src-dir>" >&2; exit 2
    ;;
  *)
    target="$mode"
    echo "== verified-android-skills: running checks against $target ==" >&2
    printf '['
    for skill_dir in skills/*/; do
      skill=$(basename "$skill_dir")
      for check in "$skill_dir"/checks/*.sh; do
        [ -f "$check" ] || continue
        run_check "$skill" "$check" "$target" || true
      done
    done
    printf ']\n'
    if [ $overall -eq 0 ]; then echo "RESULT: PASS" >&2; exit 0
    else echo "RESULT: FAIL (see flagged lines above)" >&2; exit 1; fi
    ;;
esac
