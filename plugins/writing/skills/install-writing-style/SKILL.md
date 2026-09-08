---
name: install-writing-style
description: Install the communication-style rule shipped with this plugin into ~/.claude/rules/ and wire it into CLAUDE.md. Use when the user asks to install, set up, or update the communication-style rule.
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/install-rule.sh*)
---

# install-writing-style

Install the plugin's communication-style rule so it loads always-on.

## Steps

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/install-rule.sh`. Show the user its
   output. The script is idempotent. If it reports a diverged
   installed copy, show the user the diff. Ask before you re-run
   with `--force`.
2. The script appends the `@~/` line to `~/.claude/CLAUDE.md` itself
   when the file exists. If it exits nonzero because `CLAUDE.md` does
   not exist, create that file with this line:

   ```text
   @~/.claude/rules/communication-style.md
   ```

   If the script or you changed `CLAUDE.md`, and `~/.claude` is a git
   checkout, tell the user the change is local and where it landed.
   They can then commit it upstream.
3. Confirm each of these:
   - The rule file exists.
   - `CLAUDE.md` contains the line.
   - The rule takes effect in the next session.

## If the harness denies a step

If the harness denies permission to run the script or to edit
`~/.claude/`, do not retry or work around the denial. Give the user
the exact command to run themselves with the `!` prefix. Expand
`${CLAUDE_PLUGIN_ROOT}` to the real path:

```text
! bash ${CLAUDE_PLUGIN_ROOT}/install-rule.sh
```

If the harness denies only the `CLAUDE.md` edit, give this instead:

```text
! echo '@~/.claude/rules/communication-style.md' >> ~/.claude/CLAUDE.md
```

Tell the user the output will land in the conversation. Verify the
result once it does.
