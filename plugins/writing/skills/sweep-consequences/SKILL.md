---
name: sweep-consequences
description: Sweep a plan for the edits a set of decisions forces, and emit them as edit instructions plus the questions the sweep could not settle. Use when a plan skill has a batch of accepted fixes or ratified rulings to turn into targeted edits, and when the user asks what a set of changes to a plan drags with it.
---

# sweep-consequences

Discover the edits a decision set forces on a plan and emit them as
instructions. This skill writes nothing. `writing:revise-plan` applies
what this skill emits. Write all prose per the communication-style
rule. Use the installed copy at
`~/.claude/rules/communication-style.md` if present, else the plugin's
bundled copy at `${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

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

## Output

A list of edit instructions, plus any question a behavior walk left
unanswered. Each instruction names the plan section it targets and the
change to make there. This skill writes no file and posts nothing.

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
- A `fix`-triaged question's repo-derived answer folds into the same
  instruction batch its sweep emitted, with no consequence sweep of
  its own.
- A `refute`-triaged question drops, with its reason recorded.
- A `discuss`-triaged question reaches the user.

## What each caller passes

- **`writing:converge-plan`** passes the round's accepted batch, the
  round's plan text by path, and the ledger by path.
- **`writing:write-plan`'s core-draft seat** passes the interview's
  whole ruling set as the decision set, plus the core draft and the
  ledger by path. The core draft carries the Problem, Scope, Solution,
  and Acceptance criteria sections and no other, so an instruction
  targets those sections by the fixed section names `write-plan` →
  "5. Write" owns. Its instructions land in the revision `write-plan`
  → "Draft the core" runs, before the full plan is drafted.
- **`writing:write-plan`'s human-review seat** passes the requested
  changes as the decision set, plus the draft and the ledger by path.

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
skill as a question, per "Output".

When a decision is a fix, enumerate every other instance of the same
defect class in the plan. Each instance becomes its own instruction.

Emit one instruction per consequence and per instance. A consequence
applied at one site and discovered at five others costs a critique
round per site.
