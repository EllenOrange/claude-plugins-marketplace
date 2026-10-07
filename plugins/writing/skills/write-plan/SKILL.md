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

## The state directory

Keep the flow's state in the `write-plan-<issue>` directory that
`writing-plan-state` holds for the target repo. Never use the session
scratchpad for it. `writing:converge-plan` seeds its own ledger from
this directory, so the state has to outlive the session that wrote it.

### Reach the state through the script

This plugin ships `writing-plan-state` in its `bin/`, which the
harness puts on the Bash tool's `PATH` while the plugin is enabled.
The script composes every state path under the XDG state home, and no
skill restates that root. This subsection owns how a seat reaches the
state, and every other site cites it:

- Name no path under the state root, in a tool call or in a Bash
  command. A hook that confines reads and writes to the current repo
  then never sees one.
- Name the directory by three flags: `--repo`, `--skill`, and
  `--issue`. These flags are the state handle. A seat hands a subagent
  the state handle and the file names it needs, never a path.
- Read a file with `--mode print --file <name>`, which writes it to
  stdout. `--mode list` names the files the directory holds.
- Replace a file with `--mode put --file <name> --from <path>`, and
  append to one with `--mode append --file <name> --from <path>`. The
  script refuses a `put` of `evidence.md`.
- Create the directory and an empty `evidence.md` with `--mode init`.
- Stage a file in the staging directory
  `.claude/tmp/writing-<skill>-<issue>/` at the target repo's root,
  under the name of the state file it feeds. Stage there every file
  you pass `--from`, and every file you print out to edit or to post.
  A staged file is a transient copy. Read state only through `print`,
  never from a file another seat staged.

Pass the target repo's `gh repo view --json url --jq .url` value as
`--repo`, unchanged. The script refuses a value with no host, and a
segment it cannot place under the root. Run `--mode init` before any
other write. Stop and report before you write any state when the `gh`
call fails or the script refuses the value. No fallback directory
exists.

### The state's files

The state has these files:

- **`ledger.md`, the decision ledger.** It holds every ruling the
  interview settles and every question still open. Its format is the
  one `converge-plan` → "2. Set up the state" owns. The format splits
  by seat: this seat writes the ruling entries with their class marks
  and the open questions, and the round-indexed fields and the loop
  facts are `converge-plan`'s own. The citation of that format covers
  only the fields this seat writes.
- **`draft.md`, the plan's working copy.** "4. Propose" drafts the
  agreed core into it, and "5. Write" overwrites it with the full
  plan. The post reads this file.
- **`evidence.md`, the evidence log.** This entry owns the record
  shape. A record is appended and never edited. It opens with its
  item's text, then carries:
  - the `file:symbol` it concerns, for a behavior claim or a
    prescribed text
  - the paths the command names, or the tree root when it names none,
    for a command
  - the quoted lines, for a behavior claim
  - the commit the check ran against
  - each verify command, with at most the first 50 lines of its output
    and the total line count
  - the lint or compile run, for a prescribed text
- **The instruction files.** Each sweep call writes its own file,
  under a fixed name:
  - `core-style.md` and `core-batch.md`, for "Draft the core"
  - `style.md`, for "7. Style pipeline"
  - `review-<n>-batch.md`, for the nth pass of "8. Human review"
  - `<file>-fold.md`, beside each `sweep-consequences` instruction file
    `<file>.md` whose questions folded

### Define the ledger's entry classes

Every ruling in the ledger carries one of these class marks. This
subsection owns the marking, and every other site cites it:

- **User-ratified.** The user ruled on the question. The mark makes
  the ruling a fixed constraint for every later critic.
- **Repo-derived.** The answer came from the repo rather than the
  user. The entry keeps its derivation in the ledger beside the
  ruling, so a later reader can test it and veto it. It cites the
  `evidence.md` record that backs it only when the ruling concerns
  code behavior.

A contract-version ruling's derivation records the registry lookup or
the package-source read in the ledger, with its command and output. A
command in a derivation that fails, an auth failure included, blocks
the ruling, and the question stays a `discuss` item.

