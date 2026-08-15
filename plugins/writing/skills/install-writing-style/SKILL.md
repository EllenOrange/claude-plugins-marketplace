---
name: install-writing-style
description: Install the writing-style rule shipped with this plugin into ~/.claude/rules/ and wire it into CLAUDE.md. Use when the user asks to install, set up, or update the writing-style rule.
---

# install-writing-style

Install the plugin's writing-style rule so it loads always-on.

## Steps

1. Locate the plugin root: the directory two levels above this
   SKILL.md (the one containing `.claude-plugin/plugin.json` and
   `install-rule.sh`).
2. Run `bash <plugin-root>/install-rule.sh` and show the user its
   output. The script is idempotent; if it reports a diverged
   installed copy, show the user the diff and ask before re-running
   with `--force`.
3. If the script reports that `~/.claude/CLAUDE.md` does not load the
   rule, add this line to that file, next to the other `@~/` lines:

   ```text
   @~/.claude/rules/writing-style.md
   ```

   If `~/.claude` is a git checkout, tell the user the change is
   local and where it landed, so they can commit it upstream.
4. Confirm: the rule file exists, `CLAUDE.md` contains the line, and
   the rule takes effect in the next session.
