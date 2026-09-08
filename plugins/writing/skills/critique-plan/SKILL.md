---
name: critique-plan
description: Critique a plan by listing the parts that fall short or cause problems elsewhere, then listing the gaps. Use whenever the user asks to critique, review, red-team, poke holes in, or find problems with a plan, spec, design doc, brief, or RFC, even when they don't use the word "critique".
---

# critique-plan

Critique one plan against the problem it claims to solve.
Write all prose per the communication-style rule: the installed copy at
`~/.claude/rules/communication-style.md` if present, else the plugin's
bundled copy at `${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

## Inputs

The user names the plan. A caller running the critique inside a loop,
such as `writing:plan-converge`, may also pass any of these:

- **A decision ledger.** The rulings the user has already ratified.
  Treat each one as a fixed constraint. Do not re-litigate a ratified
  ruling, and do not report a finding that asks for a different
  ruling.
- **A known-open list.** The questions the caller already tracks as
  open. Do not report one of them as a finding.
- **A prior plan snapshot or diff.** The plan as it stood before the
  caller's most recent fix round. Use it for the prior-round-text
  label in the Collect step.

Every input is optional. Without them, critique the plan as it stands.

## 1. Read

- Read the plan in full, from the file, issue comment, or text the
  user points at.
- Read the originating issue, if the plan has one. It is the source
  the plan's problem definition answers to.
- Read `CLAUDE.md` and `README.md`. Then read the docs under `docs/`
  that cover the area the plan touches, and anything the plan
  references. Do not read the whole `docs/` tree.
- Read the code the plan touches. A critique built only on the plan's
  own text repeats the plan's blind spots.
- Resolve the review's sources per
  `${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`. Read the installed
  skill it names, or its fallback. Then read the style guides it names,
  with the per-guide fallback it states.
  Its hardest rule: the acceptance-criteria source is exempt from the
  review's stakes bar and carries a High severity floor.
- Read the neighboring issues the plan's Scope names, and the issue's
  own edges. Read the edges as `write-plan` → "Derive the scope"
  prescribes.

## 2. Check the problem definition

Do this first. A plan aimed at the wrong problem fails whatever its
solution, so the rest of the critique is worthless until this passes.

- **Does the plan define the problem at all?** A plan that opens on a
  solution has skipped the step that makes it judgeable.
- **Does the problem match the issue?** Compare the plan's problem
  statement against what the originating issue reports. Name any
  drift: a narrower problem silently descopes the issue, a wider one
  smuggles in work nobody asked for.
- **Does the problem presuppose the solution?** A problem statement
  that names the fix, the mechanism, or the component to change
  cannot be judged against any other solution. Test it: could a
  second, genuinely different solution answer the same sentence? If
  none could, the sentence is a solution in disguise, and the
  critique starts by saying so.
- **Does the plan solve the problem it states?** Every sub-problem
  needs a unit of work that addresses it.

## 3. Critique

Judge the plan's solution, and each unit of its outline, against these
failure modes:

- It does not fully address the problem it targets.
- It causes a problem elsewhere: in other code, other workflows, or
  later units of the same plan.
- Its scope disagrees with the plan's own Scope section.

Then hunt for gaps: sub-problems no unit addresses, and actions a unit
needs but does not contain.

An Open questions section that carries a bullet absent from the
caller's known-open list is a build-changing finding. Its consequence
is the implementer's stop. With no caller, every bullet counts. The
section's empty form is the one `write-plan` → "5. Write" owns.

### Run the review's sources

Run each source the review works, per
`${CLAUDE_PLUGIN_ROOT}/docs/review-sources.md`. For each source, ask
its question of the plan and of the implementation the Outline
prescribes, then report the finding that file names for a failing
answer. That file owns the questions and the findings; restate neither
here.

### Derive each named set from the code

When the plan binds an obligation to a list of sites, fields, or
rpcs, derive the true set from the code and compare. Enumerate a
shared helper's call sites, the writes and reads able to violate a
stated invariant, and the files that restate a rule the plan
changes. A list smaller than the derived set is a build-changing
finding even when every listed member is correct. Prescribe stating
the membership rule as a class-level sweep action with a verify
command. Do not prescribe adding the missing member to the list: a
grown list is still frozen, and it goes stale on the next change.

### Treat consequential silence as a finding

Compare sibling units the plan treats as parallel. A pattern spelled
out in one and absent from the other is a finding unless the plan
waives it explicitly. So is a stated guarantee with no pinning test,
and an action that pins the order of checks but not what each check
evaluates. These findings are build-changing: the implementer reads
the silence as a decision and builds the gap.

### Flag a rule stated twice with no owner

When the plan writes the same rule or derivation into two sites,
prescribe naming one owning site, with the other site citing it.
This finding is text-only, and it is still worth reporting: every
copy is critique surface, and copies drift apart.

Check the plan's own actions against the plan's ownership rule. An
action that prescribes a copy of a fact the plan declares owned
elsewhere is a finding. So is a verify command that counts one phrase
where the fact has more spellings: it reports a passing count while
the review counts them all.

### Verify against the ref the plan builds on

Verify every claim about the repo against the ref the plan names. When
the plan states that it builds on a branch or a pull request, check
the post-merge state at that ref, never at main. A confident finding
verified at the wrong ref is false, and rejecting it costs the caller
a whole round.

### Verify a cited authority

Read every authority the plan cites, in-repo or external, and verify
it in both directions.

- **The plan's restatement matches the authority.** A plan that cites
  a repo rule and restates it short ships the short version, and the
  implementation inherits it.
- **The plan enumerates no list beside a citation without marking it
  illustrative.** An enumeration next to a citation displaces the
  authority it sits beside.

For an external library, SDK, or service, read the docs or source of
the version the plan targets. Your own recollection is not an
authority. Read it even when the usage looks familiar.

The same rule runs in reverse. Flag any prescription for an external
surface that carries no citation. An uncited usage pattern is where a
guess hides.

### Prescribe delete-and-cite for a wrong restatement

When the plan restates a derivable fact and gets it wrong, prescribe
deleting the restatement and citing the authority. Do not prescribe
correcting the copy. A corrected copy preserves the surface that
produced the finding, and it goes stale again on the next change to
the authority.

## 4. Collect

Write every candidate finding down as rough notes. No format, no
priority order, no verdicts. Those come next, and assigning them now
costs you the finding you would otherwise have cut.

Collect a superset. Include the marginal points and the ones you
suspect the author already knows; the report step decides what
survives, and it decides better over a wide set than a narrow one.
Note for each: the problem definition, solution, unit, or gap it
concerns, and the concrete consequence.

Note these things per finding as well. They survive into the report.

- **Provenance.** The file and the ref you verified the finding
  against. For an external claim, the doc page or source file you
  read. A finding with no provenance is labelled unverified.
- **The build-changing label.** This step owns the label's definition.
  Mark the finding `build-changing` when acting on it changes what the
  implementer builds, decides, or verifies, or what the reviewer
  checks. Mark it `text-only` when acting on it changes the plan's
  prose alone. A contradiction between two of the plan's own
  statements is build-changing, because the implementer cannot know
  which statement to follow. A missing or unfalsifiable criterion is
  build-changing, because the reviewer checks the criteria the plan
  carries.
- **The prior-round-text label.** Mark the finding when it targets
  text a prior fix round added. This needs the prior plan snapshot
  from the Inputs section, so skip the label when the caller passed
  none.

## 5. Report

Hand the collected notes to the `writing:findings-summary` skill,
which ships in this plugin. It prunes, ranks, and formats them into
one prioritized list.

Constrain that pass:

- **Synthesize only from the notes.** It may drop a finding, merge
  two, or reorder them. It may not invent one you did not collect.
- **Emit one list.** A single priority order is what the reader acts
  on. The category still shows in each finding's own sentence, and a
  problem-definition finding sorts to the top on severity.
- **Carry both axes.** Axis one is the `findings-summary` triage
  verdict of `fix`, `refute`, or `discuss`. Axis two is the
  build-changing label. Both ride through `findings-summary` inside
  each finding's own sentence.
- **Skip the pruning under a loop.** When a caller such as
  `writing:plan-converge` runs this critique, tell
  `findings-summary` that the report feeds an automated verification
  loop, so it emits every finding.

State the provenance, the unverified label where it applies, and the
prior-round-text label as the final clause of each finding's Problem
sentence.

Provenance, labels, and rulings belong to the report. Never add any of
them to the plan.

Do not rewrite the plan; report and stop.
