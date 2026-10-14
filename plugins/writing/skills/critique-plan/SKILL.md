---
name: critique-plan
description: Critique a plan by listing the parts that fall short or cause problems elsewhere, then listing the gaps. Use whenever the user asks to critique, review, red-team, poke holes in, or find problems with a plan, spec, design doc, brief, or RFC, even when they don't use the word "critique".
model: fable
---

# critique-plan

Critique one plan against the problem it claims to solve, and report.
Do not rewrite the plan.

This skill runs on the model its frontmatter names, at the reasoning
tier the session has set.

## Inputs

The user names the plan: a file, an issue comment, an issue body, or
text pasted inline. A caller running the critique as one step of a
larger flow, such as `writing:converge-plan`, may also state that the
report feeds a verification step rather than a human reader.

## 1. Read

- Read the plan in full.
- Read the originating issue, if the plan has one, and the issues its
  edges name. The issue is the source the plan's problem answers to.
- Read `CLAUDE.md` and `README.md`. Then read the docs under `docs/`
  that cover the area the plan touches, and anything the plan
  references. Do not read the whole `docs/` tree.
- Read the code the plan touches. A critique built only on the plan's
  own text repeats the plan's blind spots.
- Read `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` when the plan is one
  `writing:write-plan` produces. It states the format and the style the
  plan is graded against.
- Read `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`. When the sdlc
  plugin is installed, also read the installed
  `sdlc:theorem-generation` skill for what each source means.
- When the sdlc plugin is installed, read the installed
  `sdlc:orchestrate-readiness` skill. It owns the readiness bar.

Count the claims the plan makes as you read. A claim is a sentence
that states a decision, an outcome, a criterion, or a fact about the
tree.

## 2. Check the problem

Do this first. A plan aimed at the wrong problem fails whatever its
design, so the rest of the critique is worthless until this passes.

- **Does the plan define the problem?** A plan that opens on a design
  skips the step that makes it judgeable.
- **Does the problem match the issue?** A narrower problem silently
  descopes the issue. A wider one adds work nobody asked for.
- **Does the problem presuppose the design?** Ask whether a second,
  genuinely different design could answer the same problem. If none
  could, the problem is a design in disguise.
- **Does the design answer every part of the problem?** Each part the
  problem names needs a decision that addresses it.

## 3. Critique

Judge every decision the plan carries against these failure modes:

- It does not fully address the problem it targets.
- It causes a problem elsewhere, in other code, in other workflows, or
  in another decision of the same plan.
- It contradicts another statement in the plan.

Then hunt for gaps: a part of the problem no decision addresses, and a
decision the plan leaves open. A decision is what
`${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` defines as one. A plan that
fails `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` → "A plan is settled"
yields a finding.

### Check the plan against its style

Grade the plan against `${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` when
the plan is one `writing:write-plan` produces. Every rule that file
states yields a finding when the plan breaks it.

### Check every quote against the tree

Read each quoted passage at its path, at the ref the plan builds on.
When the plan builds on a branch or a pull request, read the
post-merge state at that ref, never at main. A quote that fails
`${CLAUDE_PLUGIN_ROOT}/docs/plan-style.md` → "The quote rule" yields a
finding.

### Ask the review's questions

Ask each question in `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md` of
the plan and of the implementation it describes. Report the finding
that file names for a failing answer. When the sdlc plugin is absent,
ask the questions as that file writes them.

### Grade against the readiness bar

When the sdlc plugin is installed, grade the plan against the
installed `sdlc:orchestrate-readiness` bar:

- Ask each bar item's question of the plan.
- Grade the Mechanical bullets per the installed
  `sdlc:orchestrate-readiness` → "The check". Its script reads only an
  issue body, so grade a plan on any other surface bullet by bullet,
  as that skill's "The issue-body grammar" states the script grades
  each key.
- Report each failure as a `readiness-failure` finding whose
  provenance is the bar item it fails.

With no sdlc install, skip this grading and say in the report that it
was skipped.

### Derive each named set from the code

When the plan binds an obligation to a list of sites, fields, or
files, derive the true set from the code and compare. A list smaller
than the derived set is a finding even when every listed member is
correct. Prescribe stating the rule that generates the set, never
adding the missing member.

### Verify each external usage

For an external library, SDK, or service, read the docs or the source
of the version the plan targets. Your own recollection is not an
authority. A usage the plan states with no source behind it is a
finding.

## 4. Sweep each defect's class

When you find one instance of a defect, sweep the whole plan for every
other instance of the same defect before you report. Report the class
as one finding, and list every member in it. A finding that names one
member of a larger class leaves the rest for a later reader to find.

Prescribe only two moves on a refuted claim: delete it, or generalise
it to what the tree supports. Never prescribe elaborating it.

## 5. Collect

Write every candidate finding down as rough notes, unordered and
without verdicts. Collect a superset, including the marginal points.
The report step decides what survives.

Note these things per finding. They survive into the report.

- **Provenance.** The file and the ref you verified the finding
  against. For an external claim, the doc page or source file you
  read. Label a finding with no provenance unverified.
- **The members.** Every instance of the defect, per "4. Sweep each
  defect's class".
- **The finding label.** This step owns the labels' definitions. Give
  each finding exactly one of them:
  - `readiness-failure` when the finding fails an item of the
    installed `sdlc:orchestrate-readiness` bar. A finding that is both
    a bar failure and build-changing takes this label.
  - `build-changing` when acting on it changes what the implementer
    builds, decides, or verifies, or what the reviewer checks. A
    contradiction between two of the plan's own statements is
    build-changing. A missing or unfalsifiable criterion is
    build-changing.
  - `text-only` when the finding is neither.

  A **material** finding is one labeled `build-changing` or
  `readiness-failure`.

## 6. Report

Open the report with one line giving the number of claims the plan
makes, per "1. Read".

Hand the collected notes to the `writing:summarize-findings` skill. It
prunes, ranks, and formats them into one prioritized list. Constrain
that pass:

- **Synthesize only from the notes.** It may drop a finding, merge
  two, or reorder them. It may not invent one you did not collect.
- **Emit one list.** A problem finding sorts to the top on severity.
- **Carry both axes.** Each finding carries its `summarize-findings`
  triage verdict and its finding label, inside its own sentence.
- **Skip the pruning for a verification step.** When the caller
  states that the report feeds a verification step, tell
  `summarize-findings` so, and it emits every finding.

State the provenance, the unverified label where it applies, and the
members of the class as the final clause of each finding's Problem
sentence.

Report and stop.
