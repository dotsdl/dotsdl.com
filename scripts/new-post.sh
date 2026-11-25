#!/usr/bin/env bash
# Start a post on its own draft/<slug> branch.
# Usage: scripts/new-post.sh notes|essays "Title"
set -euo pipefail
section=${1:-}; title=${2:-}
[[ $section == notes || $section == essays ]] || { echo "usage: $0 notes|essays \"Title\"" >&2; exit 2; }
[[ -n $title ]] || { echo "error: give a title, e.g. make ${section%s} T=\"My title\"" >&2; exit 2; }

slug=$(printf '%s' "$title" | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null || printf '%s' "$title")
slug=$(printf '%s' "$slug" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
[[ -n $slug ]] || { echo "error: could not make a slug from \"$title\"" >&2; exit 2; }

branch="draft/$slug"
if [[ $section == notes ]]; then dir="content/notes/$(date +%Y-%m-%d)-$slug"; else dir="content/essays/$slug"; fi
file="$dir/index.md"

[[ -z $(git status --porcelain) ]] || { echo "error: commit or stash your changes first" >&2; exit 1; }
git show-ref --verify --quiet "refs/heads/$branch" && { echo "error: branch $branch already exists" >&2; exit 1; }
ls -d content/notes/*-"$slug" content/essays/"$slug" >/dev/null 2>&1 && { echo "error: a post with slug \"$slug\" already exists" >&2; exit 1; }

git switch --quiet -c "$branch" main
hugo new content "${file#content/}" >/dev/null
# Put the exact title in front matter (the archetype only knows the slug).
esc=${title//\\/\\\\}; esc=${esc//\"/\\\"}   # YAML double-quoted string: escape \ and "
TITLE=$esc awk '!done && /^title: /{print "title: \"" ENVIRON["TITLE"] "\""; done=1; next} {print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
git add "$file" && git commit --quiet -m "Draft: $title"

echo "On $branch: $file"
if [[ -n ${EDITOR:-} && -t 1 ]]; then exec $EDITOR "$file"; fi
