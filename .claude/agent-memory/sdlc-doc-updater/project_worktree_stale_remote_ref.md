---
name: worktree-stale-remote-ref
description: In this repo's subagent worktrees, plain `git fetch origin` can leave origin/<branch> stale, so the checked-out PR branch silently lags the real PR head.
metadata:
  type: project
---

# Stale origin ref in agent worktrees

In a `.claude/worktrees/agent-*` worktree of this repo, a plain
`git fetch origin` sometimes leaves `refs/remotes/origin/<branch>`
pointing at an older commit than the remote actually carries.
Checking the branch out then lands on a stale tip while
`gh pr diff` returns the true PR head, so the diff and the working
tree disagree.

**Why:** it cost a doc-updater run on PR 12 real time. The diff
showed edits the checked-out file did not contain, which reads like a
failed write rather than a stale ref.

**How to apply:** after checkout, compare `git rev-parse HEAD` against
`gh pr view <PR> --json headRefOid`. When they differ, force the
remote-tracking ref forward with an explicit refspec,
`git fetch origin +refs/heads/<branch>:refs/remotes/origin/<branch>`,
then `git merge --ff-only origin/<branch>`. Do not reach for
`git reset --hard`; the harness blocks it in subagents.
