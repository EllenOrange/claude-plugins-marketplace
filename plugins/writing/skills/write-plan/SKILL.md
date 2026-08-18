---
name: write-plan
description: Write an implementation plan for an issue and post it as an issue comment. Use whenever the user asks to plan, spec out, design, or scope the work for an issue, ticket, or feature request, in any phrasing that means "figure out how to build this and write it down on the tracker".
---

# write-plan

Produce an implementation plan for one issue, and post it as a
comment on that issue. Write all prose per the
writing-style rule: the installed copy at
`~/.claude/rules/writing-style.md` if present, else the plugin's
bundled copy at `${CLAUDE_PLUGIN_ROOT}/rules/writing-style.md`.

## 1. Read

- Read the issue. If the user has issue skills installed, for example
  `/issues:issue-view`, use them; they dispatch to the repo's
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

### Sweep each ruling at decision time

When the user rules on a design question, enumerate the ruling's
cross-cutting consequences before you move on. Look for affected
verification commands, doc files, scripts, sibling fields, and scope
statements. Carry every consequence into the plan in the same pass. A
ruling applied at one site and discovered at five others costs a
critique round per site.

## 3. Walk the dependencies

Do this whenever the plan builds on another component, and especially
when that component sits on an unmerged branch. Walk each intended
outline action against the component's actual surface. Ask whether the
API, doc, or schema the action relies on exists, and whether it
expresses what the action needs.

Read the dependency at the ref the plan will build on, not at main.
The branch carries the surface the plan depends on; main does not
carry it yet.

Turn every gap you find into an interview question or into an
explicitly named extension unit in the plan. The plan may not assert
that it is built entirely on a component until this walk passes.

## 4. Propose

After the interview, propose the framing in conversation before you
draft anything. Show the user:

1. **The problem framing.** State the one-sentence problem, in the
   form the plan's Problem section will use.
2. **The scope summary.** Summarize what the work covers and what it
   rules out.
3. **Proposed solutions.** Write each one in the one-paragraph
   solution format. Propose one solution when one is obviously right.
   When viable options exist, propose each, and follow each paragraph
   with a bullet list of its relative pros and cons.

Stop and let the user pick a solution and correct the framing. The
chosen solution and framing feed the plan; the rejected options and
their pros and cons stay in the conversation and never enter the
plan file.

## 5. Write

Write the plan in Markdown, as a file. Draft it to the session
scratchpad if the harness gave you one, else to `.claude/tmp/`. You
revise this file during self-review and post it from the Post step, so
the reader never sees a draft you have already rejected.

The plan has these sections and nothing else. Every section except
References is required:

1. **Problem.** Name the problem this work solves in one sentence.
   Then write at most one paragraph on the sub-problems it decomposes
   into. Every later section answers to this sentence.
2. **Scope.** Write at most one paragraph. Give what this work
   covers, its boundaries, and anything ruled out of scope for this
   issue.
3. **Solution.** Say what will be built, in at most one paragraph.
4. **Outline.** Decompose the work.
5. **Open questions.** Keep only the ones that survived the
   interview. List the questions themselves and nothing else. A
   question the interview settled leaves this section entirely.
6. **References.** Optional. Collect the citations that run too long
   to sit inline in the body.

Include only what changes the implementer's next decision.

Leave out rationale and history:

- Do not argue for the solution.
- Do not list the alternatives you rejected.
- Do not recount how the solution arrived where it did.
- Do not record which critique round found what, when a decision was
  ratified, who ruled on it, or what the text used to say.
- Do not assess risk. That is the reviewers' judgment, and a plan
  that pre-empts it gets it deferred to rather than tested.

Citations are the one exception to that list. A citation serves the
implementer rather than the argument, so it stays.

### The problem states no solution

Write the Problem section in terms of the current behavior and what
it costs the reader. Do not name the fix, the mechanism, or the
component that will change. A problem statement that presupposes its
solution cannot be judged: the reader can no longer ask whether a
different solution serves the same problem better.

These tests catch the failure:

- Read the problem sentence alone. If it already tells you what to
  build, rewrite it.
- Ask whether a second, genuinely different solution could answer the
  same sentence. If none could, the sentence is a solution in
  disguise.

### The solution matches the problem's altitude

Write the Solution section at the same level of abstraction as the
Problem section. Name the shape of the thing you will build, and say
how that shape answers the problem. One paragraph is the whole
budget.

The Solution section is not a list of tasks. Every "then do X" belongs
in the Outline, which carries the work. A Solution section that reads
as steps has taken the Outline's job and left the reader with no
statement of what is being built.

### The outline

Write the Outline section as headed sections, not as a flat list.
Give each unit of work its own Markdown section header, and write
each action as a bullet under that header. The shape carries
information a flat list destroys: which actions belong together,
which land as one commit, and where a unit can be dropped whole.

The outline has these terms. A **unit** is a section header, named for
the work it delivers. An **action** is one thing the implementer
does, written as a bullet under its unit. Head the Outline section
itself with `##`, so each unit header is `###`:

