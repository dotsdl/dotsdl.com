#!/usr/bin/env bash
# Warn (never fail) while TODO(David) placeholders remain.
set -uo pipefail
hits=$(grep -rn --exclude-dir=public --exclude-dir=.git --exclude-dir=scripts 'TODO(David)' content data layouts hugo.toml 2>/dev/null || true)
if [[ -n $hits ]]; then
  n=$(printf '%s\n' "$hits" | wc -l)
  echo "warning: $n TODO(David) placeholder(s) remain:"
  printf '%s\n' "$hits" | sed 's/^/  /'
fi
exit 0
