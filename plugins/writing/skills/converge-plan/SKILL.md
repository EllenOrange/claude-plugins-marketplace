---
name: converge-plan
description: Run one critique-and-fix round over a plan on an issue, then report. Use when the user asks to converge a plan, run the critique loop, or critique a plan and apply the accepted fixes.
---

# converge-plan

Run one critique-and-fix round over one plan, then report. Each
invocation runs exactly one round.

## 1. Locate the plan

The user names the issue. The plan lives on the issue body or on the
most recent plan comment. A plan's first heading is `## Problem`. When
both surfaces carry a plan, the body governs, because it is the
surface the review reads. Name the leftover comment in the report.
When neither carries a plan, say so and stop.

## 2. Critique once

Spawn a fresh-context general-purpose subagent on the model
`writing:critique-plan`'s frontmatter names. Instruct it to load
`writing:critique-plan`, and pass it the issue number and the surface
the plan lives on. Tell it the report feeds a verification step. Fresh
context is the point: this session's assumptions are what the critic
must not inherit.

## 3. Verify each finding

Check each finding against the tree, at the ref the plan builds on.
A finding that does not hold is rejected. Record each rejection with
its reason.

## 4. Put the findings to the user

Show the user every verified finding as one batch, each with its
proposed fix, and the rejected findings with their reasons. Ask once
which findings to accept. Do not present them one at a time.

## 5. Apply the accepted findings in one edit

Before you apply an accepted finding, sweep the plan for every other
instance of the same defect, and fix every instance in the same edit.

Act on a refuted claim by one of two moves only: delete it, or
generalise it to what the tree supports. Never elaborate it.

Check each fix's second-order consequences before the edit. Find what
in the surrounding code and text depends on what the fix changes, such
as a caller, a citation, or a contract another component reads. Fix
in the same edit every sentence the fix leaves wrong, or inconsistent
with the tree or the rest of the plan.

Every fix leaves the plan reading as if the text had always been
right. The plan records no history of the round, no ruling, and no
earlier wording.

Edit the located surface in place, once, with the whole revised plan.
Never post a new comment.

### The body-surface guard

Before you edit a body surface, run these checks. When an open pull
request or an unmerged remote branch carries the issue, stop and
report without editing. A criterion under review must not move, and
a comment surface needs no guard because the review never reads it.

- **Pull requests.** Enumerate with
  `gh pr list --state open --limit 1000 --json number`, and decide
  membership through `github-prs:pr-closing-issues` per number. When
  that skill is absent or aborts, fall back to
  `gh pr list --state open --limit 1000 --search "<N>"`.
- **Branches.** Run `git fetch origin`, find the default branch with
  `git symbolic-ref refs/remotes/origin/HEAD`, and list
  `git branch -r --no-merged origin/<default>`. Keep the `origin/`
  refs carrying the `issue-` marker, and decide membership through
  `git-tools:git-issues-from-branch`. When that skill is absent or
  aborts, count any such ref that carries `<N>` as a hyphen-delimited
  token.

Re-read the body after the write, and confirm it carries the revised
plan.

## 6. Report

Give the user:

- The surface the round ran on, and the leftover comment when both
  surfaces carried a plan.
- How many claims the critic read, how many it refuted, how many the
  edit fixed, and how many were rejected.
- Each rejected finding with its reason.

Post nothing else.
