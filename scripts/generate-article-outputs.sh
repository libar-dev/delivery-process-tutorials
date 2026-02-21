#!/usr/bin/env bash
set -euo pipefail

# generate-article-outputs.sh
#
# Runs the entire tutorial from a clean state, capturing:
#   - stdout/stderr of every cell → outputs/<cell-name>.txt
#   - file snapshots after each part → outputs/snapshots/<part>/
#
# Usage:
#   cd /path/to/dp-mini-demo
#   ./scripts/generate-article-outputs.sh
#
# After running, use Claude Code with scripts/GENERATE-ARTICLE-PROMPT.md
# to assemble the static article.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="$SCRIPT_DIR/outputs"
NOTEBOOK="TUTORIAL-RUNME.md"

cd "$PROJECT_DIR"

# Clean previous outputs
rm -rf "$OUT"
mkdir -p "$OUT/snapshots"

# ── Helpers ──────────────────────────────────────────────────────────────────

run_and_capture() {
  local cell="$1"
  echo "▸ Running: $cell"
  runme run "$cell" --filename "$NOTEBOOK" > "$OUT/$cell.txt" 2>&1 || true
}

snapshot_files() {
  local label="$1"
  local dir="$OUT/snapshots/$label"
  mkdir -p "$dir"

  # Copy source files
  if [ -d src ]; then
    cp -r src/ "$dir/src/"
  fi

  # Copy config files
  [ -f delivery-process.config.ts ] && cp delivery-process.config.ts "$dir/"
  [ -f tsconfig.json ] && cp tsconfig.json "$dir/"
  cp package.json "$dir/"

  # Copy generated docs
  if [ -d docs-generated ]; then
    cp -r docs-generated/ "$dir/docs-generated/"
  fi

  # File tree listing (project files only)
  find . -type f \
    -not -path './node_modules/*' \
    -not -path './.git/*' \
    -not -path './.claude/*' \
    -not -path './.tutorial-snapshots/*' \
    -not -path './scripts/outputs/*' \
    -not -path './vhs/output/*' \
    | sort > "$dir/tree.txt"
}

# Capture environment info
capture_environment() {
  {
    echo "date: $(date -u +%Y-%m-%d)"
    echo "node: $(node --version)"
    echo "npm: $(npm --version)"
    echo "os: $(uname -s) $(uname -r)"
    echo "package: $(node -e "console.log(require('./node_modules/@libar-dev/delivery-process/package.json').version)" 2>/dev/null || echo 'unknown')"
  } > "$OUT/environment.txt"
}

echo "═══ Generating article outputs ═══"
echo "Project: $PROJECT_DIR"
echo "Output:  $OUT"
echo ""

# ── Phase 0: Clean start ────────────────────────────────────────────────────

echo "── Phase 0: Setup ──"
run_and_capture reset-workspace
run_and_capture install-deps
capture_environment
snapshot_files "00-setup"

# ── Part 1: Project Setup ───────────────────────────────────────────────────

echo "── Part 1: Project Setup ──"
run_and_capture verify-deps
run_and_capture create-tsconfig
run_and_capture create-folders
run_and_capture checkpoint-1
snapshot_files "01-project-setup"

# ── Part 2: Configuration ───────────────────────────────────────────────────

echo "── Part 2: Configuration ──"
run_and_capture create-config
run_and_capture add-npm-scripts
run_and_capture first-overview
run_and_capture checkpoint-2
snapshot_files "02-configuration"

# ── Part 3: First Annotation ────────────────────────────────────────────────

echo "── Part 3: First Annotation ──"
run_and_capture create-user-service-v1
run_and_capture overview-after-first
run_and_capture sources-after-first
snapshot_files "03-first-annotation"

# ── Part 4: Adding Richness ─────────────────────────────────────────────────

echo "── Part 4: Adding Richness ──"
run_and_capture create-user-service-v2
run_and_capture tags-after-richness
run_and_capture overview-after-richness
snapshot_files "04-richness"

# ── Part 5: Relationships ───────────────────────────────────────────────────

echo "── Part 5: Relationships & Multiple Sources ──"
run_and_capture create-user-service-final
run_and_capture create-auth-handler
run_and_capture create-event-store
run_and_capture overview-with-deps
run_and_capture dep-tree-auth
run_and_capture arch-contexts
run_and_capture list-roadmap
run_and_capture checkpoint-5
snapshot_files "05-relationships"

# ── Part 6: Doc Generation ──────────────────────────────────────────────────

echo "── Part 6: Generate Documentation ──"
run_and_capture gen-patterns
run_and_capture gen-roadmap
run_and_capture list-generated
run_and_capture checkpoint-6
snapshot_files "06-doc-generation"

# ── Part 7: Gherkin Specs ───────────────────────────────────────────────────

echo "── Part 7: Gherkin Specs ──"
run_and_capture create-user-reg-feature
run_and_capture create-auth-feature
run_and_capture query-rules
run_and_capture gen-business-rules
run_and_capture overview-after-gherkin
run_and_capture sources-after-gherkin
run_and_capture checkpoint-7
snapshot_files "07-gherkin"

# ── Part 8: Design Stubs ────────────────────────────────────────────────────

echo "── Part 8: Design Stubs ──"
run_and_capture create-notification-stub
run_and_capture query-stubs
run_and_capture checkpoint-8
snapshot_files "08-stubs"

# ── Part 9: Full Generation ─────────────────────────────────────────────────

echo "── Part 9: Full Generation & Linting ──"
run_and_capture gen-all
run_and_capture list-all-generated
run_and_capture add-reference-config
run_and_capture gen-reference
run_and_capture list-generators
run_and_capture lint-patterns
run_and_capture checkpoint-9
snapshot_files "09-full-generation"

# ── Part 10: Advanced Queries ────────────────────────────────────────────────

echo "── Part 10: Advanced Queries ──"
run_and_capture arch-neighborhood
run_and_capture arch-blocking
run_and_capture arch-dangling
run_and_capture pattern-detail
run_and_capture count-roadmap
run_and_capture final-overview
run_and_capture final-verification
snapshot_files "10-advanced"

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "═══ Done ═══"
echo ""
echo "Captured outputs:"
ls "$OUT"/*.txt | wc -l | xargs echo "  Cell outputs:"
ls -d "$OUT"/snapshots/*/ | wc -l | xargs echo "  Snapshots:"
echo ""
echo "Next: Use Claude Code with scripts/GENERATE-ARTICLE-PROMPT.md to generate the article."
