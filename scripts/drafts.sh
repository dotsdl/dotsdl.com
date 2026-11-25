#!/usr/bin/env bash
# List draft/* branches, oldest first, with age in days and title.
set -euo pipefail
now=$(date +%s)
found=0
while read -r branch ts; do
  found=1
  file=$(git diff --name-only "main...$branch" -- 'content/notes/*/index.md' 'content/essays/*/index.md' | head -1)
  title=""
  [[ -n $file ]] && title=$(git show "$branch:$file" 2>/dev/null | sed -n 's/^title: "\{0,1\}\(.*[^"]\)"\{0,1\}$/\1/p' | head -1)
  printf '%4sd  %-40s %s\n' "$(( (now - ts) / 86400 ))" "$branch" "$title"
done < <(git for-each-ref --sort=committerdate --format='%(refname:short) %(committerdate:unix)' refs/heads/draft/)
(( found )) || echo "No drafts."
