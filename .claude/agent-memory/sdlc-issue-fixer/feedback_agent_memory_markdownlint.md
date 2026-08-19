---
name: agent-memory-markdownlint
description: Agent-memory Markdown in this repo is covered by the repo-wide markdownlint gate, and the memory file format trips MD041 and MD013 by default.
metadata:
  type: feedback
---

# Lint the agent memory you commit

Run `npx markdownlint-cli2` over the files under
`.claude/agent-memory/` that you add, not only the files under
`plugins/`. The gate in `CLAUDE.md` names no directory, so it covers
every Markdown file a PR adds.

**Why:** the memory template violates the gate on its own. A body file
whose frontmatter carries `name:` rather than `title:` fails MD041,
because MD041 looks for a frontmatter title. A one-line `MEMORY.md`
index entry with a link and a hook runs past the 80-column MD013
limit. A review fails the PR on either one.

**How to apply:** give each memory body file an H1 right after the
frontmatter, matching its index title. Wrap each `MEMORY.md` entry
onto a second line, with the hook indented under the link. Then lint
the memory files in the same pass as the rest of the diff. See
[[worktree-branch-fetch-refspec]] for the other worktree-specific trap
on this repo.
