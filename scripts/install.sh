#!/usr/bin/env bash
# Installs the sharpen skill.
#
#   curl -fsSL https://raw.githubusercontent.com/sazzadurrahmaan/sharpen/main/scripts/install.sh | bash
#
# Pin to a release instead of tracking main:
#
#   SHARPEN_REF=v1.1.1 curl -fsSL https://raw.githubusercontent.com/sazzadurrahmaan/sharpen/v1.1.1/scripts/install.sh | bash
#
# Primary target is ~/.agents/skills — the Agent Skills standard location, read by
# Codex, Cursor, Gemini CLI, Copilot, Amp, OpenCode, Goose, Kiro, and others.
# Claude Code reads ~/.claude/skills instead, so it gets a link to the same folder.
#
# Everything lives inside main(), invoked on the last line, so a download truncated
# in transit does nothing at all rather than running half a script.
set -euo pipefail

main() {
  local repo="https://github.com/sazzadurrahmaan/sharpen.git"
  local ref="${SHARPEN_REF:-}"

  command -v git >/dev/null 2>&1 || die "git is required"

  local agents_dir claude_dir
  agents_dir="${AGENTS_SKILLS_DIR:-$(default_dir .agents/skills)}"
  claude_dir="${CLAUDE_SKILLS_DIR:-$(default_dir .claude/skills)}"

  local tmp
  tmp="$(mktemp -d)"
  # shellcheck disable=SC2064  # expand tmp now, not at trap time
  trap "rm -rf '$tmp'" EXIT

  echo "fetching sharpen${ref:+ @ $ref}..."
  if [ -n "$ref" ]; then
    git -c advice.detachedHead=false clone --depth 1 --quiet --branch "$ref" \
      "$repo" "$tmp/sharpen" || die "could not fetch ref '$ref'"
  else
    git clone --depth 1 --quiet "$repo" "$tmp/sharpen"
  fi

  local src="$tmp/sharpen/plugins/sharpen/skills/sharpen"
  [ -f "$src/SKILL.md" ] || die "clone looks incomplete: $src/SKILL.md is missing"

  # --- standard location: works across every Agent Skills client ---
  mkdir -p "$agents_dir"
  place "$src" "$agents_dir/sharpen"
  echo "installed  $agents_dir/sharpen"

  # --- Claude Code reads its own directory ---
  mkdir -p "$claude_dir"
  preserve "$claude_dir/sharpen"
  if ln -s "$agents_dir/sharpen" "$claude_dir/sharpen" 2>/dev/null; then
    echo "linked     $claude_dir/sharpen -> $agents_dir/sharpen"
  else
    cp -R "$src" "$claude_dir/sharpen"
    echo "installed  $claude_dir/sharpen"
  fi

  cat <<'DONE'

Restart your agent, then:

  Claude Code   /sharpen <your messy prompt>
  Codex         $sharpen <your messy prompt>
  Cursor        /sharpen in Agent chat
  others        it activates on its own when you ask to improve a prompt

DONE
}

die() { echo "error: $*" >&2; exit 1; }

# Resolve a path under $HOME, with a useful message when HOME is not set.
default_dir() {
  [ -n "${HOME:-}" ] || die "HOME is not set — pass AGENTS_SKILLS_DIR and CLAUDE_SKILLS_DIR explicitly"
  printf '%s/%s' "$HOME" "$1"
}

# Move an existing install aside if it holds changes, so local edits are never lost.
preserve() {
  local target="$1"
  [ -e "$target" ] || [ -L "$target" ] || return 0
  # a symlink is our own doing from a previous run; nothing of the user's inside it
  if [ -L "$target" ]; then rm -f "$target"; return 0; fi
  local backup
  backup="$target.backup.$(date +%Y%m%d%H%M%S)"
  mv "$target" "$backup"
  echo "moved      existing install to $backup"
}

# Install src at target, keeping any modified copy that was already there.
place() {
  local src="$1" target="$2"
  if [ -d "$target" ] && [ ! -L "$target" ] && diff -rq "$src" "$target" >/dev/null 2>&1; then
    rm -rf "${target:?}"          # byte-identical, nothing to preserve
  else
    preserve "$target"
  fi
  cp -R "$src" "$target"
}

main "$@"
