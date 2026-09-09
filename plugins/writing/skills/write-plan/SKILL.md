---
name: write-plan
description: Write an implementation plan for an issue and post it as an issue comment. Use whenever the user asks to plan, spec out, design, or scope the work for an issue, ticket, or feature request, in any phrasing that means "figure out how to build this and write it down on the tracker".
---

# write-plan

Produce an implementation plan for one issue, and post it as a
comment on that issue. Write all prose per the communication-style
rule. Use the installed copy at
`~/.claude/rules/communication-style.md` if present, else the plugin's
bundled copy at `${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

## 1. Read

- Read the issue. If the user has issue skills installed, for example
  `/issues:issue-view`, use them. They dispatch to the repo's
  configured tracker. Otherwise use `gh issue view`.
- Read `CLAUDE.md` and `README.md`. Then read the docs under `docs/`
  that cover the area the issue touches, and any file the issue
  references. Do not read the whole `docs/` tree.
- Read the code the issue touches before proposing changes to it.
- Resolve the review's sources per
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`. Read the installed
  skill it names, or its fallback. Then read the style guides it names,
  with the per-guide fallback it states.
  Its hardest rule: the acceptance-criteria source is exempt from the
  review's stakes bar and carries a High severity floor.

## 2. Interview

Resolve open design questions with the user before you write.
Follow `~/.claude/rules/ask-vs-discuss.md` if present. Build
understanding with plain questions, one at a time. Reserve
multiple-choice forms for bounded decisions among known options.
Do not manufacture questions you can settle by reading the repo.

The interview settles every decision that
`${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md` names as the decision
set, before the draft. Resolve that set per the resolution order in
that file. Enumerate none of it here.

### Sweep each ruling at decision time

When the user rules on a design question, enumerate the ruling's
cross-cutting consequences before you move on.

Run "Walk each stated behavior" over each behavior the ruling
changes, before you edit any prose. Every answer lands in the plan at
one owning site. The walk writes nowhere else.

Then look for these affected surfaces:

- verification commands
- doc files
- scripts
- sibling fields
- scope statements

Carry every consequence into the plan in the same pass. A ruling
applied at one site and discovered at five others costs a critique
round per site.

### Walk each stated behavior

Run this walk before the interview closes. Walk every behavior the
plan's Solution or Outline states. A behavior is anything the plan
says happens after the code ships. Anything the implementer does is
not a behavior.

Ask first what class rule the target repo states for that kind of
behavior. When such a rule exists, walk the behavior against it.

When no class rule covers the behavior, apply this test. If the plan
describes behavior, verify that it specifies enough to implement the
behavior on every path, including each way it fails to complete. If
the behavior is conditional, verify that it names the decider and the
information the decision needs. If another part of the plan relies on
the behavior, verify that what it relies on is stated.

An unanswered question becomes an interview question. It never
becomes a plan sentence.

Each answer lands at one owning site, per "Cite the authority instead
of restating it".

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
3. **The acceptance criteria and invariants.** State them in the entry
   shape "State the acceptance criteria" gives. They are the
   definition of done, and you measure every candidate solution below
   against them.
4. **Proposed solutions.** Write each one in the one-paragraph
   solution format. Each proposed solution has passed "Walk each
   stated behavior". Propose one solution when one is obviously
   right. When viable options exist, propose each. Follow each
   paragraph with a bullet list of its relative pros and cons.

Stop and let the user pick a solution and correct the framing. The
chosen solution and framing feed the plan. The rejected options and
their pros and cons stay in the conversation and never enter the
plan file.

The chosen solution makes one addition to the criteria: the draft adds
the contract-level criteria that solution commits to. That is the only
addition it makes.

## 5. Write

Write the plan in Markdown, as a file. Draft it to the session
scratchpad if the harness gave you one, else to `.claude/tmp/`. You
revise this file during self-review and post it from the Post step, so
the reader never sees a draft you already rejected.

The plan has these sections and nothing else. Every section except
References is required:

1. **Problem.** Name the problem this work solves in one sentence.
   Then write at most one paragraph on the sub-problems it decomposes
   into. Every later section answers to this sentence.
