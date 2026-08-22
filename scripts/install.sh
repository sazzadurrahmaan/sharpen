#!/usr/bin/env bash
# Installs the sharpen skill for Claude Code (personal scope) and, optionally, Cursor.
#   curl -fsSL https://raw.githubusercontent.com/sazzadurrahmaan/sharpen/main/scripts/install.sh | bash
set -euo pipefail

REPO="https://github.com/sazzadurrahmaan/sharpen.git"
DEST="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/sharpen"

need() { command -v "$1" >/dev/null 2>&1 || { echo "error: $1 is required" >&2; exit 1; }; }
need git

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "fetching sharpen..."
git clone --depth 1 --quiet "$REPO" "$TMP/sharpen"

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -R "$TMP/sharpen/plugins/sharpen/skills/sharpen" "$DEST"

echo
echo "installed: $DEST"
echo "restart Claude Code, then run:  /sharpen <your messy prompt>"

if [ -d "$HOME/.cursor/rules" ]; then
  echo
  printf 'Cursor detected. Install the Cursor rule too? [y/N] '
  read -r reply </dev/tty || reply=n
  case "$reply" in
    [yY]*)
      cp "$TMP/sharpen/adapters/cursor/rules/sharpen.mdc" "$HOME/.cursor/rules/sharpen.mdc"
      echo "installed: $HOME/.cursor/rules/sharpen.mdc"
      ;;
  esac
fi
