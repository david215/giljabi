#!/usr/bin/env bash
# Regenerate a knowledge index from page frontmatter and each page's first sentence.
# usage: index.sh docs/domain > docs/domain/README.md   (same for docs/platform)
set -euo pipefail
dir="${1:?usage: index.sh <docs/domain|docs/platform>}"
case "$(basename "$dir")" in
  domain)   title="Domain knowledge";   what="domain entity" ;;
  platform) title="Platform knowledge"; what="behaviour of the stack as deployed here" ;;
  *)        title="Knowledge";          what="entity" ;;
esac
printf '# %s\n\nOne current-state page per %s, rewritten in place; git is the ledger.\nThe contract is in the `/knowledge` skill. **This index is generated** from page frontmatter —\nedit the pages, then regenerate; never edit this file.\n\n' "$title" "$what"
for f in "$dir"/*.md; do
  [ "$(basename "$f")" = README.md ] && continue
  awk -v f="$(basename "$f")" '
    /^---$/ { fm++; next }
    fm==1 && /^id: /      { id=$2 }
    fm==1 && /^context: / { ctx=$2 }
    fm==1 && /^status: /  { st=$2 }
    fm>=2 && /^# /        { intitle=1; next }
    fm>=2 && intitle && NF { def = def (def ? " " : "") $0; if ($0 ~ /\.( |$)/) intitle=0 }
    END {
      sub(/\.( .*)?$/, "", def)
      printf "%s\t%s\t%s\t%s\t%s\n", (ctx ? ctx : "~"), id, f, (st == "intended" ? " _(intended)_" : ""), def
    }' "$f"
done | sort -t$'\t' -k1,1 -k2,2 | awk -F'\t' '
  $1 != ctx { ctx=$1; printf "%s### %s\n\n", (NR>1 ? "\n" : ""), (ctx=="~" ? "uncategorised" : ctx) }
  { printf "- [%s](%s)%s — %s\n", $2, $3, $4, $5 }'
