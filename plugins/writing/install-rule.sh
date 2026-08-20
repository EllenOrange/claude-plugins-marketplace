#!/usr/bin/env bash
# Install the communication-style rule shipped with this plugin into
# ~/.claude/rules/, where Claude Code's CLAUDE.md can load it.
#
# Idempotent: no-op when the installed copy already matches and
# CLAUDE.md already loads it; refuses to clobber a diverged copy
# unless run with --force. Appends the CLAUDE.md line when missing.
set -euo pipefail

force=0
for arg in "$@"; do
  case "$arg" in
    --force) force=1 ;;
    *) echo "usage: $0 [--force]" >&2; exit 2 ;;
  esac
done

plugin_root="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
src="$plugin_root/rules/communication-style.md"
dst="$HOME/.claude/rules/communication-style.md"
line='@~/.claude/rules/communication-style.md'
claude_md="$HOME/.claude/CLAUDE.md"

[ -f "$src" ] || { echo "error: $src not found" >&2; exit 1; }

if [ -f "$dst" ]; then
  if cmp -s "$src" "$dst"; then
    echo "Already installed and up to date: $dst"
  elif [ "$force" = 1 ]; then
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

if [ -f "$claude_md" ]; then
  if grep -qxF "$line" "$claude_md"; then
    echo "CLAUDE.md already loads it."
  else
    printf '%s\n' "$line" >> "$claude_md"
    echo "Added to $claude_md: $line"
  fi
else
  echo "Not done yet: $claude_md does not exist. Create it with this line so the rule loads:" >&2
  echo "  $line" >&2
  exit 1
fi