### The post-success lifecycle

A successful post leaves the directory in place, so
`writing:converge-plan` can seed its ledger from it. Nothing deletes
the directory. It sits outside the target repo, so no repo-local
cleanup indexes it. This skill neither reads nor migrates state from
the repo-local directory earlier versions used. `converge-plan` owns
when seeding fires, and that trigger
makes a stale directory harmless. The reader-side guard for a stale
directory is `converge-plan`'s seed comparison, cited rather than
restated here.

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
- Resolve `sdlc:orchestrate-readiness` per its entry in
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`, and read the
  installed skill. It owns the readiness bar and the issue-body
  grammar, and it has no fallback.

## 2. Interview

Resolve open design questions with the user before you write.
Follow `~/.claude/rules/ask-vs-discuss.md` if present. Build
understanding with plain questions, one at a time. Reserve
multiple-choice forms for bounded decisions among known options.
Do not manufacture questions you can settle by reading the repo.

The interview settles every decision in the "No unanswered design
decisions" item of the installed `sdlc:orchestrate-readiness` bar,
before the draft. This plugin adds one decision to that set: the
authority site of any convention, name, or class the solution
introduces. Enumerate none of the bar's decisions here.

With the sdlc plugin absent, the interview settles the authority-site
decision alone. The report then says that the bar's decision set was
skipped.

### Record each ruling to the ledger

The interview runs uninterrupted. Write each ruling to `ledger.md` as
it lands, marked per "Define the ledger's entry classes", and move on
to the next question. No sweep runs between rulings. "4. Propose"
sweeps the whole ruling set once, so a sweep at decision time only
splits the user's attention and re-runs over the same set.

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
draft anything. The step runs in two stages, because the criteria
answer to the chosen solution and cannot be stated before it.

**Stage one. The framing and the candidate solutions.** Show the user:

1. **The problem framing.** State the one-sentence problem, in the
   form the plan's Problem section will use.
2. **The scope summary.** Summarize what the work covers and what it
   rules out.
3. **Proposed solutions.** Write each one in the one-paragraph
   solution format. Each proposed solution has passed "Walk each
   stated behavior". Propose one solution when one is obviously
   right. When viable options exist, propose each. Follow each
   paragraph with a bullet list of its relative pros and cons.

Stop and let the user pick a solution and correct the framing. The
chosen solution and framing feed the plan. The rejected options and
their pros and cons stay in the conversation and never enter the
plan file.

**Stage two. The criteria the chosen solution earns.** Derive the
Acceptance section's Mechanical and Semantic bullets from the solution
the user picked. State them in the bullet form "State the acceptance
criteria" gives. Record each criterion's evidence per "Record evidence
before the sentence" before you show it. Show them and stop for
correction.

### Draft the core

Draft the agreed core to `draft.md` in the directory "The state
directory" owns. The core is the Problem, Scope, Solution, and
Acceptance sections, written as "5. Write" prescribes them, with
evidence recorded per "Record evidence before the sentence". The
full-plan draft later overwrites `draft.md`, and the core text is not
retained separately.

Then sweep the core once. Every file below is a state file, which a
subagent reaches per "Reach the state through the script":

1. Spawn a general-purpose subagent on the Opus model, per
   `sweep-consequences` → "Execution context". Instruct it to load
   `writing:sweep-consequences`, and pass it the interview's whole
   ruling set as the decision set. Pass it the state handle,
   `draft.md`, `ledger.md`, and `evidence.md` by name, and
   `core-batch.md` as its instruction file.
2. Spawn a second general-purpose subagent on the Opus model, per
   `sweep-style` → "Execution context". Instruct it to load
   `writing:sweep-style`, and pass it the state handle, `draft.md` by
   name, and `core-style.md` as its instruction file.
3. Triage every question the consequence sweep returns, per "Triage
   the sweep's questions".
4. Spawn a third general-purpose subagent, instruct it to load
   `writing:revise-plan`, and pass it the state handle, with
   `draft.md`, `core-batch.md`, and `core-style.md` by name, plus
   `core-batch-fold.md` when a fold ran.
   One revision applies them all.
5. Read the revised file back.

`revise-plan` → "Output" owns the unapplied-instruction resolution
rule. This seat resolves every unapplied instruction before it drafts
the full plan, and a conflict that survives that rule stops the flow
here for the user.

Re-show the revised core to the user only when the revision changed
the Solution or the Acceptance section. Otherwise proceed; human
review covers the rest.

### Triage the sweep's questions

`sweep-consequences` → "Output" owns the triage seat, the finding
shape, the fold rule, and the refute rule. Route every question the
sweep returns through `writing:summarize-findings` as that owner
prescribes. This seat's own behavior is the verdict handling:

- A `fix` verdict's repo-derived answer goes to the one fold call the
  owning Output section prescribes. Spawn that call as a
  general-purpose subagent on the Opus model, per `sweep-consequences`
  → "Execution context", and instruct it to load
  `writing:sweep-consequences`. Pass it the fold-call inputs
  `sweep-consequences` → "What each caller passes" names. Record the
  answer in `ledger.md` as a vetoable ruling, marked per "Define the
  ledger's entry classes", only once the fold call reports its check
  passed.
- A fold answer whose check failed, and every question the fold call
  raises, lands in the ledger as a `discuss` item.
- A `refute` verdict follows the owning Output section.
- A `discuss` verdict reaches the user, and its ruling lands in the
  ledger user-ratified.

`revise-plan` receives the fold file beside the instruction file
whenever a fold ran.

## 5. Write

Draft the full plan in Markdown from the settled core, overwriting
`draft.md` in the directory "The state directory" owns. You revise
this file during
self-review and post it from the Post step, so the reader never sees a
draft you already rejected. `converge-plan`'s seed comparison reads
this file, so the posted plan's own text is what stays on disk.

The plan has these sections, in this order, and nothing else. Every
section is required:

1. **Problem.** Name the problem this work solves in one sentence.
   Then write at most one paragraph on the sub-problems it decomposes
   into. Every later section answers to this sentence.
2. **Scope.** Write at most one paragraph. Give what this work
   covers, its boundaries, and anything ruled out of scope for this
   issue. Derive it per "Derive the scope".
3. **Solution.** Say what will be built, in at most one paragraph.
4. **Acceptance.** Head it `## Acceptance`, with the sub-headings
   `### Mechanical` and `### Semantic` under it. State the claims the
   merged result must satisfy, per "State the acceptance criteria".
