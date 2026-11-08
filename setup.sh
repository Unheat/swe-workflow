#!/usr/bin/env bash
# setup.sh - One-command installer for SWE Workflow Suite across any agent harness
#
# Supported Harnesses:
#   - Claude Code (.claude/)
#   - DeepSeek Harness (.dsh/)
#   - Cursor (.cursor/)
#   - Codex (.codex/)
#   - OpenCode (.opencode/)
#   - ZCode (.zcode/)
#
# Usage:
#   # From inside your target workspace:
#   bash /path/to/swe-workflow/setup.sh
#   # Or run directly in any project:
#   curl -fsSL https://raw.githubusercontent.com/Unheat/swe-workflow/main/setup.sh | bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"

echo "🚀 [swe-workflow] Installing SWE Workflow Suite into: $TARGET_DIR"
cd "$TARGET_DIR"

# 1. Ensure target skill directories
mkdir -p .agents/skills
mkdir -p .agent/agents
mkdir -p .agents/subagents
mkdir -p .claude/agents

# 2. Copy or update skills
echo "📦 [1/3] Installing core skills (swe-workflow, judge-plan, judge-pr)..."
cp -R "$SCRIPT_DIR/skills/swe-workflow" .agents/skills/
cp -R "$SCRIPT_DIR/skills/judge-plan" .agents/skills/
cp -R "$SCRIPT_DIR/skills/judge-pr" .agents/skills/

# 3. Register judge subagents
echo "🤖 [2/3] Registering judge subagents..."
for agent_file in "$SCRIPT_DIR/skills/swe-workflow/agents"/*.md; do
  if [ -f "$agent_file" ]; then
    base_name="$(basename "$agent_file")"
    cp "$agent_file" ".agent/agents/$base_name"
    cp "$agent_file" ".agents/subagents/$base_name"
    cp "$agent_file" ".claude/agents/$base_name"
    echo "   -> Registered agent: $base_name"
  fi
done

# 4. Scaffolding cross-harness symlinks
echo "🔗 [3/3] Scaffolding cross-harness adapter symlinks..."
mkdir -p .claude .cursor .dsh .codex .opencode .zcode

ensure_link() {
  local link_path="$1"
  local target_path="$2"
  if [ ! -e "$link_path" ] && [ ! -L "$link_path" ]; then
    ln -s "$target_path" "$link_path"
    echo "   -> Linked $link_path -> $target_path"
  fi
}

ensure_link ".claude/skills" "../.agents/skills"
ensure_link ".cursor/skills" "../.agents/skills"
ensure_link ".dsh/skills" "../.agents/skills"
ensure_link ".codex/skills" "../.agents/skills"
ensure_link ".opencode/skills" "../.agents/skills"
ensure_link ".zcode/skills" "../.agents/skills"

echo ""
echo "🎉 [swe-workflow] Successfully installed!"
echo "   Available skills in your harness:"
echo "   • /swe-workflow  - Disciplined 4-phase autonomous software engineering"
echo "   • /judge-plan    - Calibrated plan review gate before implementation"
echo "   • /judge-pr      - Calibrated PR & verification gate before delivery"
