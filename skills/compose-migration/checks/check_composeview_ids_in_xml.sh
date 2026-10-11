#!/usr/bin/env bash
# check_composeview_ids_in_xml.sh <res-or-src-dir>
# FLAGS: an XML layout hosting 2+ ComposeView elements where at least one
# lacks android:id — unique IDs are required for savedInstanceState
# restoration when a layout hosts multiple ComposeViews.
# Rule: SKILL.md §3.
# Source: https://developer.android.com/develop/ui/compose/migrate/interoperability-apis/compose-in-views
# Heuristic limitation: element spans run from the opening tag line to
# the closing `/>` or `</...ComposeView>`; a single ComposeView layout is
# not flagged (the documented rule covers multiple ComposeViews).
set -uo pipefail
target="${1:?usage: check_composeview_ids_in_xml.sh <res-or-src-dir>}"
[ -d "$target" ] || { echo "ERROR: not a directory: $target" >&2; exit 2; }

hits=0
while IFS= read -r -d '' f; do
  grep -qE '<[A-Za-z.]*ComposeView' "$f" 2>/dev/null || continue
  stats=$(awk '
    /<[A-Za-z.]*ComposeView/ && !inElem {
      total++; inElem=1; hasId=0
      if ($0 ~ /android:id/) hasId=1
      if ($0 ~ /\/>/) { if (!hasId) missing++; inElem=0 }
      next
    }
    inElem {
      if ($0 ~ /android:id/) hasId=1
      if ($0 ~ /\/>/ || $0 ~ /<\/[A-Za-z.]*ComposeView>/) { if (!hasId) missing++; inElem=0 }
    }
    END { print total+0, missing+0 }' "$f" 2>/dev/null)
  total=${stats%% *}; missing=${stats##* }
  if [ "${total:-0}" -ge 2 ] && [ "${missing:-0}" -gt 0 ]; then
    echo "FAIL check_composeview_ids_in_xml: $total ComposeViews in layout, $missing without android:id: $f"
    hits=1
  fi
done < <(find "$target" -name '*.xml' -type f -print0 2>/dev/null)

[ $hits -ne 0 ] && exit 1
echo "PASS check_composeview_ids_in_xml"
exit 0
