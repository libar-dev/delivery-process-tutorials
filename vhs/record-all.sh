#!/usr/bin/env bash
set -euo pipefail

# record-all.sh — Generate all tutorial GIF recordings
#
# Usage:
#   cd /path/to/dp-mini-demo
#   ./vhs/record-all.sh
#
# Each part depends on the previous, so they run sequentially.
# Total time: ~10-15 minutes depending on machine speed.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "═══ Recording all tutorial parts ═══"
echo ""

FAILED=0
for tape in "$SCRIPT_DIR"/part-*.tape; do
  name=$(basename "$tape" .tape)
  echo "▸ Recording: $name"
  if vhs "$tape" 2>&1 | tail -1; then
    echo "  ✓ Done"
  else
    echo "  ✗ Failed"
    FAILED=$((FAILED + 1))
  fi
  echo ""
done

echo "═══ Complete ═══"
echo ""
ls -lh "$SCRIPT_DIR/output/"*.gif 2>/dev/null
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "⚠ $FAILED tape(s) failed"
  exit 1
else
  echo "✓ All recordings generated in vhs/output/"
fi
