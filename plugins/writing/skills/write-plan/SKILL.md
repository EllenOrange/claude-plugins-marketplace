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
- Read the code the issue touches. The plan quotes it under
  `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` → "The quote rule".
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

A design question is any decision, as
`${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` defines one. Settle each one
here.

When the plan builds on a component that sits on an unmerged branch,
read that component at the branch's ref, never at main. Each gap
between what the plan needs and what the component offers becomes an
interview question.

When the plan depends on an external SDK, library, or service, read
its docs or its source before you decide how the work uses it. A usage
decision made from memory is a guess.

The interview ends when no question is open. Never post a plan that
fails `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` → "A plan is settled".

## 3. Propose

Show the user the problem in one sentence, stated as
`${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` → "Problem" states it. It
names no fix and no mechanism.

When there is a real choice between designs, show the candidate
designs, one paragraph each, with the pros and cons of each as a
bullet list. Stop and let the user pick one. The rejected designs stay
in the conversation, and `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` →
"The style" governs what the plan says of them. When one design is
obviously right, show no candidates.

Then show the framing of the design:

1. A short summary of the design in plain language, a few sentences
   the user takes in at one reading.
2. The list of decisions the plan's Design will carry, one plain
   sentence each. Each is a decision as
   `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` defines one.

Neither part names anything that file leaves to the implementer. Each
listed decision becomes one Design paragraph or subheading in the
draft, and the draft's Design carries no decision the list lacks.

Stop for the user's confirmation and correction of the framing, and
draft nothing until the user confirms it. Apply each correction and
show the framing again. A decision you find later, while drafting or
reviewing, comes back to this step before it enters the draft.

Then derive the acceptance criteria from the confirmed framing. Show
them and stop for correction.

## 4. Draft

Draft the plan into a file in the harness scratchpad. Write it in the
format and style `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` states.
Nothing outside this skill reads the file.

## 5. Self-review

Read the draft back and check it. A defect you find here costs an
edit rather than a correction.

- **The format.** Check every section and every sentence against
  `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md`.
- **The confirmed framing.** Each decision the user confirmed in "3.
  Propose" is one Design paragraph or subheading, and Design carries
  no other decision.
- **The problem.** Does the problem match what the issue reports? A
  narrower problem descopes the issue, and a wider one adds work
  nobody asked for.
- **The quotes.** Re-read each quoted passage at its path in the tree,
  and hold it to `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` → "The
  quote rule". Correct a quote that fails it from the tree, or delete
  the claim.
- **The review's questions.** Ask each question in
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md` of the draft, and fix
  every failing answer.
- **The readiness bar.** When the sdlc plugin is installed, grade the
  draft against every item of the installed `sdlc:orchestrate-readiness`
  bar. Grade the Mechanical bullets per that skill's "The check". Its
  script reads only an issue body, so grade the draft bullet by bullet,
  as that skill's "The issue-body grammar" states the script grades
  each key. Grade the bar's "No unanswered design decisions" item only
  on decisions as `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` defines
  them. An internal name or a placement in the tree that crosses no
  boundary never fails it. With no sdlc install, skip this item and say
  in the report that the grading was skipped.
- **Second-order consequences.** For each decision the plan makes,
  find what in the surrounding code and text depends on what the
  decision changes, such as a caller, a citation, a copy of the same
  rule, or a contract another component reads. A decision that leaves
  any of them wrong, or inconsistent with the plan, is a defect. Settle
  it in the plan as a decision or an outcome, or ask the user.
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
