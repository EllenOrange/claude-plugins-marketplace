---
name: plan-converge
description: Run a bounded critique-and-fix loop over a plan on an issue until it converges, then report. Use when the user asks to converge a plan, run the critique loop, iterate a plan until it settles, or keep critiquing and fixing a plan until there is nothing left to find.
---

# plan-converge

Run the critique-and-fix loop over one plan until a stopping rule
ends it, then report. This skill wraps `writing:critique-plan` rather
than restating it. Write all prose per the communication-style rule.
Use the installed copy at `~/.claude/rules/communication-style.md` if
present, else the plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/communication-style.md`.

## Inputs

- **The issue number** holding the plan. Required.
- **The dryness threshold K.** Optional, and 1 by default. It sets how
  many consecutive dry rounds end the loop.
- **The round budget N.** Optional, and 5 by default. It caps how many
  critique rounds the loop runs before it stops.

## 1. Locate the plan

The plan lives on one of these surfaces: the most recent plan comment
on the issue, or the issue body itself. A promoted body is the plan,
per `promote-plan` → "4. Write the plan into the issue body", so its
first heading is `## Problem`. A plan carries the sections `write-plan`
emits:

- Problem
- Scope
- Acceptance criteria, with its Invariants subsection
- Solution
- Outline
- Open questions

An optional References section may follow them.

When both surfaces exist, the body governs, because it is the surface
the review reads. Name the leftover comment in the report.

When the issue carries neither a plan comment nor a promoted plan in
its body, say so and stop. Writing a plan is `writing:write-plan`.

### The body-surface guard

Before every edit of a body surface, run the checks below. When an
open pull request or an unmerged remote branch carries the issue, stop
and report without editing. Run the checks again each round, and again
on every resumed run. A loop pauses for rulings and outlives its
session. A pull request that opens during the pause blocks the next
edit as firmly as one that was open at the start.

A criterion under review must not move. The review re-attacks its
criterion theorems every round. A disposition that contradicts the
carried record is a declared reversal, per
`sdlc:theorem-based-pr-reviewer` → "Declare a reversed criterion
verdict". Editing the criterion mid-review is a way to cause one. A
comment surface needs no guard, because the review never reads it.

Each check has the same shape:

- an enumeration with no item cap
- a membership decision through the installed skill
- an over-firing fallback that needs no installed plugin

Use the fallback when the skill is absent or aborts.

**The pull-request check.** Enumerate with:

```bash
gh pr list --state open --limit 1000 --json number
```

Decide membership through `github-prs:pr-closing-issues` per number.
Fall back to:

```bash
gh pr list --state open --limit 1000 --search "<N>"
```

**The branch check.** Enumerate unmerged remote branches only, so a
merged branch never blocks the loop:

```bash
git fetch origin
git symbolic-ref refs/remotes/origin/HEAD
git branch -r --no-merged origin/<default>
```

Restrict the result to `origin/` refs. Decide membership through
`git-tools:git-issues-from-branch` per ref carrying the `issue-`
marker. Fall back to any ref that carries the `issue-` marker and
`<N>` as a hyphen-delimited token.

## 2. Set up the state

Keep the loop's state in `.claude/tmp/plan-converge-<issue>/`. Never
use the session scratchpad for it. A loop that pauses for rulings can
outlive the session, and the state has to survive that pause.

The state has these files:

- **`ledger.md`, the decision ledger.** It holds:
  - every ruling the user ratified, with the round it landed in
  - every question still open
  - the loop facts a resumed run needs, such as a churn firing
  - the round's verified fix findings, held across a pause

  The rulings and the open questions feed each round's critic
  verbatim, so the critic does not re-litigate ratified rulings or
  re-report open questions. The loop facts stay out of the critic's
  brief.
- **`open-issues.md`, the open-issues doc.** The discuss findings
  gathered across rounds, synthesized into common themes, each with
  its options and a recommendation. The user sees this file whenever
  the loop pauses or stops.
