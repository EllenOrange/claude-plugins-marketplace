---
name: critique-plan
description: Critique a plan or spec — list decisions that fall short or cause problems elsewhere, and list gaps. Use whenever the user asks to critique, review, or red-team a plan, spec, or design doc.
---

# critique-plan

Critique one plan or spec against the problems it claims to solve.
Write all prose per `~/.claude/rules/writing-style.md`.

## 1. Read

- Read the plan in full — from the file, issue comment, or text the
  user points at.
- Read the project's foundational docs: `CLAUDE.md`, `README.md`,
  design docs under `docs/`, and anything the plan references.
- Read the code the plan touches. A critique built only on the plan's
  own text repeats the plan's blind spots.

## 2. Critique

Judge each decision in the plan against two failure modes:

- The decision does not fully address the problem it targets.
- The decision causes a problem elsewhere: in other code, other
  workflows, or later steps of the same plan.

Then hunt for gaps: identified problems no decision addresses, and
steps the plan needs but does not contain.

Drop any point a reasonable senior engineer could figure out alone.
Keep only points the plan's author would act on.

## 3. Report

Emit two lists, most important first:

1. **Failing decisions** — for each: the decision, the failure mode
   (does not fully address / causes a problem elsewhere), and the
   concrete consequence.
2. **Gaps** — for each: what is missing and what breaks without it.

If the user has the `findings-summary` skill installed, format both
lists with it. Do not rewrite the plan; report and stop.
