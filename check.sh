#!/usr/bin/env bash
# Regression guard. Structural for now — entries get added when something ships broken once.
set -euo pipefail
cd "$(dirname "$0")"
fail=0

# Every skill dir has a SKILL.md whose frontmatter name matches the directory.
for d in skills/*/; do
  name=$(basename "$d")
  if [ ! -f "$d/SKILL.md" ]; then
    echo "FAIL: $d has no SKILL.md"; fail=1; continue
  fi
  fm_name=$(sed -n 's/^name: //p' "$d/SKILL.md" | head -1)
  [ "$fm_name" = "$name" ] || { echo "FAIL: $d frontmatter name is '$fm_name'"; fail=1; }
  grep -q '^description: ' "$d/SKILL.md" || { echo "FAIL: $d has no description"; fail=1; }
done

# Every tier agent has matching name, a model and an effort.
for f in agents/*.md; do
  name=$(basename "$f" .md)
  [ "$(sed -n 's/^name: //p' "$f" | head -1)" = "$name" ] || { echo "FAIL: $f frontmatter name mismatch"; fail=1; }
  grep -q '^model: ' "$f" || { echo "FAIL: $f has no model"; fail=1; }
  grep -qE '^effort: (low|medium|high|xhigh|max)$' "$f" || { echo "FAIL: $f has no valid effort"; fail=1; }
done

# plugin.json paths exist, and every skill dir is listed.
while read -r p; do
  [ -d "$p" ] || { echo "FAIL: plugin.json lists missing $p"; fail=1; }
done < <(sed -n 's/.*"\(\.\/skills\/[a-z-]*\)".*/\1/p' .claude-plugin/plugin.json)
for d in skills/*/; do
  grep -q "\"./${d%/}\"" .claude-plugin/plugin.json || { echo "FAIL: ${d%/} not in plugin.json"; fail=1; }
done

# No skill references a skill that does not exist in this repo.
known="giljabi|grill|to-spec|to-tickets|implement|review|commit|pr|knowledge|knowledge-tend|migrate-docs|setup|clear|compact|handoff|new"
if grep -rnoE '`/[a-z-]+`' skills/*/SKILL.md | grep -vE "\`/(${known})\`"; then
  echo "FAIL: reference to an unknown skill (above)"; fail=1
fi

[ "$fail" = 0 ] && echo "check.sh: all green"
exit $fail