- **`snapshot-<round>.md`, one plan snapshot per round.** The plan as
  it stood at the start of that round. The next round's critic reads
  the previous snapshot to label prior-round text.

The ledger and the open-issues doc live here and nowhere else. The
plan carries neither. The plan's Open questions section lists the
ledger's open items, as bare questions with no rulings, no dates, and
no round history.

### The staleness guard

Compare the newest snapshot against the live plan surface when you
resume a paused loop. When they differ, someone edited the plan
outside the loop. Show the user the difference and confirm before you
reuse the ledger.

The loop's own edits must not trip the guard. Write a fresh snapshot
after a churn consolidation pass. That pass is the one occasion.
Write it to `snapshot-<next round>.md`, so it is the newest snapshot
the guard compares against. The next round's step 1 rewrites that
same file from the live surface, and the round that just ended keeps
its own snapshot for the next critic to read. The resume comparison
then flags only genuine outside edits. A blocked pause needs no
snapshot, because the round pauses before it edits anything.

## 3. Run a round

1. **Snapshot the plan.** Write the plan as the located surface
   currently carries it to `snapshot-<round>.md`. That is the comment
   body, or the promoted body from `## Problem` through the end of the
   last plan section, stopping before `## Notes`.
2. **Critique it in fresh context.** Spawn a general-purpose subagent
   and instruct it to load `writing:critique-plan`. Pass it:
   - the round's snapshot as the plan text
   - the surface the plan lives on
   - the ledger's rulings and open questions
   - the known-open list
   - the previous round's snapshot

   In the round after a ruling, pass no previous snapshot.
   `critique-plan` → "Inputs" makes that input optional, so the critic
   labels no text as prior-round text.

   Withhold the ledger's loop facts. Tell the critic that a promoted
   body's `## Notes` section is not plan and yields no finding, which
   the snapshot already excludes. Brief it with the materiality bar.
   Under that bar, the critic reports a finding only when one of these
   holds:
   - the finding is build-changing per `critique-plan` → "4. Collect"
   - the plan's existing class-level actions and verify commands do
     not already cover the finding

   Tell the critic that this bar overrides the "Skip the pruning under
   a loop" item in `writing:critique-plan`'s Report step.
   `writing:critique-plan` itself stays unchanged. Fresh context is
   the point: the applier's accumulated assumptions are what the
   critic must not inherit.
3. **Verify every finding in the main session.** Check each one
   against the ref the plan builds on, per `critique-plan`. Record
   each rejected finding with its rejection reason. Act only on
   verified findings. When the round holds verified discuss findings,
   write the round's verified fix findings to the ledger and pause
   under "Blocked". Step 4 runs once every ruling has landed.
4. **Apply the verified `fix` findings that clear the acceptance
   bar.** The acceptance bar tests whether the plan already covers the
   finding at class level, through a sweep action plus a verify
   command. On a match, reject the finding. Record it in the round's
   rejected list, with the covering action as the rejection reason.
   Acceptance-bar rejections count as rejected findings for the
   stopping rules. Apply every finding that clears the bar. Delete and
   cite where `critique-plan` prescribes it. After each fix, sweep the
   plan for other instances of the same defect class. Fix them in the
   same pass.
5. **Append the verified `discuss` findings** to the open-issues doc,
   synthesizing them with the prior rounds' themes.
6. **Update the plan's Open questions section** to match the ledger.
   Write it in the empty form `write-plan` → "5. Write" owns, so every
   writer and every reader of the section share one form.
7. **Edit the located surface in place, once.** One edit per round, at
   the end of the round. Never post a new comment. On a body surface:
   1. Run "The body-surface guard".
   2. Re-read the live body.
   3. Replace the text from `## Problem` to the line before
      `## Notes`, or to the end of the body when it carries no
      `## Notes`, per `promote-plan` → "4. Write the plan into the
      issue body". `## Notes` and everything after it passes through
      byte for byte unchanged.
   4. Write the result.
   5. Re-read the body after the write.

