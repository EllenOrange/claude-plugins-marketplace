---
name: critique-plan
description: Critique a plan or spec — list decisions that fall short or cause problems elsewhere, and list gaps. Use whenever the user asks to critique, review, red-team, poke holes in, or find problems with a plan, spec, design doc, brief, or RFC, even when they don't use the word "critique".
---

# critique-plan

Critique one plan or spec against the problems it claims to solve.
Write all prose per the writing-style rule: the installed copy at
`~/.claude/rules/writing-style.md` if present, else the plugin's
bundled copy at `${CLAUDE_PLUGIN_ROOT}/rules/writing-style.md`.

## 1. Read

- Read the plan in full — from the file, issue comment, or text the
  user points at.
- Read the originating issue, if the plan has one. It is the source
  the plan's problem definition answers to.
- Read `CLAUDE.md` and `README.md`. Then read the docs under `docs/`
  that cover the area the plan touches, and anything the plan
  references. Do not read the whole `docs/` tree.
- Read the code the plan touches. A critique built only on the plan's
  own text repeats the plan's blind spots.

## 2. Check the problem definition

Do this first. A plan aimed at the wrong problem fails whatever its
design, so the rest of the critique is worthless until this passes.

- **Does the plan define the problem at all?** A plan that opens on a
  solution has skipped the step that makes it judgeable.
- **Does the problem match the issue?** Compare the plan's problem
  statement against what the originating issue reports. Name any
  drift: a narrower problem silently descopes the issue, a wider one
  smuggles in work nobody asked for.
- **Does the plan solve the problem it states?** Every sub-problem
  needs a decision that addresses it.

## 3. Critique

Judge each decision in the plan against two failure modes:

- The decision does not fully address the problem it targets.
- The decision causes a problem elsewhere: in other code, other
  workflows, or later steps of the same plan.

Then hunt for gaps: identified problems no decision addresses, and
steps the plan needs but does not contain.

## 4. Collect

Write every candidate finding down as rough notes. No format, no
priority order, no verdicts — those come next, and assigning them now
costs you the finding you would otherwise have cut.

Collect a superset. Include the marginal points and the ones you
suspect the author already knows; the report step decides what
survives, and it decides better over a wide set than a narrow one.
Note for each: the problem definition, decision, or gap it concerns,
and the concrete consequence.

## 5. Report

Hand the collected notes to the `writing:findings-summary` skill,
which ships in this plugin. It prunes, ranks, and formats them into
one prioritized list.

Two constraints on that pass:

- **Synthesize only from the notes.** It may drop a finding, merge
  two, or reorder them. It may not invent one you did not collect.
- **One list, not three.** A single priority order is what the reader
  acts on. The category still shows in each finding's own sentence,
  and a problem-definition finding sorts to the top on severity.

Do not rewrite the plan; report and stop.
