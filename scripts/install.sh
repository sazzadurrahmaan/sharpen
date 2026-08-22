#!/usr/bin/env bash
# Installs the sharpen skill.
#
#   curl -fsSL https://raw.githubusercontent.com/sazzadurrahmaan/sharpen/main/scripts/install.sh | bash
#
# Primary target is ~/.agents/skills — the Agent Skills standard location, read by
# Codex, Cursor, Gemini CLI, Copilot, Amp, OpenCode, Goose, Kiro, and others.
# Claude Code reads ~/.claude/skills instead, so it gets a link to the same folder.
set -euo pipefail

REPO="https://github.com/sazzadurrahmaan/sharpen.git"
AGENTS_DIR="${AGENTS_SKILLS_DIR:-$HOME/.agents/skills}"
CLAUDE_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

command -v git >/dev/null 2>&1 || { echo "error: git is required" >&2; exit 1; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "fetching sharpen..."
git clone --depth 1 --quiet "$REPO" "$TMP/sharpen"
SRC="$TMP/sharpen/plugins/sharpen/skills/sharpen"

# --- standard location: works across every Agent Skills client ---
mkdir -p "$AGENTS_DIR"
rm -rf "${AGENTS_DIR:?}/sharpen"
cp -R "$SRC" "$AGENTS_DIR/sharpen"
echo "installed  $AGENTS_DIR/sharpen"

# --- Claude Code reads its own directory ---
mkdir -p "$CLAUDE_DIR"
rm -rf "${CLAUDE_DIR:?}/sharpen"
if ln -s "$AGENTS_DIR/sharpen" "$CLAUDE_DIR/sharpen" 2>/dev/null; then
  echo "linked     $CLAUDE_DIR/sharpen -> $AGENTS_DIR/sharpen"
else
  cp -R "$SRC" "$CLAUDE_DIR/sharpen"
  echo "installed  $CLAUDE_DIR/sharpen"
fi

cat <<'DONE'

Restart your agent, then:

  Claude Code   /sharpen <your messy prompt>
  Codex         $sharpen <your messy prompt>
  Cursor        /sharpen in Agent chat
  others        it activates on its own when you ask to improve a prompt

DONE
