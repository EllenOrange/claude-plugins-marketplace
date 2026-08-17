---
name: install-writing-style
description: Install the writing-style rule shipped with this plugin into ~/.claude/rules/ and wire it into CLAUDE.md. Use when the user asks to install, set up, or update the writing-style rule.
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/install-rule.sh*)
---

# install-writing-style

Install the plugin's writing-style rule so it loads always-on.

## Steps

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/install-rule.sh` and show the user its
   output. The script is idempotent; if it reports a diverged
   installed copy, show the user the diff and ask before re-running
   with `--force`.
2. The script appends the `@~/` line to `~/.claude/CLAUDE.md` itself
   when the file exists. If it exits nonzero because `CLAUDE.md` does
   not exist, create that file with this line:

   ```text
   @~/.claude/rules/writing-style.md
   ```

   If the script or you changed `CLAUDE.md`, and `~/.claude` is a git
   checkout, tell the user the change is local and where it landed,
   so they can commit it upstream.
3. Confirm: the rule file exists, `CLAUDE.md` contains the line, and
   the rule takes effect in the next session.

## If the harness denies a step

If permission to run the script or edit `~/.claude/` is denied, do
not retry or work around the denial. Give the user the exact command
to run themselves with the `!` prefix, with `${CLAUDE_PLUGIN_ROOT}`
expanded to the real path:

```text
! bash ${CLAUDE_PLUGIN_ROOT}/install-rule.sh
```

If only the `CLAUDE.md` edit is denied, give this instead:

```text
! echo '@~/.claude/rules/writing-style.md' >> ~/.claude/CLAUDE.md
```

Tell the user the output will land in the conversation, and verify
the result once it does.
