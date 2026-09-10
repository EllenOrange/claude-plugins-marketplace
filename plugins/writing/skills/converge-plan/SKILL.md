---
name: converge-plan
description: Run a bounded critique-and-fix loop over a plan on an issue until it converges, then report. Use when the user asks to converge a plan, run the critique loop, iterate a plan until it settles, or keep critiquing and fixing a plan until there is nothing left to find.
---

# converge-plan

Run the critique-and-fix loop over one plan until a stopping rule
ends it, then report. This skill orchestrates. It wraps
`writing:critique-plan` for discovery of defects,
`writing:sweep-consequences` for discovery of the edits a decision set
forces, `writing:sweep-style` for the whole-plan style pass, and
`writing:revise-plan` for every edit of the plan text, rather than
restating any of them. Write all prose per the communication-style rule.
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
- Solution
- Acceptance criteria, with its Postconditions and Invariants
  subsections
- Outline
- Open questions

An optional References section may follow them. `write-plan` → "State
the acceptance criteria" owns each subsection's entry form and the
Invariants empty form.

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

Keep the loop's state in `.claude/tmp/converge-plan-<issue>/`. Never
use the session scratchpad for it. A loop that pauses for rulings can
outlive the session, and the state has to survive that pause.

The state has these files:

- **`ledger.md`, the decision ledger.** It holds:
  - every ruling the loop has recorded, with the round it landed in
    and its class mark
  - every question still open
  - the loop facts a resumed run needs, such as a churn firing
  - the round's verified fix findings, held across a pause
  - the round's emitted instruction batch
  - whether that batch has been applied to the round's draft

  A ruling carries a user-ratified or repo-derived class mark.
  `write-plan` → "Define the ledger's entry classes" owns the marking.
  A repo-derived entry carries its derivation beside the ruling.

  The rulings and the open questions feed each round's critic
  verbatim, so the critic does not re-litigate a user-ratified ruling
  or re-report an open question. The loop facts stay out of the
  critic's brief.
- **`open-issues.md`, the open-issues doc.** The discuss findings
  gathered across rounds, synthesized into common themes, each with
  its options and a recommendation. The user sees this file whenever
  the loop pauses or stops.
- **`snapshot-<round>.md`, one plan snapshot per round.** The plan as
  it stood at the start of that round. The next round's critic reads
  the previous snapshot to label prior-round text.
- **`draft.md`, the round's working copy of the plan.** The round
  writes it, `writing:revise-plan` edits it, and step 7 copies it to
  the located surface. The next round overwrites it.

The ledger and the open-issues doc live here and nowhere else. The
plan carries neither. The plan's Open questions section lists the
ledger's open items, as bare questions with no rulings, no dates, and
no round history.

### Seed the ledger from the write-plan state

Seed `ledger.md` from `.claude/tmp/write-plan-<issue>/` when that
directory is present. This bullet owns the seeding trigger. Seeding
runs only during this state setup, and only while
`.claude/tmp/converge-plan-<issue>/ledger.md` does not yet exist. A
resumed loop never re-seeds, and a loop whose ledger exists but never
seeded stays unseeded by design.

A seeded ledger arrives with its class marks already present, matching
the format split `write-plan` → "The state directory" states. It
arrives with no round-indexed field and no loop fact, so this skill
initializes its own fields on seeding.

Compare `.claude/tmp/write-plan-<issue>/draft.md` against the live
plan surface before you reuse the seed. `draft.md` holds the posted
full plan, so a byte match is expected and a mismatch means someone
edited the plan at post time. On a mismatch, show the user the
difference and confirm before reusing the seed. That confirmation is
an interaction outside the round structure, before round 1, like the
staleness guard's resume confirmation. "The body-surface guard"
discussion in "1. Locate the plan" owns which surface is the live one.

### The staleness guard

Compare the newest snapshot against the live plan surface when you
resume a paused loop. When they differ, someone edited the plan
outside the loop. Show the user the difference and confirm before you
reuse the ledger.

The loop's own edits must not trip the guard. Write a fresh snapshot
after a consolidation pass. The consolidation passes are the
occasions, and this guard owns that list. Its members are the churn
consolidation pass and the budget-spent consolidation pass.
Write the snapshot to `snapshot-<next round>.md`, so it is the newest snapshot
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
   - the round's snapshot as the plan text, by path
   - the surface the plan lives on
   - the ledger's rulings and open questions, by path
   - the known-open list
   - the previous round's snapshot, by path

   In the round after a ruling, pass no previous snapshot.
   `critique-plan` → "Inputs" makes that input optional, so the critic
   labels no text as prior-round text.

   Tell the critic that a user-ratified ruling is fixed and that a
   finding against a repo-derived one is allowed. Such a finding is
   the veto trigger this session triages.

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
4. **Collect the round's instruction batch.** Apply the acceptance bar
   in the main session. The bar tests whether the plan already covers
   the finding at class level, through a sweep action plus a verify
   command. On a match, reject the finding. Record it in the round's
   rejected list, with the covering action as the rejection reason.
   Acceptance-bar rejections count as rejected findings for the
   stopping rules.

   Run one `writing:sweep-consequences` call per round over the
   round's whole accepted batch. Spawn one general-purpose subagent on
   the Opus model, per `sweep-consequences` → "Execution context",
   instruct it to load that skill, and pass it the accepted batch as
   the decision set plus the round's plan text and the ledger by path.
   After a Blocked pause, re-run the sweep once over the enlarged
   batch on resume: one call per pause-resume cycle.

   The batch takes these instructions:
   - One per finding that clears the bar. It carries the delete-and-cite
     treatment where `critique-plan` prescribes it.
   - Every instruction the sweep emits.
   - One that updates the plan's Open questions section to match the
     ledger. It writes the empty form `write-plan` → "5. Write" owns,
     so every writer and every reader of the section share one form.

   Write the batch to the ledger.

   **Triage the sweep's questions** before the Blocked rule fires.
   `sweep-consequences` → "Output" owns the triage seat, the finding
   shape, the fold rule, and the refute rule. This seat's own behavior
   is the tally arithmetic:
   - A `fix`-triaged question counts as an accepted build-changing
     finding. Record its repo-derived answer in the ledger as a
     vetoable ruling carrying its derivation, marked per `write-plan`
     → "Define the ledger's entry classes". The fold follows the
     owning Output section.
   - A `refute`-triaged question joins the rejected total.
   - An unresolved `revise-plan` conflict joins the rejected total.
   - Only a `discuss` survivor counts as a discuss finding. It lands
     in the ledger as a discuss item, and the round pauses under
     "Blocked" before it posts.