5. **Outline.** Decompose the work.
6. **Files affected.** Head it `## Files affected (floor)`. Derive it
   per "Derive the files affected".
7. **Open questions.** Keep only the ones that survived the
   interview. List the questions themselves and nothing else. A
   question the interview settled leaves this section entirely. This
   section owns its empty form: a section with no question carries the
   single line `None.` and no bullet, and a question is a bullet.

`sdlc:orchestrate-readiness` → "The issue-body grammar" owns the
grammar of the Acceptance section and the Files affected section. This
skill copies none of its rules. With the sdlc plugin absent, the plan
still carries the headings this list names.

The Solution section precedes the Acceptance section because the
criteria answer to the solution. A reader who meets the criteria first
has nothing to measure them against.

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

Scope is derived, not recalled. One paragraph is the whole budget,
and this subsection owns that budget. A Scope section that outgrows it
has taken the Outline's job.

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

Scope also describes the work that borders this one, and rules that
work out. It names the bordering work by description and names no
issue number. The issue's edges carry the relation, so find the
bordering work through the issue read that "1. Read" prescribes.

### State the acceptance criteria

The Acceptance section is the PR reviewer's rubric. Write it for that
reader and for no other. Every bullet clears the emission bar in
`sdlc:theorem-generation` → "The emission bar: falsifiability, then
stakes". Read that section from the installed skill. With the sdlc
plugin absent, skip the emission-bar check, and say in the report that
it was skipped.