2. **Scope.** Write at most one paragraph. Give what this work
   covers, its boundaries, and anything ruled out of scope for this
   issue. Derive it per "Derive the scope".
3. **Acceptance criteria.** State the claims the merged result must
   satisfy, per "State the acceptance criteria". This section carries
   an `### Invariants` subsection, always.
4. **Solution.** Say what will be built, in at most one paragraph.
5. **Outline.** Decompose the work.
6. **Open questions.** Keep only the ones that survived the
   interview. List the questions themselves and nothing else. A
   question the interview settled leaves this section entirely. This
   section owns its empty form: a section with no question carries the
   single line `None.` and no bullet, and a question is a bullet. The
   Invariants subsection owns the same empty form: a subsection with
   no contract to keep carries the single line `None.` followed by one
   clause saying why the Outline touches no contract.
7. **References.** Optional. Collect the citations that run too long
   to sit inline in the body.

Include only what changes the implementer's next decision.

Leave out rationale and history:

- Do not argue for the solution.
- Do not list the alternatives you rejected.
- Do not recount how the solution arrived where it did.
- Do not record the plan's history:
  - which critique round found what
  - when the user ratified a decision
  - who ruled on it
  - what the text used to say
- Do not assess risk. That is the reviewers' judgment. A plan that
  pre-empts it makes the reviewers defer to it rather than test it.

Citations are the one exception to that list. A citation serves the
implementer rather than the argument, so it stays.

### The problem states no solution

Write the Problem section in terms of the current behavior and what
it costs the reader. Do not name the fix, the mechanism, or the
component that will change. Nobody can judge a problem statement
that presupposes its solution: the reader can no longer ask whether a
different solution serves the same problem better.

These tests catch the failure:

- Read the problem sentence alone. If it already tells you what to
  build, rewrite it.
- Ask whether a second, genuinely different solution could answer the
  same sentence. If none could, the sentence is a solution in
  disguise.

### Derive the scope

Scope is derived, not recalled.

Read every sweep section in the sweep-carrying files that the
codebase-consistency section of
`${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md` names. Recognise a
sweep section by the definition the codebase-consistency section
cites. For each mirrored fact the plan changes, Scope names the
surfaces that restate it. For each such fact, the Outline carries one
class-level sweep action with a grep-shaped verify command.

Editing any text in a file obliges every rule the repo states over
touched text, not only over new text. So a file the plan edits at all
brings its whole surface under those rules.

Scope also names, by number, every issue whose work borders this one,
and rules that work out. Read the borders from the issue's edges,
through the issue read that "1. Read" prescribes. The edges are:

- blocked-by
- blocking
- parent
- sub-issue
- References

With no issue skill installed, the edge set is the References lines
of the issue body, and Scope says so.

### State the acceptance criteria

The Acceptance criteria section is the only plan text that survives
into every round of the review that grades the implementation. Cite
`${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md` for the bar a criterion
clears.

Each criterion is one bullet carrying these parts:

- **The claim.** What the merged result satisfies, quantified over a
  class with its membership rule stated. State what a consumer of the
  merged result relies on.
- **`Check:`** The command or the read that settles the claim.
- **`Pinned by:` or `Waiver:`** Name the test the diff adds or
  updates, or say why none exists.

An action, an implementation step, or an exemplar to imitate is never
a criterion. The review quotes whatever reads as a criterion and
grades it against a High severity floor. So the review grades an
instruction placed here as a requirement of the merged result.

The `### Invariants` subsection carries the existing contracts,
consumers, and tests the change must leave intact. Each entry takes
the parts a criterion takes, so every invariant names its own
`Check:` clause and its own `Pinned by:` or `Waiver:` clause. An
invariant binds every write and read able to violate it, not the
consequence of one action. Every contract the Outline touches has an
invariant or a waiver naming it.

### The solution matches the problem's altitude

Write the Solution section at the same level of abstraction as the
Problem section. Name the shape of the thing you will build. Say how
that shape answers the problem. One paragraph is the whole budget.

