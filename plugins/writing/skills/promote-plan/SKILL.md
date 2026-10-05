---
name: promote-plan
description: Move an approved plan out of its issue comment and make it the whole issue body, stopping first when the plan fails the sdlc readiness bar. Use when the user asks to promote, adopt, or move a plan into the issue itself, or says the plan should live in the issue body rather than in a comment.
---

# promote-plan

Make one plan the issue body. The comment is the draft surface and the
body is the durable one. A reader of the issue then finds one problem
statement and one acceptance list rather than the plan's beside the
original body's. Write all prose per the communication-style rule. Use
the installed copy at `~/.claude/rules/communication-style.md` if
present. Otherwise use the plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

The plan text itself moves verbatim. This skill relocates prose; it
does not rewrite it. Step 3 makes its only edits: it normalizes the
plan's heading levels, and it drops an empty Open questions section.
This skill authors no section of its own.

## 1. Find the plan comment

The user names the issue. List its comments with their numeric ids,
which step 5 needs:

```bash
gh api repos/{owner}/{repo}/issues/<N>/comments \
  --jq '.[] | {id, created_at, html_url, body}'
```

Pick the comment that carries the plan. A plan comment holds the
sections `write-plan` emits:

- Problem
- Scope
- Solution
- Acceptance, with its Mechanical and Semantic sub-headings
- Outline
- Files affected (floor)
- Open questions

Then act on what you found:

- **Exactly one plan comment.** Use it.
- **Several plan comments.** Show the user the candidates with their
  URLs and dates. Ask which one to promote. Do not assume the newest.
- **No plan comment.** Say so and stop. Do not write a plan here;
  that is `writing:write-plan`.

## 2. Read the plan verbatim

Fetch the comment body into a file, exactly as stored. Step 3 edits
this file in place, and step 4 writes the issue body from it:

```bash
gh api repos/{owner}/{repo}/issues/comments/<comment-id> \
  --jq .body > "$scratch/plan.md"
```

Write the working file to the session scratchpad if the harness gave
you one, else to `.claude/tmp/`.

Then read the plan's Open questions section, in the empty form
`write-plan` → "5. Write" owns. When it carries a bullet, stop. Show
the user the questions. Ask whether to promote anyway. Proceed only on
a yes. Say in the report that you promoted the plan with open
questions.

An open question in a promoted plan stops the implementer. The
implementer stops on a design decision the issue does not answer, and
the promoted plan is the issue body it reads.

Then grade the plan against every item of the installed
`sdlc:orchestrate-readiness` bar. Grade it as step 3 leaves it,
with its sections at `##` and its unit headers at `###`, however deep
the comment nests them, and with an Open questions section that reads
`None.` deleted. Resolve that skill per
its entry in `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`. Run each
Mechanical bullet's command against the tree, per that skill's
executed Mechanical check, and read the issue's edges for the items
that key on them. The assembled body is this plan and nothing else,
per step 4, so a gap in the plan is a gap in the body.

- **Any gap.** Stop. Show the user the gaps. Ask whether to promote
  anyway. Proceed only on a yes. Say in the report that you promoted
  the plan with bar gaps.
- **No sdlc install.** When the locator finds no sdlc install, skip
  the grading. Say in the report that it was skipped.

## 3. Normalize the plan's headings

The plan becomes the body, so its sections must be `##` and its unit
headers `###`. Make every edit below in `$scratch/plan.md`. Dispatch
on the plan text's first heading:

- **`## Problem`.** The plan already carries the levels the body
  needs. Change nothing.
- **`## Plan`.** The comment nested the plan under a header of its
  own. Delete that line, then remove one `#` from every remaining
  heading.
- **Any other heading.** Stop and report the shape you found. The
  plan is not one `write-plan` emits, and its levels are not yours to
  guess.

Leave headings inside fenced code blocks alone. A `#` line inside a
fence is code or a comment, not a heading.

Then delete an Open questions section that reads the single line
`None.`, heading included. A body carries Open questions only while a
question is open.

## 4. Write the plan into the issue body

The assembled body is the normalized plan in `$scratch/plan.md` and
nothing else. Nothing of the old body carries over.

Ask once. Show the user the assembled body and the comment URL. Ask
whether to write the body and delete the comment. Deleting a comment
is irreversible, so this one question covers both acts and step 5
asks no second time. Proceed on a yes. On a no, write nothing and
stop.

Update the issue with the assembled file. Prefer an installed issue
skill, for example `/issues:issue-update`, which replaces the body
from a file. Otherwise use `gh`:

```bash
gh issue edit <N> --body-file "$scratch/plan.md"
```

Then re-read the issue body. Confirm it carries the plan. Do not
proceed to step 5 until you confirm it.

After the re-read, run `/sdlc:orchestrate-readiness <N>` when the sdlc
plugin is installed. Carry its verdict into the report.

## 5. Delete the source comment

The plan moved, so the comment does not survive the move. Step 4
gathered the approval for this deletion. Delete the comment without
asking again:

```bash
gh api --method DELETE \
  repos/{owner}/{repo}/issues/comments/<comment-id>
```

## 6. Report

Give the user the issue URL and one sentence on what moved. Give the
verdict of the `sdlc:orchestrate-readiness` run, or say that the check
was skipped because no sdlc install was found. Say that you promoted
the plan with open questions or with bar gaps when you did.
