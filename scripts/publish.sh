#!/usr/bin/env bash
# Publish the post on the current draft/<slug> branch:
# commit pending edits, set draft: false and date: now, build-check, squash-merge into main, push, delete the branch.
set -euo pipefail
branch=$(git symbolic-ref --short HEAD)
[[ $branch == draft/* ]] || { echo "error: run this on a draft/* branch (you are on $branch)" >&2; exit 1; }

if [[ -n $(git status --porcelain) ]]; then
  git add -A && git commit --quiet -m "Draft: work in progress"
fi

mapfile -t files < <(git diff --name-only "main...HEAD" -- 'content/notes/*/index.md' 'content/essays/*/index.md')
(( ${#files[@]} == 1 )) || { echo "error: expected one post on this branch, found ${#files[@]}: ${files[*]:-none}" >&2; exit 1; }
file=${files[0]}

if [[ $file == content/essays/* ]] && grep -qE '^summary: *(""|)? *(#.*)?$' "$file"; then
  echo "error: essays need a summary in front matter ($file)" >&2; exit 1
fi

now=$(date +%Y-%m-%dT%H:%M:%S%:z)
# Edit only the front matter (between the first two --- lines).
awk -v now="$now" 'NR==1 && /^---$/ {fm=1; print; next}
  fm && /^---$/ {fm=0; print; next}
  fm && /^draft:/ {print "draft: false"; next}
  fm && /^date:/  {print "date: " now; next}
  {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

title=$(sed -n 's/^title: "\{0,1\}\(.*[^"]\)"\{0,1\}$/\1/p' "$file" | head -1)
git add "$file" && git commit --quiet -m "Publish: $title"

echo "Checking the build..."
make --no-print-directory build >/dev/null

git switch --quiet main
if git remote get-url origin >/dev/null 2>&1; then git pull --quiet --ff-only; fi
git merge --quiet --squash "$branch" >/dev/null
git commit --quiet -m "Publish: $title"
if git remote get-url origin >/dev/null 2>&1; then
  git push --quiet origin main
  git push --quiet origin --delete "$branch" 2>/dev/null || true
fi
git branch --quiet -D "$branch"
echo "Published \"$title\" ($file). The site updates when the deploy Action finishes."