The Solution section is not a list of tasks. Every "then do X" belongs
in the Outline, which carries the work. A Solution section that reads
as steps takes the Outline's job and leaves the reader with no
statement of what the work builds.

### The outline

Write the Outline section as headed sections, not as a flat list.
Give each unit of work its own Markdown section header. Write each
action as a bullet under that header. The shape carries information a
flat list destroys:

- which actions belong together
- which actions land as one commit
- where the implementer can drop a unit whole

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
  no work. Delete them or replace them with the specific case.
- **Order by dependency.** An action may rely only on actions above
  it.
- **State the how, never the result.** An action that reads as a claim
  about the merged result belongs in Acceptance criteria. The review
  quotes it as a criterion wherever it sits.

### State the rule that generates each set

A plan bullet often binds an obligation to a set:

- the rpcs a gate covers
- the call sites of a helper
- the writes an invariant constrains
- the consumers a change affects

State the membership rule that generates the set. Write the
obligation as a class-level sweep action: an action that names the
class, instructs a sweep for every instance, and carries a verify
command. A named site is an illustration, never the set. An
implementer reads a bare list as exhaustive and frozen. The members
the list missed ship unbuilt and untested.

These cases bite hardest:

- **A shared helper or single code path.** Every contract, test, and
  doc obligation about it quantifies over the helper's call sites,
  not over an example list in another bullet.
- **An invariant.** "State the acceptance criteria" defines it and
  owns its shape.

`writing:plan-converge` accepts a critique finding as already
covered only when the plan carries such a class-level sweep action
with a verify command. A plan written this way clears that bar from
the first round.

### Mark every waiver

Make silence distinguishable from a waiver. Wherever the plan
could be read as deliberately leaving something out, say which it
is:

- A sibling path without a pattern its twin spells out. Say whether
  the sibling follows the pattern or is exempt, and why the
  exemption holds.
- A stated guarantee with no pinning test. Name the test, or say the
  guarantee ships untested and why.
- A check whose predicate is left to the reader. A bullet that pins
  the order of checks also pins, or cites the authority for, what
  each check evaluates.

An implementer treats an unmarked silence as a decision. One
explicit waiver elsewhere in the plan makes every other silence read
as deliberate too.

### Cite the authority instead of restating it

The plan carries decisions and obligations. It does not carry copies
of facts the implementer can derive from a repo file, an authority
doc, or a dependency's source. A copy can be wrong today and stale
tomorrow, and every copy is critique surface.

Name the authority instead. Keep the reference terse. A file path
or a rule name in passing is enough inline. Move anything longer to
the References section at the bottom, so the body stays clear,
concise, and prescriptive.

When the plan cites an authority for a class, it does not enumerate
the class's members beside the citation. A short enumeration reads as
the class and wins over the authority it sits next to. Mark a named
member as an illustration, per "State the rule that generates each
set".

The same rule governs text the plan itself authors. When the plan
writes a derivation or contract text in full, name the single file
that owns it. Every other site the plan touches cites the owner
instead of carrying a second copy.

Name the permitted-restatement set: the sites allowed to carry the
fact. The verify command measures every spelling of the fact across
the touched surfaces, not one phrase. A count of one phrase passes
while the review counts the rest.

### Consult the authority for external usage

Read the authority before you prescribe how to use an external
dependency or service. This covers:

- an SDK call pattern
- a library's configuration surface
- a service's API or auth flow

The authority is one of:

- the official docs
- the dependency's source or type definitions
- the pinned version's README

Web search and WebFetch are fair game.

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
  Problem section's level of abstraction, or is it a list of tasks
  the Outline already carries?
- **Stated behavior.** Run "Walk each stated behavior" over the
  drafted Solution and Outline. Every behavior passes the walk's
  test, or the question it fails on sits under Open questions.
- **Criteria shape.** Does every criterion state a claim about the
  merged result, quantified over a class with its membership rule?
  Does each carry a `Check:` clause and a `Pinned by:` or `Waiver:`
  clause, per "State the acceptance criteria"? Is any criterion an
  action, an implementation step, or an exemplar to imitate wearing
  those clauses? Move that one into the Outline.
