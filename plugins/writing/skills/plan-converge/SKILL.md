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

## 1. Locate the plan

The plan lives in the most recent plan comment on the issue. A plan
comment carries the sections `write-plan` emits: Problem, Scope,
Solution, Outline, and Open questions.

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
  ratified, and every question still open. It feeds each round's
  critic verbatim, so ratified rulings are not re-litigated and open
  questions are not re-reported.
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

## 3. Run a round

1. **Snapshot the plan.** Write the current plan comment to
   `snapshot-<round>.md`.
2. **Critique it in fresh context.** Spawn a general-purpose subagent
   and instruct it to load `writing:critique-plan`. Pass the plan
   location, the decision ledger, the known-open list, and the
   previous round's snapshot. Tell it the report feeds an automated
   verification loop, so `findings-summary` skips its pruning. Fresh
   context is the point: the applier's accumulated assumptions are
   what the critic must not inherit.
3. **Verify every finding in the main session.** Check each one
   against the ref the plan builds on, per `critique-plan`. Record
   each rejected finding with its rejection reason. Act only on
   verified findings.
4. **Apply the verified `fix` findings to the plan.** Delete and cite
   where `critique-plan` prescribes it. After each fix, sweep the plan
   for other instances of the same defect class and fix them in the
   same pass.
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

Check these rules in order after each round, and act on the first one
that matches.

1. **Dry.** The round produced zero verified build-changing findings.
   Text-only fixes may still have landed, and they do not reset
   dryness. Stop and report after K consecutive dry rounds.
2. **Blocked.** Every verified build-changing finding is a discuss
   item. Pause, give the user the open-issues doc, and ask for
   rulings. Resume only once the rulings arrive. Write each ruling
   into the ledger and sweep its consequences, per the decision sweep
   in `writing:write-plan`.
3. **Churn.** A majority of the round's verified findings target text
   that prior fix rounds added. Do not run another critique round.
   Run one altitude pass instead: apply the restatement audit from
   `writing:write-plan` to the whole plan and shrink it. Then resume
   the rounds.
4. **Negative value.** The round produced more rejected findings than
   verified build-changing ones. Stop and report. The marginal round
   costs more verification than it returns.

## 5. Report on stop

Give the user:

- The rule that ended the loop.
- The number of rounds run.
- The fixes applied, counted by class.
- The rejected findings, each with its rejection reason.
- The open-issues doc, with a recommendation per item.

The plan comment is already updated in place. Post nothing else.
