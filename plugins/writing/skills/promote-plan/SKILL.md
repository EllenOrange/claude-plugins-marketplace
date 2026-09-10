---
name: promote-plan
description: Move an approved plan out of its issue comment and make it the issue body, carrying the old body's leftover detail into a Notes section. Use when the user asks to promote, adopt, or move a plan into the issue itself, or says the plan should live in the issue body rather than in a comment.
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
does not rewrite it. It makes two edits. Step 3 normalizes the plan's
heading levels. Step 4 gathers what the old body carried and the plan
does not into a `## Notes` section, the one section this skill
authors.

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
- Acceptance criteria, with its Invariants subsection
- Solution
- Outline
- Open questions

An optional References section may follow them. Then act on what you
found:

- **Exactly one plan comment.** Use it.
- **Several plan comments.** Show the user the candidates with their
  URLs and dates. Ask which one to promote. Do not assume the newest.
- **No plan comment.** Say so and stop. Do not write a plan here;
  that is `writing:write-plan`.

## 2. Read both texts verbatim

Fetch the comment body and the current issue body into files. Keep
both exactly as stored:

```bash
gh issue view <N> --json body --jq .body > "$scratch/body.md"
gh api repos/{owner}/{repo}/issues/comments/<comment-id> \
  --jq .body > "$scratch/plan.md"
```

Write the working files to the session scratchpad if the harness gave
you one, else to `.claude/tmp/`.

Then read the plan's Open questions section, in the empty form
`write-plan` → "5. Write" owns. When it carries a bullet, stop. Show
the user the questions. Ask whether to promote anyway. Proceed only on
a yes. Say in the report that you promoted the plan with open
questions.

An open question in a promoted plan stops the implementer. The
implementer stops on a design decision the issue does not answer, and
the promoted plan is part of the issue body it reads.

## 3. Normalize the plan's headings

The plan becomes the body, so its sections must be `##` and its unit
headers `###`. Dispatch on the plan text's first heading:

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

## 4. Write the plan into the issue body

The assembled body is the normalized plan, then at most one `## Notes`
section. It carries nothing else, and nothing above the plan.

`## Notes` carries every detail and piece of evidence the old body
holds that the plan does not state, in the old body's own words, as
prose or bullets. It carries nothing the plan already states. When the
old body leaves nothing over, write no `## Notes` section.

Which part of the old body supplies those leftovers depends on the
body's shape:

- **Its first heading is `## Problem`.** The body is a prior
  promotion, so the source is its existing `## Notes` section.
- **It ends in a `## Plan` section.** The body was promoted before
  this skill wrote whole bodies, so the source is the text above
  `## Plan`.
- **Neither.** The source is the whole body.

Assemble the file, then ask once. Show the user the assembled body and
the comment URL. Ask whether to write the body and delete the comment.
Deleting a comment is irreversible, so this one question covers both
acts and step 5 asks no second time. Proceed on a yes. On a no, write
nothing and stop.

Update the issue with the assembled file. Prefer an installed issue
skill, for example `/issues:issue-update`, which replaces the body
from a file. Otherwise use `gh`:

```bash
gh issue edit <N> --body-file "$scratch/body.md"
```

Then re-read the issue body. Confirm it carries the plan. Do not
proceed to step 5 until you confirm it.

## 5. Delete the source comment

The plan moved, so the comment does not survive the move. Step 4
gathered the approval for this deletion. Delete the comment without
asking again:

```bash
gh api --method DELETE \
  repos/{owner}/{repo}/issues/comments/<comment-id>
```

## 6. Report

Give the user the issue URL and one sentence on what moved. Say what
`## Notes` carries, or that the body has no `## Notes` section. Say
that you promoted the plan with open questions when you did.
