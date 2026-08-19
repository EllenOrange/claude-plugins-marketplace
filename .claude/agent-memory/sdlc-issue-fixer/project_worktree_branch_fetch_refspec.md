---
name: worktree-branch-fetch-refspec
description: Subagent worktrees of this repo fetch only main, so checking out a PR branch and pushing it both need an explicit refspec.
metadata:
  type: project
---

# Fetching a PR branch in a subagent worktree

A `.claude/worktrees/agent-*` worktree of this repo has
`remote.origin.fetch` set to `+refs/heads/main:refs/remotes/origin/main`
only. So `git fetch origin` brings back nothing but `main`, and
`git checkout <pr-branch>` fails with "pathspec did not match any
files".

**Why:** the failure reads like a missing branch rather than a narrow
refspec, so it costs several turns of diagnosis.

**How to apply:** fetch the branch by name into a local branch,
`git fetch origin <branch>:<branch>`, then check it out. The local
branch has no upstream, so push it with an explicit refspec,
`git push origin HEAD:<branch>`. A bare `git push` fails. This is a
sibling of the doc-updater's stale-remote-ref note, and the two share
a root cause in how the worktree's remote is configured.
