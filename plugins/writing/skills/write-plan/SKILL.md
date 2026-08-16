---
name: write-plan
description: Write an implementation plan for an issue and post it as an issue comment. Use whenever the user asks to plan, spec out, design, or scope the work for an issue, ticket, or feature request — any phrasing that means "figure out how to build this and write it down on the tracker".
---

# write-plan

Produce an implementation plan for one issue, and post it as a
comment on that issue. Write all prose per the
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

## 3. Propose

After the interview, propose the framing in conversation before you
draft anything. Show the user:

1. **The problem framing** — the one-sentence problem, in the form
   the plan's Problem section will use.
2. **The scope summary** — a high-level summary of what the work
   covers and what it rules out.
3. **Proposed solutions** — each in the one-paragraph solution
   format. Propose one solution when one is obviously right. When
   viable options exist, propose each, and follow each paragraph with
   a bullet list of its relative pros and cons.

Stop and let the user pick a solution and correct the framing. The
chosen solution and framing feed the plan; the rejected options and
their pros and cons stay in the conversation and never enter the
plan file.

## 4. Write

Write the plan in Markdown, as a file. Draft it to the session
scratchpad if the harness gave you one, else to `.claude/tmp/`. You
revise this file in step 5 and post it from step 7, so the reader
never sees a draft you have already rejected.

The plan has five sections and nothing else:

1. **Problem** — one sentence naming the problem this work solves.
   Then at most one paragraph on the sub-problems it decomposes into.
   Every later section answers to this sentence.
2. **Scope** — at most one paragraph. What this work covers, its
   boundaries, and anything ruled out of scope for this issue.
3. **Solution** — what will be built, in at most one paragraph.
4. **Outline** — the work, decomposed.
5. **Open questions** — only ones that survived the interview.

Include only what changes the implementer's next decision.

Leave out rationale and history:

- Do not argue for the solution.
- Do not list the alternatives you rejected.
- Do not recount how the solution arrived where it did.
- Do not assess risk. That is the reviewers' judgment, and a plan
  that pre-empts it gets it deferred to rather than tested.

### The outline

Write the Outline section as a nested outline, not a flat list. The
top level names the units of work; each unit decomposes into the
actions that deliver it. The shape carries information a flat list
destroys: which actions belong together, which land as one commit,
and where a unit can be dropped whole.

The outline has two levels and two terms. A **unit** is a top-level
entry. An **action** is one thing the implementer does, nested under
its unit. Every action obeys:

- **One action per line.** "Add the field and migrate the callers and
  update the tests" is three actions.
- **Name the verification.** Give the command or the test that shows
  the action landed. An action nobody can check is not an action.
- **No placeholders.** Write the actual names, signatures, and
  commands. "Add error handling" and "update the relevant tests" name
  no work; delete them or replace them with the specific case.
- **Order by dependency.** An action may rely only on actions above
  it.

### Write for the implementer

The reader is an implementation agent — `sdlc:issue-developer` when
the repo runs the sdlc plugin — or the engineer in that seat. It reads
the issue, opens the tree, and derives its own locations. So the plan
carries what that reader cannot derive:

- The solution it is to build.
- The scope, and anything ruled out of scope for this issue.
- The bar the work has to clear: which tests must pass, which
  commands must run clean.
- Per-PR obligations the repo imposes, such as a version bump. These
  are actions in the outline like any other.

Leave out the search you already ran. An exhaustive file inventory or
a line-level edit list goes stale against the tree, and the
implementer derives locations more accurately by reading it. Name the
change surface at the component level — enough to scope the work and
to tell whether it collides with another issue — and stop there.

## 5. Self-review

Read the file back and check it. This is the step the file exists
for: the draft is not yet in front of anyone, so a defect you find
here costs an edit rather than a correction.

- **Problem against the issue.** Does the one-sentence problem match
  what the issue actually reports? A plan that solves a different
  problem is wrong however good the solution.
- **Outline against the problem.** Does every sub-problem get a unit?
  Does every unit serve the problem, or has scope crept in?
- **Placeholders.** Any action that names no specific work.
- **Contradictions.** Actions that undo each other, or an action that
  contradicts the Solution paragraph.
- **Rationale and risk.** Any argument for the solution, rejected
  alternative, or risk assessment that crept back in. Cut it.
- **Writing style.** Read the file against the writing-style rule.
  Check sentence length, one instruction per sentence, one term per
  concept, and vertical lists for parallel items.

Edit the file to fix what you find, then read it back again. Repeat
until a pass turns up nothing.

## 6. Human review

Show the user the file and stop. Do not post until they approve it.
Apply the changes they ask for to the file, then show it again.

## 7. Post

Post the approved file as a comment on the issue. Prefer an installed
issue skill (for example `/issues:issue-comment`), which reads the
body from a file; otherwise use `gh issue comment --body-file`. Then
report the comment URL to the user.
