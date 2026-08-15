#!/usr/bin/env bash
# Install the writing-style rule shipped with this plugin into
# ~/.claude/rules/, where Claude Code's CLAUDE.md can load it.
#
# Idempotent: no-op when the installed copy already matches; refuses
# to clobber a diverged copy unless run with --force.
set -euo pipefail

plugin_root="$(cd "$(dirname "$0")" && pwd)"
src="$plugin_root/rules/writing-style.md"
dst="$HOME/.claude/rules/writing-style.md"
line='@~/.claude/rules/writing-style.md'
claude_md="$HOME/.claude/CLAUDE.md"

[ -f "$src" ] || { echo "error: $src not found" >&2; exit 1; }

if [ -f "$dst" ]; then
  if cmp -s "$src" "$dst"; then
    echo "Already installed and up to date: $dst"
  elif [ "${1:-}" = "--force" ]; then
    cp "$src" "$dst"
    echo "Overwrote diverged copy: $dst"
  else
    echo "error: $dst exists and differs from the plugin's copy." >&2
    echo "Re-run with --force to overwrite, or diff first:" >&2
    echo "  diff '$dst' '$src'" >&2
    exit 1
  fi
else
  mkdir -p "$HOME/.claude/rules"
  cp "$src" "$dst"
  echo "Installed: $dst"
fi

if [ -f "$claude_md" ] && grep -qxF "$line" "$claude_md"; then
  echo "CLAUDE.md already loads it."
else
  echo
  echo "Not done yet: add this line to $claude_md so the rule loads:"
  echo "  $line"
fi
