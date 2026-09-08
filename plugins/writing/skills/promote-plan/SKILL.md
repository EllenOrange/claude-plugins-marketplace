---
name: promote-plan
description: Move an approved plan out of its issue comment and into the bottom of the issue body under a Plan header. Use when the user asks to promote, adopt, or move a plan into the issue itself, or says the plan should live in the issue body rather than in a comment.
---

# promote-plan

Move one plan from its issue comment into the bottom of the issue
body, under a `## Plan` header. The comment is the draft surface and
the body is the durable one. A reader of the issue then sees the plan
without hunting the comment thread. Write all prose per the
communication-style rule. Use the installed copy at
`~/.claude/rules/communication-style.md` if present. Otherwise use the
plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

The plan text itself moves verbatim. This skill relocates prose; it
does not rewrite it. The one edit it makes is the heading shift in
step 3. That shift keeps the plan's own sections nested under the
`## Plan` header.

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

## 3. Shift the plan's headings down one level

The plan lands under a `## Plan` header, so its own top-level sections
must sit below that header. Add one `#` to every heading in the plan
text. A plan whose sections are `##` becomes `###`, and its unit
headers become `####`.

Constraints on the shift:

- Leave headings inside fenced code blocks alone. A `#` line inside a
  fence is code or a comment, not a heading.
- If any heading is already at `######`, stop. Tell the user. A
  seventh level does not exist in Markdown, and the plan needs
  flattening first.

## 4. Write the plan into the issue body

Append the `## Plan` header and the shifted plan to the end of the
issue body, separated from the text above it by one blank line.

If the body already ends in a `## Plan` section, this is a re-run or a
revision. Replace that section and everything after it, rather than
appending a second one. The result has exactly one `## Plan` header.

Update the issue with the assembled file. Prefer an installed issue
skill, for example `/issues:issue-update`, which replaces the body
from a file. Otherwise use `gh`:

```bash
gh issue edit <N> --body-file "$scratch/body.md"
```

Then re-read the issue body. Confirm the plan is present under the
`## Plan` header. Do not proceed to step 5 until you confirm it.

## 5. Delete the source comment

The plan moves, so the comment does not survive the move. Deleting a
comment is irreversible. Show the user the comment URL and ask before
you delete it:

```bash
gh api --method DELETE \
  repos/{owner}/{repo}/issues/comments/<comment-id>
```

If the user declines, leave the comment in place and say that the
plan is now in both places.

## 6. Report

Give the user the issue URL and one sentence on what moved. Name the
comment as deleted or as left in place. Say that you promoted the plan
with open questions when you did.