5. **Append the verified `discuss` findings** to the open-issues doc,
   synthesizing them with the prior rounds' themes.
6. **Revise the draft.** Write the round's snapshot to `draft.md`.
   Spawn a general-purpose subagent, instruct it to load
   `writing:revise-plan`, and pass it the draft's path and the batch.
   Read the result back when it reports.

   `revise-plan` → "Output" owns the unapplied-instruction resolution
   rule, and this seat applies it before the round posts. A conflict
   that survives it is recorded as rejected for the round's tallies,
   with the conflict as its reason. The budget-spent consolidation is
   this skill's other applying seat, and it disposes of a conflict the
   same way.
7. **Edit the located surface in place, once.** One edit per round, at
   the end of the round. The surface receives the revised draft's
   content. Never post a new comment. On a body surface:
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

Every instruction leaves the plan reading as if the text had always
been right. The plan never records any of these:

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

1. **Budget spent.** The rounds run reach the round budget N. Run one
   consolidation pass, unconditionally, then stop and report. The pass
   reuses the churn pass's mechanics, so its steps live under "Churn"
   and this rule cites them rather than restating them. "The staleness
   guard" owns the occasions a fresh snapshot is written, and this
   pass is one of them. The consolidation edit lands through "Run a
   round" step 7, and it sits outside the one-edit-per-round rule
   exactly as the churn pass's edit does. Critique rounds alone consume
   budget. A consolidation pass and a blocked pause consume none, and a
   resume continues the same count.
2. **Dry.** The round produced zero accepted build-changing fix
   findings and zero verified build-changing discuss findings.
   Accepted means verified and past the acceptance bar in "Run a
   round". Text-only fixes may still have landed, and they do not
   reset dryness. A round carrying build-changing discuss findings is
   not dry, and the blocked rule handles it. Stop and report after K
   consecutive dry rounds.
3. **Blocked.** The round produced verified discuss findings. A
   `discuss` survivor of the sweep-question triage is one of them, and
   counts as a verified build-changing discuss finding in every tally.
   The round pauses before any edit of the round: at "Run a round"
   step 3 for a finding the critic raised, and at step 4 for a
   surviving sweep question.
   1. Give the user the open-issues doc. It shows every repo-derived
      ruling with its derivation, so the user can veto one.
   2. Present the open items one at a time. Each item carries a
      problem statement, its options, and a recommendation.
   3. Resume only once every item is ruled.
   4. Write each ruling into the ledger, marked user-ratified. Its
      consequences ride the resume's single re-run of
      `writing:sweep-consequences` over the enlarged batch, per "Run a
      round" step 4. The instructions that sweep emits ride the
      round's one edit under "Run a round" step 7.
   5. Evaluate the remaining rules against this same round's tallies,
      so the resume still records and acts on a churn firing from
      this round.

   **A veto** reopens the vetoed question as a discuss item in the
   ledger. It reverts nothing: a ruling that already landed in the
   plan stays landed, the reopened item's eventual ruling rides the
   next round's normal edit, and the tallies are not restated.
4. **Churn.** A majority of the round's verified findings target text
   that prior fix rounds added. On the first firing, do not run
   another critique round. Run one consolidation pass instead:
   1. Write a fresh draft to `draft.md` from the live surface. Spawn a
      general-purpose subagent on the Opus model, per `sweep-style` →
      "Execution context", instruct it to load `writing:sweep-style`,
      and pass it that draft by path. Hand the batch it emits to
      `writing:revise-plan` in a further general-purpose subagent,
      with the same draft passed by path.
   2. Record the firing as a line in `ledger.md`, so a resumed loop
      still knows of it.
   3. Write the fresh snapshot that "The staleness guard" prescribes
      once the consolidation edit lands.
   4. Resume the rounds.

   The consolidation pass runs outside a round, so its edit is the one
   edit of the plan's surface that no round carries. It lands through
   the procedure "Run a round" step 7 owns. That step stays the one
   place that describes an edit of the plan's surface.

   The round after a ruling cannot fire this rule. A ruling here is
   any ledger ruling the previous round recorded, whether the user
   ratified it at a pause or a fix-triaged sweep question derived it.
   Its critic receives no previous snapshot, per "Run a round" step 2,
   so no finding carries the prior-round-text label. The round's ordinary
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
- The open-issues doc, with a recommendation per item. It shows every
  repo-derived ruling with its derivation, so the user can veto one.

The plan is already updated in place on its surface, and the report
names that surface. Post nothing else.