### Fixes carry no history

Rewrite the plan as if the text had always been right. The plan never
records any of these:

- which round found what
- what the text used to say
- who ruled on a question

Provenance and rulings stay in the state files.

## 4. Check the stopping rules

A finding is **build-changing** per `critique-plan` → "4. Collect",
which owns the definition. A finding that names one more site the
plan's existing class-level action already sweeps is not
build-changing. Several rules below pivot on this term, so apply the
bar before you tally a round's findings.

Check these rules in order after each round. Act on the first one
that matches, except where a rule says otherwise. The blocked rule
says otherwise: it sends you back to the remaining rules once its
pause resolves.

1. **Budget spent.** The rounds run reach the round budget N. Stop and
   report. Critique rounds alone consume budget. A consolidation pass
   and a blocked pause consume none, and a resume continues the same
   count.
2. **Dry.** The round produced zero accepted build-changing fix
   findings and zero verified build-changing discuss findings.
   Accepted means verified and past the acceptance bar in "Run a
   round". Text-only fixes may still have landed, and they do not
   reset dryness. A round carrying build-changing discuss findings is
   not dry, and the blocked rule handles it. Stop and report after K
   consecutive dry rounds.
3. **Blocked.** The round produced verified discuss findings. The
   round pauses under "Run a round" step 3, before any edit of the
   round:
   1. Give the user the open-issues doc.
   2. Present the open items one at a time. Each item carries a
      problem statement, its options, and a recommendation.
   3. Resume only once every item is ruled.
   4. Write each ruling into the ledger. Sweep its consequences, per
      "Sweep each ruling at decision time" in `writing:write-plan`.
      Walk every behavior the ruling changes, per that skill's
      "Walk each stated behavior". The answers ride the round's one
      edit under "Run a round" step 7.
   5. Evaluate the remaining rules against this same round's tallies,
      so the resume still records and acts on a churn firing from
      this round.
4. **Churn.** A majority of the round's verified findings target text
   that prior fix rounds added. On the first firing, do not run
   another critique round. Run one consolidation pass instead:
   1. Collapse site-enumeration bullets back into class-level sweep
      actions with verify commands. Apply the "Restatements" item from
      `writing:write-plan`'s self-review to the whole plan.
   2. Record the firing as a line in `ledger.md`, so a resumed loop
      still knows of it.
   3. Write the fresh snapshot that "The staleness guard" prescribes
      once the consolidation edit lands.
   4. Resume the rounds.

   The round after a ruling cannot fire this rule. Its critic
   receives no previous snapshot, per "Run a round" step 2, so no
   finding carries the prior-round-text label. The round's ordinary
   fixes escape the rule in that round too, because one baseline
   cannot separate the sweep's text from the fixes that landed in the
   same edit. The loop accepts that cost.

   On a second firing, stop and report.
5. **Negative value.** The round produced more rejected findings than
   accepted build-changing ones. Acceptance-bar rejections count
   toward the rejected total. The denominator is accepted rather than
   verified on purpose. Under a verified denominator, an
   acceptance-bar rejection would raise the rejected total while the
   finding it rejected still counted as build-changing. The same
   finding would then sit on both sides of the comparison. Stop and
   report. The marginal round costs more verification than it
   returns.

## 5. Report on stop

Give the user:

- The surface the loop ran on: the plan comment, or the promoted plan
  in the issue body. Name the leftover comment when both existed.
- The rule that ended the loop. Its value is one of:
  - a spent budget
  - K consecutive dry rounds
  - a second churn firing
  - negative value
- The number of rounds run.
- The fixes applied, counted by class.
- The rejected findings, each with its rejection reason. This list
  carries the acceptance-bar rejections, each citing the plan action
  that already covers the finding.
- The open-issues doc, with a recommendation per item.

The plan is already updated in place on its surface, and the report
names that surface. Post nothing else.