**The altitude test.** A criterion earns its place only if the PR
reviewer needs it to judge the merged result; anything only the
implementer needs to do the work is Outline material, however it is
phrased. This subsection owns that test, and every other site cites
it.

An action, an implementation step, or an exemplar to imitate is never
a criterion. The review quotes whatever reads as a criterion and
grades it against a High severity floor. So the review grades an
instruction placed here as a requirement of the merged result.

**The bullet form.** This subsection owns it. Every bullet under both
sub-headings is a bold title phrase ending in a period, followed by
one claim sentence:

```markdown
- **The title.** The claim, quantified over a class with its
  membership rule stated.
```

**The Mechanical command.** A bullet under `### Mechanical` names, in
its claim sentence, one read-only command that settles the claim. A
check that needs several commands, or a command that writes to the
tree, is not one Mechanical bullet. Restate it as a Semantic claim, or
split it into several Mechanical bullets with one command each.

**Reconcile with Files affected.** Reconcile each Mechanical bullet's
hits and targets with the Files affected section, per
`sdlc:orchestrate-readiness` → "The executed Mechanical check".

**The size discipline.** A bullet's claim is one sentence. A section
that outgrows the rubric stops being one: the reviewer reads every
bullet every round, so each bullet the plan adds costs every later
round.

**Touched contracts.** Every existing contract the Outline touches
earns one claim. The claim binds every write and read able to violate
the contract, not the consequence of one action.

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
  about the merged result belongs in the Acceptance section. The
  review quotes it as a criterion wherever it sits.
- **Pin a claim with an action.** A test that pins an Acceptance claim
  is an Outline action, with its verify command.
- **Name no test in Acceptance.** No Acceptance bullet names a test.
  The test lives in the Outline action that adds or updates it.

### Derive the files affected

Derive the Files affected section from the Outline, never from recall.
List these paths:

- every file an Outline action touches
- every file a Mechanical bullet's command hits in the tree today
- every file a Mechanical bullet requires a change in

Tag each path per `sdlc:orchestrate-readiness` → "The files-affected
section".

### State the rule that generates each set

A plan bullet often binds an obligation to a set:

- the rpcs a gate covers
- the call sites of a helper
- the writes a touched contract constrains
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
- **A touched contract.** "State the acceptance criteria" owns the
  claim it earns.

`writing:converge-plan` accepts a critique finding as already
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

Name the authority instead, and keep the reference terse. An in-repo
path or a skill name stays inline because the implementer can open it
where they work, while a fact that lives only where the implementer
cannot open it, such as another issue, a pull request, a commit, or a
web page, is restated in the body in the present tense with no URL.
Pointing at a file never stands in for stating a decision.

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

### Name the sibling instead of mirroring its mechanism

A mechanism the plan states in full lives at one owning site. Where a
later unit mirrors a sibling contract, that unit names the sibling and
states what differs from it. It restates none of the mechanism.

This reading reaches prose, not only enumerated lists. A mechanism
paragraph that reads as fresh prose still restates the sibling it
mirrors, and the restatement multiplies the sites each later ruling has
to edit. Every such site is fresh surface for the next critic.

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
carry one. Restate the fact you read in the body, in the present
tense, with no URL. An in-repo authority, such as a dependency's
source path or a skill name, stays inline.

### Record evidence before the sentence

The evidence class is:

- every command the plan carries, run against the tree with its output
  recorded
- every code or config text the plan prescribes verbatim, linted or
  compiled in the seat that writes it
- every claim about how existing code behaves, with the quoted lines

A citation of a section or a path, a decision, and an obligation get
no record.

Write every member of the class from a record appended first to
`evidence.md`, in the shape "The state directory" owns. An item the
seat cannot verify lands under Open questions and never as plan text.
The only unverifiable command is one that cannot run. A command that
runs and reports the tree's current state records that output, a grep
with no hit included.

The log is a record for the critic and for a later postmortem. No seat
matches an item to a record by key. These seats append records while
drafting:

