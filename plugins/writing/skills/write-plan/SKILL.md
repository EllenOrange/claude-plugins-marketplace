---
name: write-plan
description: Write an implementation plan for an issue and post it as an issue comment. Use whenever the user asks to plan, spec out, design, or scope the work for an issue, ticket, or feature request, in any phrasing that means "figure out how to build this and write it down on the tracker".
model: opus
---

# write-plan

Produce a plan for one issue, and post it as a comment on that issue.
`${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` states the format and the
style of a plan, and is the only authority on either. Read it before
you draft, and write every sentence of the plan to it.

This skill runs on the model its frontmatter names, at the reasoning
tier the session has set.

## 1. Read

- Read the issue. If the user has issue skills installed, for example
  `/issues:issue-view`, use them. They dispatch to the repo's
  configured tracker. Otherwise use `gh issue view`.
- Read the issue's edges and the issues they name, so you can tell
  this issue's work from the work that borders it.
- Read `CLAUDE.md` and `README.md`. Then read the docs under `docs/`
  that cover the area the issue touches, and any file the issue
  references. Do not read the whole `docs/` tree.
- Read the code the issue touches. Every claim the plan makes about
  existing code or text rests on a passage you read here.
- Read `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`. It holds the
  questions the review that grades the implementation will ask.
- When the sdlc plugin is installed, read the installed
  `sdlc:orchestrate-readiness` skill. It owns the readiness bar and the
  issue-body grammar the plan's Acceptance and Files affected sections
  follow.

## 2. Interview

Settle every open design question with the user before you draft.
Build understanding with plain questions, one at a time. Reserve
multiple-choice forms for bounded decisions among known options. Do
not manufacture a question you can settle by reading the repo.

A design question is any decision the implementer cannot make alone.
When the sdlc plugin is installed, the decisions in the "No unanswered
design decisions" item of its readiness bar are all in that set. Settle
each one here.

When the plan builds on a component that sits on an unmerged branch,
read that component at the branch's ref, never at main. Each gap
between what the plan needs and what the component offers becomes an
interview question.

When the plan depends on an external SDK, library, or service, read
its docs or its source before you decide how the work uses it. A usage
decision made from memory is a guess.

The interview ends when no question is open. A plan with an open
question is never posted.

## 3. Propose

Show the user the framing before you draft:

1. The problem, in one sentence, stated as the current behavior and
   what it costs. It names no fix and no mechanism.
2. The candidate designs, one paragraph each, with the pros and cons
   of each as a bullet list. Propose one design when one is obviously
   right.

Stop and let the user pick a design and correct the framing. The
rejected designs stay in the conversation and never enter the plan.

Then derive the acceptance criteria from the design the user picked.
Show them and stop for correction.

## 4. Draft

Draft the plan into a file in the harness scratchpad. Write it in the
format and style `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` states.
Nothing outside this skill reads the file.

## 5. Self-review

Read the draft back and check it. A defect you find here costs an
edit rather than a correction.

- **The format.** Check every section and every sentence against
  `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md`.
- **The problem.** Does the problem match what the issue reports? A
  narrower problem descopes the issue, and a wider one adds work
  nobody asked for.
- **The quotes.** Re-read each quoted passage at its path in the tree.
  A quote that does not match the tree verbatim is wrong. Correct it
  from the tree, or delete the claim.
- **The review's questions.** Ask each question in
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md` of the draft, and fix
  every failing answer.
- **The readiness bar.** When the sdlc plugin is installed, grade the
  draft against every item of the installed `sdlc:orchestrate-readiness`
  bar. Run each Mechanical bullet's command against the tree, per that
  skill's executed Mechanical check. With no sdlc install, skip this
  item and say in the report that the grading was skipped.
- **Every instance.** When you find one instance of a defect, search
  the draft for every other instance and fix them all in the same
  edit.

Edit the draft to fix what you find, then read it back again. Repeat
until a pass turns up nothing.

## 6. Human review

Show the user the draft and stop. Do not post until they approve it.

Apply each change they ask for to the draft. Before you apply one,
search the draft for every other sentence the change makes wrong, and
fix those in the same edit. Then run "5. Self-review" again and show
the result.

## 7. Post

Post the draft file as a comment on the issue. Prefer an installed
issue skill, for example `/issues:issue-comment`, which reads the body
from a file. Otherwise use `gh issue comment --body-file`. Report the
comment URL to the user.

`writing:converge-plan` runs one critique-and-fix round over the
posted plan. `writing:promote-plan` moves the plan into the issue body,
which is the surface the review that grades the implementation reads.