```markdown
## Outline

### Add the retry budget to the client

- Add the `retry_budget` field to `ClientConfig`.
- Verify with `pytest tests/test_config.py`.

### Migrate the callers

- Pass `retry_budget` from `build_client()`.
- Verify with `pytest tests/test_client.py`.
```

Every action obeys:

- **One action per line.** "Add the field and migrate the callers and
  update the tests" is three actions.
- **Name the verification.** Give the command or the test that shows
  the action landed. An action nobody can check is not an action.
- **No placeholders.** Write the actual names, signatures, and
  commands. "Add error handling" and "update the relevant tests" name
  no work; delete them or replace them with the specific case.
- **Order by dependency.** An action may rely only on actions above
  it.

### Cite the authority instead of restating it

The plan carries decisions and obligations. It does not carry copies
of facts the implementer can derive from a repo file, an authority
doc, or a dependency's source. A copy can be wrong today and stale
tomorrow, and every copy is critique surface.

Name the authority instead, and keep the reference terse. A file path
or a rule name in passing is enough inline. Move anything longer to
the References section at the bottom, so the body stays clear,
concise, and prescriptive.

### Consult the authority for external usage

Read the authority before you prescribe how to use an external
dependency or service. This covers an SDK call pattern, a library's
configuration surface, and a service's API or auth flow. The
authority is the official docs, the dependency's source or type
definitions, or the pinned version's README. Web search and WebFetch
are fair game.

A usage pattern written from memory is a guess, and the plan may not
carry one. Cite the authority you consulted, so the prescription
stays terse and the reference carries the detail.

### Write for the implementer

The reader is an implementation agent or the engineer in that seat.
On a repo that runs the sdlc plugin, that agent is
`sdlc:issue-developer`. The reader reads the issue, opens the tree,
and derives its own locations. So the plan carries what that reader
cannot derive:

- The solution it is to build.
- The scope, and anything ruled out of scope for this issue.
- The bar the work has to clear: which tests must pass, which
  commands must run clean.
- Per-PR obligations the repo imposes, such as a version bump. These
  are actions in the outline like any other.

Leave out the search you already ran. An exhaustive file inventory or
a line-level edit list goes stale against the tree, and the
implementer derives locations more accurately by reading it. Name the
change surface at the component level and stop there. That is enough
to scope the work and to tell whether it collides with another issue.

## 6. Self-review

Read the file back and check it. This is the step the file exists
for: the draft is not yet in front of anyone, so a defect you find
here costs an edit rather than a correction.

- **Problem against the issue.** Does the one-sentence problem match
  what the issue actually reports? A plan that solves a different
  problem is wrong however good the solution.
- **Problem against the solution.** Does the problem sentence
  presuppose the solution? Apply both tests under "The problem states
  no solution".
- **Solution altitude.** Does the Solution paragraph sit at the
  Problem section's level of abstraction, or has it decayed into a
  list of tasks the Outline already carries?
- **Outline shape.** Is every unit a section header, and every action
  a bullet under its unit?
- **Outline against the problem.** Does every sub-problem get a unit?
  Does every unit serve the problem, or has scope crept in?
- **Restatements.** Find every sentence that states a fact the
  implementer can derive from a repo file, an authority doc, or a
  dependency's source. Drop the restatement and name the authority
  instead. Keep the inline reference terse, and move a long one to
  the References section.
- **Uncited external usage.** Any prescription for an external SDK,
  library, or service that names no authority. Read the authority
  now, then cite it.
- **Open questions against the body.** Every question the body defers,
  marks unresolved, or points elsewhere for appears in Open questions.
  Open questions lists nothing the body treats as decided, and carries
  no record of formerly open questions or how they were resolved.
- **Placeholders.** Any action that names no specific work.
- **Contradictions.** Actions that undo each other, or an action that
  contradicts the Solution paragraph.
- **Rationale and risk.** Any argument for the solution, rejected
  alternative, or risk assessment that crept back in. Cut it.
- **Writing style.** Read the file against the writing-style rule.
  Check sentence length, one instruction per sentence, one term per
  concept, vertical lists for parallel items, and no parentheticals.

Edit the file to fix what you find, then read it back again. Repeat
until a pass turns up nothing.

## 7. Human review

Show the user the file and stop. Do not post until they approve it.
Apply the changes they ask for to the file, then show it again.

## 8. Post

Post the approved file as a comment on the issue. Prefer an installed
issue skill, for example `/issues:issue-comment`, which reads the
body from a file; otherwise use `gh issue comment --body-file`. Then
report the comment URL to the user.

`writing:plan-converge` runs the critique-and-fix loop over the posted
comment. Run it before promotion. The loop edits a comment, so a plan
already promoted into the issue body needs demoting first.

Once the user approves the plan, `writing:promote-plan` moves it from
the comment into the bottom of the issue body.