- "4. Propose" stage two
- "Draft the core"
- "5. Write"
- "6. Self-review"

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

Leave out the search you already ran. A line-level edit list goes
stale against the tree, and the implementer derives locations more
accurately by reading it. Name the change surface at the component
level in the Outline. The Files affected section is the plan's one
file list, and "Derive the files affected" owns what it carries.

This section owns the altitude rule's forbidden forms. Plan text names
no `file:line`, no hunk count, and no parameter position. The sites
permitted to restate these forms are this section,
`sweep-consequences` → "Output", and `revise-plan` → "Boundaries".

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
- **Readiness bar.** Grade the draft against every item of the
  installed `sdlc:orchestrate-readiness` bar. Re-run each command the
  plan carries against the tree, per that skill's executed Mechanical
  check, and append each run's record to `evidence.md` per "Record
  evidence before the sentence". Fix every gap. When the locator in
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md` finds no sdlc install,
  skip this item and say in the report that the grading was skipped.
- **Criteria shape.** Does every Acceptance bullet take the bullet
  form "State the acceptance criteria" owns, and does every Mechanical
  bullet name one read-only command? Does each claim quantify over a
  class with its membership rule?
- **Criteria altitude.** Apply the altitude test "State the acceptance
  criteria" owns to every bullet. Move a failing bullet into the
  Outline. Is any bullet an action, an implementation step, or an
  exemplar to imitate wearing the bullet form?
- **Criteria budget.** Does any claim run past one sentence, or does
  any Mechanical bullet need more than one command, against "State the
  acceptance criteria"? Split the bullet, or restate it as a Semantic
  claim.
- **Touched contracts.** Does every existing contract the Outline
  touches have one Acceptance bullet?
- **Evidence.** Does every member of the evidence class have a record,
  per "Record evidence before the sentence"? A fix this review makes
  appends its record as the draft does.
- **Actions that read as results.** Any outline action stating a claim
  about the merged result. Move it to the Acceptance section, per
  "State the how, never the result".
- **Scope against the sweep sections.** Does Scope name the restating
  surfaces of every mirrored fact the plan changes, and does Scope
  describe the bordering work with no issue number, per "Derive the
  scope"?
- **Enumeration beside a citation.** Any list of a class's members
  written next to the citation of the authority for that class.
- **Ownership.** Does the plan name the permitted-restatement set for
  every fact it declares owned, and does the verify command measure
  every spelling of that fact rather than one phrase?
- **Style guides.** Check each outline action against each rule of the
  style guides read in "1. Read". What counts as a rule comes from
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`.
- **Decisions settled.** Is every decision settled in the body,
  rather than posed or implied? The decisions are those of the "No
  unanswered design decisions" item of the installed
  `sdlc:orchestrate-readiness` bar, plus the authority-site decision
  "2. Interview" adds.
- **Outline shape.** Is every unit a section header, and every action
  a bullet under its unit?
- **Outline against the problem.** Does every sub-problem get a unit?
  Does every unit serve the problem, or did scope creep in?
- **Frozen sets.** Find every bullet that binds an obligation to a
  list of sites, fields, or rpcs. Each one states the membership
  rule and carries a class-level sweep action with a verify command,
  per "State the rule that generates each set". Check each
  touched-contract claim the same way, against "State the acceptance
  criteria".
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
  instead. Keep the inline reference terse, and restate a fact from
  outside the repo in the body with no URL, per "Cite the authority
  instead of restating it".
- **Uncited external usage.** Any prescription for an external SDK,
  library, or service that names no authority. Read the authority
  now, then cite it.
- **Open questions against the body.** Every question the body defers,
  marks unresolved, or points elsewhere for appears in Open questions.
  Open questions lists nothing the body treats as decided, and carries
  no record of formerly open questions or how each one closed. A
  question left here is a design decision the plan does not answer,
  so promotion stops on it.
