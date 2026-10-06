---
name: sweep-consequences
description: Sweep a plan for the edits a set of decisions forces, and emit them as edit instructions plus the questions the sweep could not settle. Use when a plan skill has a batch of accepted fixes or ratified rulings to turn into targeted edits, and when the user asks what a set of changes to a plan drags with it.
---

# sweep-consequences

Discover the edits a decision set forces on a plan and emit them as
instructions. This skill edits no plan and posts nothing. It writes
only the instruction file its caller names, and appends only to the
evidence file its caller names. `writing:revise-plan` applies what
this skill emits. Write all prose per the communication-style rule.
Use the installed copy at `~/.claude/rules/communication-style.md` if
present, else the plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

The sibling skill `writing:sweep-style` carries the style agenda.

## Execution context

Every call runs in a fresh-context general-purpose subagent on the
Opus model, in every caller. The caller spawns that subagent, names
the model inline, and instructs it to load this skill. This section is
the owning statement of the model choice, and every spawn site cites
it.

A sweep run in the caller's accumulated context inherits the
assumptions that hid the sibling instances in the first place.

## Inputs

- **The decision set.** Required. It is a set of decisions, never one
  decision: the round's accepted fix findings, or the rulings the user
  ratified across an interview or a pause. A set of one is the k=1
  case of the same shape.
- **The plan text, by path.** Optional, and passed whenever a plan
  text exists.
- **The ledger, by path.** Optional, and passed whenever a ledger
  exists.
- **The instruction-file path.** Required from every caller.
- **The evidence-file path.** Required from every caller. It names the
  caller's `evidence.md`.

## Output

Write the instructions to the instruction file, truncating it first.
Append a record to the evidence file for each evidence item an
instruction adds or changes in meaning, in the record shape
`write-plan` → "The state directory" owns. Edit no plan and post
nothing. Return any question a behavior walk left unanswered.

This section owns the instruction-file format, and every other site
cites it. The file is a Markdown list with one instruction per item.
Each instruction names the plan section it targets and the change to
make there.

Emit the primary instruction for each decision in the set that forces
an edit, as well as its consequences, so the caller composes no
instruction of its own.

No instruction names a `file:line`, a hunk count, or a parameter
position. `write-plan` → "Write for the implementer" owns these
forbidden forms.

An instruction may prescribe a restructuring move. `revise-plan` →
"The edit rules" owns those moves.

This section owns the question channel. Every caller cites this owner
rather than restating the mechanism. The obligations on a caller are:

- A question leaves this skill as a question, never as an instruction.
- The caller triages every question through
  `writing:summarize-findings`.
- The triage runs in the calling seat's own context.
- A question enters `summarize-findings` as a finding whose Problem
  sentence is the question.
- The repo-derived answers of the `fix`-triaged questions become the
  decision set of exactly one fold call of this skill. The fold call
  takes the same evidence file and writes `<file>-fold.md` beside the
  instruction file `<file>.md` of the call whose questions it folds.
  It re-checks each answer against the tree and appends the answer's
  records. The caller writes no instruction.
- A fold call writes no instruction for an answer whose check failed,
  and returns that answer as a question.
- Every question a fold call raises, and every failed answer it
  returns, is a `discuss` item for the caller. No fold call follows a
  fold call.
- The caller records a `fix`-triaged answer as a ruling only after the
  fold call reports its check passed.
- A `refute`-triaged question drops, with its reason recorded.
- A `discuss`-triaged question reaches the user.

## What each caller passes

Every path a caller passes sits in its own state directory.

- **`writing:converge-plan`** passes the round's accepted batch plus
  the standing Open questions sync as the decision set. The sync
  carries the located plan surface and its form rule. It also passes
  the round's plan text, the ledger, and its evidence copy by path,
  and `batch-<round>.md` as the instruction file.
- **`writing:write-plan`'s core-draft seat** passes the interview's
  whole ruling set as the decision set, plus the core draft, the
  ledger, and `evidence.md` by path, and `core-batch.md` as the
  instruction file. The core draft carries the Problem, Scope,
  Solution, and Acceptance sections and no other, so an instruction
  targets those sections by the fixed section names `write-plan` →
  "5. Write" owns. Its instructions land in the revision `write-plan`
  → "Draft the core" runs, before the full plan is drafted.
- **`writing:write-plan`'s human-review seat** passes the requested
  changes as the decision set, plus the draft, the ledger, and
  `evidence.md` by path, and `review-<n>-batch.md` as the instruction
  file.
- **Each caller's fold call** passes the `fix`-triaged answers as the
  decision set, the same plan text, ledger, and evidence file by path,
  and the fold file "Output" names as the instruction file.

## The decision-set agenda

Enumerate the cross-cutting consequences of every decision in the set.
Look for these affected surfaces:

- verification commands
- doc files
- scripts
- sibling fields
- scope statements

Run `write-plan` → "Walk each stated behavior" over each behavior the
set alters, before any prose changes. Every answer lands in the plan
at one owning site. A question the walk leaves unanswered leaves this
skill as a question, per "Output". So does a fix whose walk needs
mechanism the plan does not state: it never becomes an instruction.

When a decision is a fix, enumerate every other instance of the same
defect class in the plan. Each instance becomes its own instruction.

Emit one instruction per consequence and per instance. A consequence
applied at one site and discovered at five others costs a critique
round per site.

A fix that touches a rule stated at several sites is the exception.
It emits one instruction, which names one owner and replaces each
other site with a citation. The owner is the site `write-plan` →
"Cite the authority instead of restating it" selects.

An evidence item is a member of the class `write-plan` → "Record
evidence before the sentence" defines. Append an item's record before
you emit the instruction that carries the item. A pure reword needs no
fresh record.
