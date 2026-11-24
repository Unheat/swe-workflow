#!/usr/bin/env bash
# setup.sh - installer entry point for the swe-workflow suite.
#
# Local checkout:
#   bash setup.sh [target-dir]
# Remote (no clone needed):
#   curl -fsSL https://raw.githubusercontent.com/Unheat/swe-workflow/main/setup.sh | bash
#
# It materializes the three skills in <target>/.agents/skills/, then delegates to the
# skill's own setup.sh for subagents, harness adapter links and the pre-push hook.
# The skill-level script is the only place that owns install behaviour.

set -euo pipefail

TARGET_DIR="${1:-$(pwd)}"
mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

SOURCE_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [ -z "$SOURCE_DIR" ] || [ ! -d "$SOURCE_DIR/skills" ]; then
  # Piped install (curl | bash): no local tree to copy from, fetch one.
  SOURCE_DIR="$(mktemp -d -t swe-workflow-install.XXXXXX)"
  trap 'rm -rf "$SOURCE_DIR"' EXIT
  echo "📥 [swe-workflow] Fetching suite into $SOURCE_DIR..."
  git clone --depth 1 https://github.com/Unheat/swe-workflow.git "$SOURCE_DIR"
fi

echo "🚀 [swe-workflow] Installing skill suite into: $TARGET_DIR"
mkdir -p "$TARGET_DIR/.agents/skills"

for skill in swe-workflow judge-plan judge-pr; do
  dest="$TARGET_DIR/.agents/skills/$skill"
  if [ -L "$dest" ]; then
    echo "  ℹ️  $dest is a symlink (catalog-managed); left untouched."
    continue
  fi
  cp -R "$SOURCE_DIR/skills/$skill" "$TARGET_DIR/.agents/skills/"
  echo "  -> Installed skill: $skill"
done

cd "$TARGET_DIR"
exec bash .agents/skills/swe-workflow/setup.sh