- **The empty form.** An Open questions section with no question reads
  the single line `None.` and carries no bullet, in the form
  "5. Write" owns. The Acceptance section has no empty form, so an
  Acceptance section with no bullet is a defect rather than a form.
- **Placeholders.** Any action that names no specific work.
- **Contradictions.** Actions that undo each other, or an action that
  contradicts the Solution paragraph.
- **Rationale and risk.** Any argument for the solution, rejected
  alternative, or risk assessment that crept back in. Cut it.
- **Writing style.** Leave this to "7. Style pipeline", which owns the
  style pass over the whole file.

Edit the file to fix what you find, then read it back again. Repeat
until a pass turns up nothing.

## 7. Style pipeline

Run the whole-draft style pass once, before anyone sees the file:

1. Spawn a general-purpose subagent on the Opus model, per
   `sweep-style` → "Execution context". Instruct it to load
   `writing:sweep-style`, and pass it the state handle, `draft.md` by
   name, and `style.md` as its instruction file.
2. Spawn a second general-purpose subagent, instruct it to load
   `writing:revise-plan`, and pass it the state handle, with
   `draft.md` and `style.md` by name.
3. Read the revised file back.

`revise-plan` → "Output" owns the unapplied-instruction resolution
rule. This seat reports to the user a conflict that survives it.

This is the only whole-draft style pass. A human-review change rides
the consequence sweep below and `revise-plan`'s read-back, so no
second whole-draft pass runs.

## 8. Human review

Show the user the file and stop. Do not post until they approve it.

This step is the veto surface for the repo-derived rulings that
"Triage the sweep's questions" recorded. Present each one with its
derivation. A ruling the user leaves standing carries forward, and
`writing:converge-plan` inherits it as vetoable when it seeds.

Apply the changes they ask for through this pipeline. On the nth pass
of this step, every file below is a state file, which a subagent
reaches per "Reach the state through the script":

1. Spawn a general-purpose subagent on the Opus model, per
   `sweep-consequences` → "Execution context". Instruct it to load
   `writing:sweep-consequences`, and pass it the requested changes as
   the decision set. Pass it the state handle, `draft.md`,
   `ledger.md`, and `evidence.md` by name, and `review-<n>-batch.md` as
   its instruction file.
2. Triage every question the sweep returns, per "Triage the sweep's
   questions".
3. Spawn a second general-purpose subagent, instruct it to load
   `writing:revise-plan`, and pass it the state handle, with
   `draft.md` and `review-<n>-batch.md` by name, plus
   `review-<n>-batch-fold.md` when a fold ran. The seat composes no
   batch of its own.
4. Read the revised file back, then show it again.

`revise-plan` → "Output"
owns the unapplied-instruction resolution rule, and this seat reports
to the user a conflict that survives it. The sweep walks every
behavior the change alters before the edit, and `revise-plan`'s
read-back covers the edit itself, so this step runs no walk of its
own.

## 9. Post

Post `draft.md` from the directory "The state directory" owns as a
comment on the issue. Print it into the staging directory and post
that copy, per "Reach the state through the script". Every
human-review edit lands in `draft.md` through `revise-plan` before the
post, and nothing edits the text at post time. Prefer an installed
issue skill, for example `/issues:issue-comment`, which reads the body
from a file. Otherwise use `gh issue comment --body-file`. Then report
the comment URL to the user.

`writing:converge-plan` runs the critique-and-fix loop over the plan.
It loops over the comment or over the promoted plan in the issue body,
whichever the plan lives on.

The review that grades the implementation reads the issue body and
never its comments, per
`${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`. So
`writing:promote-plan` is the step that puts the plan in front of that
review, and a plan left in a comment never reaches it. Promotion
precedes `sdlc:orchestrate-ready` grooming. That grooming is the last
step before orchestration, and it reads the promoted plan as part of
the body it rewrites. Promotion stops and asks on a plan whose Open
questions section carries a bullet. It also stops and asks on a plan
that fails an item of the `sdlc:orchestrate-readiness` bar. Both stops
follow `promote-plan` → "2. Read the plan verbatim".
