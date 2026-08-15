---
name: write-plan
description: Write a technical spec and implementation plan for an issue and post it as an issue comment. Use whenever the user asks to plan, spec out, design, or scope the work for an issue, ticket, or feature request — any phrasing that means "figure out how to build this and write it down on the tracker".
---

# write-plan

Produce a technical spec and implementation plan for one issue, and
post it as a comment on that issue. Write all prose per the
writing-style rule: the installed copy at
`~/.claude/rules/writing-style.md` if present, else the plugin's
bundled copy at `${CLAUDE_PLUGIN_ROOT}/rules/writing-style.md`.

## 1. Read

- Read the issue. If the user has issue skills installed (for example
  `/issues:issue-view`), use them; they dispatch to the repo's
  configured tracker. Otherwise use `gh issue view`.
- Read `CLAUDE.md` and `README.md`. Then read the docs under `docs/`
  that cover the area the issue touches, and any file the issue
  references. Do not read the whole `docs/` tree.
- Read the code the issue touches before proposing changes to it.

## 2. Interview

Resolve open design questions with the user before you write.
Follow `~/.claude/rules/ask-vs-discuss.md` if present: build
understanding with plain questions, one at a time; reserve
multiple-choice forms for bounded decisions among known options.
Do not manufacture questions you can settle by reading the repo.

## 3. Write

Write the spec and plan as an inverted pyramid:

1. **Problem** — one sentence naming the problem this work solves.
   Then at most one paragraph on the sub-problems it decomposes into.
   Every later section answers to this sentence.
2. **Decision** — what will be built, in one short paragraph.
3. **Why** — the constraints that picked this design, including
   alternatives rejected and the reason each lost.
4. **Design** — the components, interfaces, and data changes, and the
   change surface the work touches.
5. **Plan** — ordered implementation steps.
6. **Risks and open questions** — only ones that survived the
   interview.

Include only what changes the implementer's next decision.

### Plan steps

Each step is one action with one verification:

- **One action per step.** "Add the field and migrate the callers and
  update the tests" is three steps.
- **Name the verification.** Give the command or the test that shows
  the step landed. A step nobody can check is not a step.
- **No placeholders.** Write the actual names, signatures, and
  commands. "Add error handling" and "update the relevant tests" name
  no work; delete them or replace them with the specific case.
- **Order by dependency.** A step may rely only on steps above it.

### Write for the implementer

The reader is an implementation agent — `sdlc:issue-developer` when
the repo runs the sdlc plugin — or the engineer in that seat. It reads
the issue, opens the tree, and derives its own locations. So the plan
carries what that reader cannot derive:

- The design decision and why the alternatives lost.
- Scope boundaries, and anything ruled out of scope for this issue.
- The bar the work has to clear: which tests must pass, which
  commands must run clean.
- Per-PR obligations the repo imposes, such as a version bump.

Leave out the search you already ran. An exhaustive file inventory or
a line-level edit list goes stale against the tree, and the
implementer derives locations more accurately by reading it. Name the
change surface at the component level — enough to scope the work and
to tell whether it collides with another issue — and stop there.

## 4. Self-review

Review the draft yourself before anyone else sees it. Check:

- **Problem against the issue.** Does the one-sentence problem match
  what the issue actually reports? A plan that solves a different
  problem is wrong however good the design.
- **Plan against the problem.** Does every sub-problem get a step?
  Does every step serve the problem, or has scope crept in?
- **Placeholders.** Any step that names no specific work.
- **Contradictions.** Steps that undo each other, or a step that
  contradicts the Design section.

Fix what you find, then review the fixed draft again. Repeat until a
pass turns up nothing.

## 5. Human review

Show the draft to the user and stop. Do not post until they approve
it. Apply the changes they ask for, then show it again.

## 6. Post

Post the approved spec as a comment on the issue. Prefer an installed
issue skill (for example `/issues:issue-comment`); otherwise use
`gh issue comment`. Then report the comment URL to the user.
