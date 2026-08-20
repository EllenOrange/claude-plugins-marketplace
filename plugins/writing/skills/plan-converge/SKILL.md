---
name: plan-converge
description: Run a bounded critique-and-fix loop over a plan on an issue until it converges, then report. Use when the user asks to converge a plan, run the critique loop, iterate a plan until it settles, or keep critiquing and fixing a plan until there is nothing left to find.
---

# plan-converge

Run the critique-and-fix loop over one plan until a stopping rule
ends it, then report. This skill wraps `writing:critique-plan` rather
than restating it. Write all prose per the writing-style rule: the
installed copy at `~/.claude/rules/writing-style.md` if present, else
the plugin's bundled copy at
`${CLAUDE_PLUGIN_ROOT}/rules/writing-style.md`.

## Inputs

- **The issue number** holding the plan. Required.
- **The dryness threshold K.** Optional, and 1 by default. It sets how
  many consecutive dry rounds end the loop.
- **The round budget N.** Optional, and 5 by default. It caps how many
  critique rounds the loop runs before it stops.

## 1. Locate the plan

The plan lives in the most recent plan comment on the issue. A plan
comment carries the sections `write-plan` emits: Problem, Scope,
Solution, Outline, and Open questions. An optional References section
may follow them.

The loop edits a comment, so a plan already promoted into the issue
body needs demoting first. When the issue body carries a `## Plan`
section, ask the user to confirm the demotion. On confirmation, move
that section back into a plan comment, remove it from the body, and
run the loop on the comment. Offer `writing:promote-plan` at the end
of the run. Without confirmation, stop and change nothing.

When the issue carries neither a plan comment nor a `## Plan` section,
say so and stop. Writing a plan is `writing:write-plan`.

## 2. Set up the state

Keep the loop's state in `.claude/tmp/plan-converge-<issue>/`. Never
use the session scratchpad for it. A loop that pauses for rulings can
outlive the session, and the state has to survive that pause.

The state has these files:

- **`ledger.md`, the decision ledger.** Every ruling the user has
  ratified, every question still open, and the loop facts a resumed
  run needs, such as a churn firing. The rulings and the open
  questions feed each round's critic verbatim, so ratified rulings are
  not re-litigated and open questions are not re-reported. The loop
  facts stay out of the critic's brief.
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

Compare the newest snapshot against the live plan comment when you
resume a paused loop. When they differ, someone edited the plan
outside the loop. Show the user the difference and confirm before you
reuse the ledger.

The loop's own edits must not trip the guard. Write a fresh snapshot
once the loop's edit lands on a blocked pause, and again after a churn
consolidation pass. Write it to `snapshot-<next round>.md`, so it is
the newest snapshot the guard compares against. The next round's step
1 rewrites that same file from the live comment, and the round that
just ended keeps its own snapshot for the next critic to read. The
resume comparison then flags only genuine outside edits.

## 3. Run a round

1. **Snapshot the plan.** Write the current plan comment to
   `snapshot-<round>.md`.
2. **Critique it in fresh context.** Spawn a general-purpose subagent
   and instruct it to load `writing:critique-plan`. Pass the plan
   location, the ledger's rulings and open questions, the known-open
   list, and the previous round's snapshot. Withhold the ledger's
   loop facts. Brief it with the materiality bar:
   report a finding only when it is build-changing per the definition
   under "Check the stopping rules", or when the plan's existing
   class-level actions and verify commands do not already cover it.
   Tell the critic that this bar overrides the "Skip the pruning under
   a loop" item in `writing:critique-plan`'s Report step, and that the
   significance definition governs the build-changing label in its
   report. `writing:critique-plan` itself stays unchanged. Fresh
   context is the point: the applier's accumulated assumptions are
   what the critic must not inherit.
3. **Verify every finding in the main session.** Check each one
   against the ref the plan builds on, per `critique-plan`. Record
   each rejected finding with its rejection reason. Act only on
   verified findings.
