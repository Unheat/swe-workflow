#!/usr/bin/env bash
# update-catalog.sh - refresh the machine catalog from GitHub.
#
# The catalog is a *deployment* copy: it follows origin/main, not a dirty working
# tree. Every workspace linked with `harness skill add <name>` points at
# ~/.agents/catalog/skills/<name>, so after this script runs those workspaces see
# the pushed skill bodies immediately.
#
# Usage:
#   bash scripts/update-catalog.sh          # fetch + fast-forward the catalog clone
#   bash scripts/update-catalog.sh --check  # report how far behind origin/main is
#
# Env overrides:
#   SWE_WORKFLOW_REPO   git URL (default https://github.com/Unheat/swe-workflow.git)
#   HARNESS_CATALOG_DIR catalog root (default ~/.agents/catalog)

set -euo pipefail

REPO_URL="${SWE_WORKFLOW_REPO:-https://github.com/Unheat/swe-workflow.git}"
CATALOG_DIR="${HARNESS_CATALOG_DIR:-$HOME/.agents/catalog}"
DEPLOY_DIR="$CATALOG_DIR/repos/swe-workflow"
SKILLS=(swe-workflow judge-plan judge-pr)

if [ "${1:-}" = "--check" ]; then
  CHECK=1
elif [ "${1:-}" = "" ]; then
  CHECK=0
else
  echo "Usage: bash scripts/update-catalog.sh [--check]" >&2
  exit 2
fi

if [ ! -d "$DEPLOY_DIR/.git" ]; then
  if [ "$CHECK" = 1 ]; then
    echo "catalog clone missing: $DEPLOY_DIR" >&2
    exit 1
  fi
  mkdir -p "$CATALOG_DIR/repos"
  echo "📥 Cloning $REPO_URL into $DEPLOY_DIR..."
  git clone "$REPO_URL" "$DEPLOY_DIR"
fi

git -C "$DEPLOY_DIR" fetch --prune origin

if [ "$CHECK" = 1 ]; then
  behind="$(git -C "$DEPLOY_DIR" rev-list --count HEAD..origin/main)"
  echo "catalog clone: $behind commit(s) behind origin/main ($(git -C "$DEPLOY_DIR" rev-parse --short HEAD))"
  exit 0
fi

git -C "$DEPLOY_DIR" pull --ff-only origin main

mkdir -p "$CATALOG_DIR/skills"
for skill in "${SKILLS[@]}"; do
  link="$CATALOG_DIR/skills/$skill"
  if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "❌ $link exists and is not a symlink; move it aside and re-run." >&2
    exit 1
  fi
  ln -sfn "$DEPLOY_DIR/skills/$skill" "$link"
done

echo "✅ Catalog at $(git -C "$DEPLOY_DIR" rev-parse --short HEAD) — linked workspaces updated."
echo "   Skill bodies are live through the symlinks."
echo "   Re-run .agents/skills/swe-workflow/setup.sh in a workspace after changes to agents/ or hooks/."