- **Touched contracts.** Does every existing contract the Outline
  touches have an invariant or a waiver naming it?
- **Actions that read as results.** Any outline action stating a claim
  about the merged result. Move it to Acceptance criteria, per "State
  the how, never the result".
- **Scope against the sweep sections.** Does Scope name the restating
  surfaces of every mirrored fact the plan changes, and does Scope
  name the neighboring issues by number, per "Derive the scope"?
- **Enumeration beside a citation.** Any list of a class's members
  written next to the citation of the authority for that class.
- **Ownership.** Does the plan name the permitted-restatement set for
  every fact it declares owned, and does the verify command measure
  every spelling of that fact rather than one phrase?
- **Style guides.** Check each outline action against each rule of the
  style guides read in "1. Read". What counts as a rule comes from
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`.
- **Decisions settled.** Is every decision the decision set names
  settled in the body, rather than posed or implied? The set and its
  resolution order come from
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`.
- **Outline shape.** Is every unit a section header, and every action
  a bullet under its unit?
- **Outline against the problem.** Does every sub-problem get a unit?
  Does every unit serve the problem, or did scope creep in?
- **Frozen sets.** Find every bullet that binds an obligation to a
  list of sites, fields, or rpcs. Each one states the membership
  rule and carries a class-level sweep action with a verify command,
  per "State the rule that generates each set". Check each invariant
  the same way, against the shape "State the acceptance criteria"
  gives it.
- **Unmarked silences.** Each of these says waiver or obligation, per
  "Mark every waiver":
  - sibling paths missing a pattern their twin spells out
  - guarantees with no pinning test
  - checks whose predicate the plan leaves to the reader
- **Unowned text.** Every derivation or contract text the plan
  authors names one owning file, and every other site cites it.
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
  no record of formerly open questions or how each one closed.
- **The empty form.** An Open questions section with no question reads
  the single line `None.` and carries no bullet. An Invariants
  subsection with no invariant reads `None.` followed by its one
  clause saying why the Outline touches no contract. Both forms are
  the ones "5. Write" owns, and the sibling skills that cite the owner
  key on the Open questions form. The Invariants subsection has a second
  reader that does not. The acceptance-criteria source in
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md` asks instead whether
  every contract the Outline touches carries an invariant or a waiver.
  So a well-formed `None.` still fails when the Outline touches one.
- **Placeholders.** Any action that names no specific work.
- **Contradictions.** Actions that undo each other, or an action that
  contradicts the Solution paragraph.
- **Rationale and risk.** Any argument for the solution, rejected
  alternative, or risk assessment that crept back in. Cut it.
- **Writing style.** Read the file against the communication-style rule.
  Check each of these:
  - sentence length
  - one instruction per sentence
  - one term per concept
  - vertical lists for parallel items
  - no parentheticals

Edit the file to fix what you find, then read it back again. Repeat
until a pass turns up nothing.

## 7. Human review

Show the user the file and stop. Do not post until they approve it.
Apply the changes they ask for to the file.

Run "Walk each stated behavior" over every behavior those changes add
or alter, before you show the file again. Walk those behaviors alone.
Self-review already walked the rest, and no change since then touched
them. Then show the file again.

## 8. Post

Post the approved file as a comment on the issue. Prefer an installed
issue skill, for example `/issues:issue-comment`, which reads the
body from a file. Otherwise use `gh issue comment --body-file`. Then
report the comment URL to the user.

`writing:plan-converge` runs the critique-and-fix loop over the plan.
It loops over the comment or over the promoted plan in the issue body,
whichever the plan lives on.

The review that grades the implementation reads the issue body and
never its comments, per
`${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`. So
`writing:promote-plan` is the step that puts the plan in front of that
review, and a plan left in a comment never reaches it. Promotion
precedes `sdlc:orchestrate-ready` grooming. That grooming is the last
step before orchestration, and it reads the promoted plan as part of
the body it rewrites. On a plan whose Open questions section carries a
bullet, promotion stops and asks, per `promote-plan` → "2. Read both
texts verbatim".