4. **Apply the verified `fix` findings that clear the acceptance
   bar.** The acceptance bar tests whether the plan already covers the
   finding at class level, through a sweep action plus a verify
   command. On a match, reject the finding, cite the covering action
   as the rejection reason, and record it in the round's rejected
   list. Acceptance-bar rejections count as rejected findings for the
   stopping rules. Apply every finding that clears the bar. Delete and
   cite where `critique-plan` prescribes it. After each fix, sweep the
   plan for other instances of the same defect class and fix them in
   the same pass.
5. **Append the verified `discuss` findings** to the open-issues doc,
   synthesizing them with the prior rounds' themes.
6. **Update the plan's Open questions section** to match the ledger.
7. **Edit the plan comment in place, once.** One edit per round, at
   the end of the round. Never post a new comment.

### Fixes carry no history

Rewrite the plan as if the text had always been right. The plan never
records which round found what, what the text used to say, or who
ruled on a question. Provenance and rulings stay in the state files.

## 4. Check the stopping rules

A finding is **build-changing** when the artifact built from
implementing the plan would change in a significant way. A finding
that only rewords the plan is not build-changing. Neither is a finding
that names one more site the plan's existing class-level action
already sweeps. Several rules below pivot on this term, so apply the
significance bar before you tally a round's findings.

Check these rules in order after each round, and act on the first one
that matches, except where a rule says otherwise. The blocked rule
says otherwise: it sends you back to the remaining rules once its
pause resolves.

1. **Budget spent.** The rounds run have reached the round budget N.
   Stop and report. Critique rounds alone consume budget. A
   consolidation pass and a blocked pause consume none, and a resume
   continues the same count.
2. **Dry.** The round produced zero accepted build-changing fix
   findings and zero verified build-changing discuss findings.
   Accepted means verified and past the acceptance bar in "Run a
   round". Text-only fixes may still have landed, and they do not
   reset dryness. A round carrying build-changing discuss findings is
   not dry, and the blocked rule handles it. Stop and report after K
   consecutive dry rounds.
3. **Blocked.** The round produced verified discuss findings. Pause
   once the round's fixes are applied. Write the fresh snapshot that
   "The staleness guard" prescribes before you pause, so the resume
   comparison does not flag those fixes. Give the user the
   open-issues doc and present the open items one at a time, each as
   a problem statement, its options, and a recommendation. Resume
   only once every item is ruled. Write each ruling into the ledger
   and sweep its consequences, per "Sweep each ruling at decision
   time" in `writing:write-plan`. Then evaluate the remaining rules
   against this same round's tallies, so a churn firing in this round
   is still recorded and acted on at resume.
4. **Churn.** A majority of the round's verified findings target text
   that prior fix rounds added. On the first firing, do not run
   another critique round. Run one consolidation pass instead:
   collapse site-enumeration bullets back into class-level sweep
   actions with verify commands, applying the "Restatements" item from
   `writing:write-plan`'s self-review to the whole plan. Record the
   firing as a line in `ledger.md`, so a resumed loop still knows of
   it. Write the fresh snapshot that "The staleness guard" prescribes
   once the consolidation edit lands. Then resume the rounds. On a
   second firing, stop and report.
5. **Negative value.** The round produced more rejected findings than
   accepted build-changing ones. Acceptance-bar rejections count
   toward the rejected total. The denominator is accepted rather than
   verified on purpose: an acceptance-bar rejection would otherwise
   raise the rejected total while the finding it rejected still
   counted as build-changing, so the same finding would sit on both
   sides of the comparison. Stop and report. The marginal round costs
   more verification than it returns.

## 5. Report on stop

Give the user:

- The rule that ended the loop. Its value is a spent budget, K
  consecutive dry rounds, a second churn firing, or negative value.
- The number of rounds run.
- The fixes applied, counted by class.
- The rejected findings, each with its rejection reason. This list
  carries the acceptance-bar rejections, each citing the plan action
  that already covers the finding.
- The open-issues doc, with a recommendation per item.

The plan comment is already updated in place. Post nothing else.
